# frozen_string_literal: true

# name: discourse-moaclab-tools
# about: Registers first-class /typing and /viewer routes for Moaclab tool theme components.
# meta_topic_id: 0
# version: 1.3.0
# authors: Moaclab, Codex
# url: https://moaclab.com
# required_version: 3.3.0

require "uri"

enabled_site_setting :moaclab_tools_enabled

module ::DiscourseMoaclabTools
  ROUTES = { "/typing" => :typing, "/viewer" => :viewer }.freeze

  def self.route_key(url)
    path = url.to_s.split("?", 2).first
    path = URI.parse(path).path if path.start_with?("http://", "https://")
    path = path.delete_suffix("/") unless path == "/"
    ROUTES[path]
  rescue URI::InvalidURIError
    nil
  end

  def self.meta_value(route, property)
    configured = SiteSetting.public_send("moaclab_#{route}_meta_#{property}")
    configured.presence || I18n.t("discourse_moaclab_tools.#{route}_#{property}")
  end
end

register_modifier(:meta_data_content) do |content, property, options|
  route = DiscourseMoaclabTools.route_key(options[:url])
  route && %i[title description].include?(property) ? DiscourseMoaclabTools.meta_value(route, property) : content
end

register_html_builder("server:before-head-close") do |controller|
  route = DiscourseMoaclabTools.route_key(controller.request.fullpath)
  if route
    keywords = ERB::Util.html_escape(DiscourseMoaclabTools.meta_value(route, :keywords))
    %(<meta name="keywords" content="#{keywords}">)
  else
    ""
  end
end

after_initialize do
  Discourse::Application.routes.append do
    get "/typing" => "list#latest", defaults: { format: :html }
    get "/viewer" => "list#latest", defaults: { format: :html }
  end
end
