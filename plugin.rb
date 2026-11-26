# frozen_string_literal: true

# name: discourse-moaclab-tools
# about: Registers first-class /typing and /viewer routes plus CAD model storage for Moaclab tool theme components.
# meta_topic_id: 0
# version: 1.7.0
# authors: Moaclab, Codex
# url: https://moaclab.com
# required_version: 3.3.0

require "uri"
require "fileutils"
require "json"
require "securerandom"
require "digest"

enabled_site_setting :moaclab_tools_enabled

module ::DiscourseMoaclabTools
  ROUTES = { "/typing" => :typing, "/viewer" => :viewer }.freeze
  MODEL_EXTENSIONS = %w[step stp igs iges dxf dwg].freeze
  MODEL_ID_PATTERN = /\A[a-f0-9]{16}\z/
  MAX_MODEL_BYTES = 25.megabytes
  SOURCE_EXTENSIONS = %w[step stp igs iges dxf dwg].freeze
  SOURCE_ID_PATTERN = /\A[a-f0-9]{32}\z/

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

  def self.model_storage_dir
    Rails.root.join("public", "uploads", "moaclab-cad-models")
  end

  # STEP 等源文件只给特权群组下载，必须存在 nginx 直接发放的 public/ 以外。
  # 生产容器里 /shared 是持久卷（rebuild 不丢），开发和测试环境退回 tmp/。
  def self.source_storage_dir
    configured = ENV["MOACLAB_CAD_SOURCE_DIR"].presence
    return Pathname.new(configured) if configured
    return Pathname.new("/shared/moaclab-cad-sources") if Rails.env.production? && File.directory?("/shared")

    Rails.root.join("tmp", "moaclab-cad-sources#{ENV["TEST_ENV_NUMBER"]}")
  end

  def self.max_source_bytes
    SiteSetting.moaclab_cad_source_max_size_mb.to_i.megabytes
  end

  def self.can_download_sources?(user)
    return false if user.blank?

    group_ids = SiteSetting.moaclab_cad_source_download_groups_map
    group_ids.present? && user.in_any_groups?(group_ids)
  end

  def self.safe_model_name(name)
    File.basename(name.to_s).gsub(/[[:cntrl:]\r\n]/, "").presence || "moaclab-cad-model"
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
  module ::DiscourseMoaclabTools
    class ModelsController < ::ApplicationController
      requires_plugin "discourse-moaclab-tools"

      before_action :ensure_logged_in, only: [:create]
      skip_before_action :check_xhr, only: %i[create show]

      def create
        file = params[:model]
        raise Discourse::InvalidParameters.new(:model) if file.blank?

        original_name = DiscourseMoaclabTools.safe_model_name(params[:name].presence || file.original_filename)
        ext = File.extname(original_name).delete_prefix(".").downcase
        raise Discourse::InvalidParameters.new(:type) if !MODEL_EXTENSIONS.include?(ext)

        size = file.respond_to?(:size) ? file.size.to_i : File.size(file.tempfile.path)
        if size <= 0 || size > MAX_MODEL_BYTES
          render json: { ok: false, error: "file too large" }, status: 413
          return
        end

        id = SecureRandom.hex(8)
        FileUtils.mkdir_p(DiscourseMoaclabTools.model_storage_dir)
        path = DiscourseMoaclabTools.model_storage_dir.join("#{id}.#{ext}")
        meta_path = DiscourseMoaclabTools.model_storage_dir.join("#{id}.json")

        FileUtils.cp(file.tempfile.path, path)
        File.binwrite(
          meta_path,
          {
            id: id,
            name: original_name,
            ext: ext,
            size: size,
            uploaded_by: current_user&.id,
            created_at: Time.zone.now.iso8601,
          }.to_json,
        )

        render json: {
          ok: true,
          id: id,
          name: original_name,
          ext: ext,
          size: size,
          url: "/moaclab-cad/models/#{id}",
        }
      end

      def show
        id = params[:id].to_s
        raise Discourse::InvalidParameters.new(:id) if !MODEL_ID_PATTERN.match?(id)

        meta_path = DiscourseMoaclabTools.model_storage_dir.join("#{id}.json")
        raise Discourse::NotFound if !File.file?(meta_path)

        meta = JSON.parse(File.read(meta_path))
        ext = meta["ext"].to_s.gsub(/[^a-z0-9]/, "")
        raise Discourse::NotFound if !MODEL_EXTENSIONS.include?(ext)

        path = DiscourseMoaclabTools.model_storage_dir.join("#{id}.#{ext}")
        raise Discourse::NotFound if !File.file?(path)

        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["Cache-Control"] = "public, max-age=3600"
        send_file path, type: "application/octet-stream", disposition: "inline", filename: "#{id}.#{ext}"
      end
    end
  end

  module ::DiscourseMoaclabTools
    class SourcesController < ::ApplicationController
      requires_plugin "discourse-moaclab-tools"

      before_action :ensure_logged_in
      skip_before_action :check_xhr, only: %i[create show]

      def create
        file = params[:source]
        raise Discourse::InvalidParameters.new(:source) if file.blank?

        original_name = DiscourseMoaclabTools.safe_model_name(params[:name].presence || file.original_filename)
        ext = File.extname(original_name).delete_prefix(".").downcase
        raise Discourse::InvalidParameters.new(:type) if !SOURCE_EXTENSIONS.include?(ext)

        size = file.respond_to?(:size) ? file.size.to_i : File.size(file.tempfile.path)
        if size <= 0 || size > DiscourseMoaclabTools.max_source_bytes
          render json: { ok: false, error: "file too large" }, status: 413
          return
        end

        RateLimiter.new(current_user, "moaclab-cad-source-upload", 30, 1.hour).performed! if !current_user.staff?

        id = SecureRandom.hex(16)
        dir = DiscourseMoaclabTools.source_storage_dir
        FileUtils.mkdir_p(dir)
        FileUtils.cp(file.tempfile.path, dir.join("#{id}.#{ext}"))
        File.binwrite(
          dir.join("#{id}.json"),
          {
            id: id,
            name: original_name,
            ext: ext,
            size: size,
            sha256: Digest::SHA256.file(file.tempfile.path).hexdigest,
            uploaded_by: current_user.id,
            created_at: Time.zone.now.iso8601,
          }.to_json,
        )

        render json: { ok: true, id: id, name: original_name, ext: ext, size: size }
      end

      def show
        raise Discourse::InvalidAccess if !DiscourseMoaclabTools.can_download_sources?(current_user)

        id = params[:id].to_s
        raise Discourse::InvalidParameters.new(:id) if !SOURCE_ID_PATTERN.match?(id)

        dir = DiscourseMoaclabTools.source_storage_dir
        meta_path = dir.join("#{id}.json")
        raise Discourse::NotFound if !File.file?(meta_path)

        meta = JSON.parse(File.read(meta_path))
        ext = meta["ext"].to_s.gsub(/[^a-z0-9]/, "")
        raise Discourse::NotFound if !SOURCE_EXTENSIONS.include?(ext)

        path = dir.join("#{id}.#{ext}")
        raise Discourse::NotFound if !File.file?(path)

        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["Cache-Control"] = "private, no-store"
        send_file path,
                  type: "application/octet-stream",
                  disposition: "attachment",
                  filename: DiscourseMoaclabTools.safe_model_name(meta["name"].presence || "#{id}.#{ext}")
      end
    end
  end

  add_to_serializer(:current_user, :can_download_moaclab_cad_sources) do
    DiscourseMoaclabTools.can_download_sources?(object)
  end

  Discourse::Application.routes.append do
    get "/typing" => "list#latest", defaults: { format: :html }
    get "/viewer" => "list#latest", defaults: { format: :html }
    post "/moaclab-cad/models" => "discourse_moaclab_tools/models#create", defaults: { format: :json }
    get "/moaclab-cad/models/:id" => "discourse_moaclab_tools/models#show", constraints: { id: /[a-f0-9]{16}/ }
    post "/moaclab-cad/sources" => "discourse_moaclab_tools/sources#create", defaults: { format: :json }
    get "/moaclab-cad/sources/:id" => "discourse_moaclab_tools/sources#show", constraints: { id: /[a-f0-9]{32}/ }
  end
end
