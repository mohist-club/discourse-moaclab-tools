# frozen_string_literal: true

# name: discourse-moaclab-tools
# about: Registers first-class /typing and /viewer routes for Moaclab tool theme components.
# meta_topic_id: 0
# version: 1.0.0
# authors: Moaclab, Codex
# url: https://moaclab.com
# required_version: 3.3.0

enabled_site_setting :moaclab_tools_enabled

after_initialize do
  Discourse::Application.routes.append do
    get "/typing" => "list#latest", defaults: { format: :html }
    get "/viewer" => "list#latest", defaults: { format: :html }
  end
end
