# frozen_string_literal: true

module DiscourseMoaclabTools
  class DrawingLibrary
    PAGE_SIZE = 24
    SCAN_SIZE = 120
    SHORTCODE = /\[moaclab-3d\s+([^\]]+)\]/i
    ATTRIBUTES = /([a-z0-9_-]+)\s*=\s*(?:"([^"]*)"|“([^”]*)”|'([^']*)'|‘([^’]*)’|([^\s]+))/i

    def initialize(guardian)
      @guardian = guardian
    end

    def list(params)
      # Only published public first posts are discoverable, even for administrators.
      topics = Topic.visible.secured.where(archetype: Archetype.default)
      tagged_topics = TopicTag.where(tag_id: Tag.where(name: "drawings").select(:id)).select(:topic_id)
      posts = Post.where(topic_id: topics.select(:id), post_number: 1, hidden: false)
      posts = posts.where("raw LIKE ?", "%[moaclab-3d %").or(posts.where(topic_id: tagged_topics))
      cursor = params[:before].to_i
      posts = posts.where("posts.id < ?", cursor) if cursor.positive?
      query = params[:q].to_s.strip.first(100)
      if query.present?
        titles = Topic.where("title ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%")
        posts = posts.where(topic_id: titles.select(:id))
      end
      format = params[:format_filter].to_s.downcase
      format = "" unless MODEL_EXTENSIONS.include?(format)
      candidates = posts.includes(:topic, :user).order(id: :desc).limit(SCAN_SIZE + 1).to_a
      tagged_ids = TopicTag.where(topic_id: candidates.map(&:topic_id), tag_id: Tag.where(name: "drawings").select(:id)).pluck(:topic_id).to_set
      items = []
      consumed = 0
      candidates.first(SCAN_SIZE).each do |post|
        consumed += 1
        next unless @guardian.can_see?(post.topic)
        document = Nokogiri::HTML.fragment(post.cooked.to_s)
        document.css("pre, code, blockquote").remove
        references = document.text.scan(SHORTCODE).map do |match|
          match.first.scan(ATTRIBUTES).to_h { |key, *values| [key.downcase, values.compact.first] }
        end
        drawing = references.filter_map do |attrs|
          preview = preview_url(attrs)
          next unless preview
          ext = (attrs["ext"] || attrs["type"]).to_s.downcase
          next if format.present? && ext != format
          { preview_url: preview, format: ext.upcase }
        end.first
        if tagged_ids.include?(post.topic_id) && drawing.nil?
          next if references.any? { |attrs| attrs["listed"] == "false" }
          drawing = attachment_preview(document, format)
          drawing ||= { preview_url: nil, format: nil } if format.blank?
        end
        next unless drawing
        image = document.css("img:not(.emoji)").filter_map { |img| safe_image(img["src"]) }.first
        items << drawing.merge(
          id: post.topic_id,
          title: post.topic.title,
          topic_url: "/t/topic/#{post.topic_id}",
          image_url: image,
          username: post.user&.username,
          created_at: post.created_at.iso8601,
          replies: [post.topic.posts_count - 1, 0].max,
        )
        break if items.size >= PAGE_SIZE
      end
      more = candidates.size > consumed
      { drawings: items, next_before: more ? candidates[consumed - 1].id : nil }
    end

    def attachment_preview(document, format)
      login_required = SiteSetting.prevent_anons_from_downloading_files && @guardian.user.nil?
      document.css("a.attachment[href]").each do |link|
        url = URI.parse(link["href"])
        ext = File.extname(url.path.to_s).delete_prefix(".").downcase
        next if format.present? && ext != format
        preview = preview_url({ "url" => link["href"], "ext" => ext, "title" => link.text })
        next unless preview
        sha1 = Upload.sha1_from_short_path(url.path) || Upload.sha1_from_long_url(url.path)
        next unless sha1
        @attachment_uploads ||= {}
        upload = @attachment_uploads.fetch(sha1) do
          @attachment_uploads[sha1] = Upload.without_s3_file_missing_confirmed_verification_status.find_by(sha1: sha1, secure: false)
        end
        return { preview_url: login_required ? nil : preview, format: ext.upcase } if upload
      rescue URI::InvalidURIError
        next
      end
      nil
    end

    def preview_url(attrs)
      return if attrs["listed"] == "false"
      ext = (attrs["ext"] || attrs["type"]).to_s.downcase
      return unless MODEL_EXTENSIONS.include?(ext)
      params = { ext: ext, name: (attrs["title"] || attrs["name"]).to_s.first(255) }
      if attrs["id"].to_s.match?(MODEL_ID_PATTERN)
        params[:id] = attrs["id"]
      elsif attrs["upload"].to_s.match?(%r{\Aupload://[A-Za-z0-9._-]+\z})
        params[:upload] = attrs["upload"]
      elsif attrs["url"].present?
        url = URI.parse(attrs["url"])
        base = URI.parse(Discourse.base_url)
        return unless (url.host.nil? || url.host == base.host) && url.path.start_with?("/uploads/")
        return if url.scheme.present? && !%w[https http].include?(url.scheme)
        params[:url] = attrs["url"]
      else
        return
      end
      "/viewer?#{URI.encode_www_form(params)}"
    rescue URI::InvalidURIError
      nil
    end

    def safe_image(value)
      url = URI.parse(value.to_s)
      return value if url.scheme == "https" || (url.scheme.nil? && value.to_s.start_with?("/") && !value.start_with?("//"))
    rescue URI::InvalidURIError
      nil
    end
  end
end
