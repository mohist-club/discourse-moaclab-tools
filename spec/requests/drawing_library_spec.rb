# frozen_string_literal: true
require "rails_helper"

describe "Moaclab drawing library" do
  let(:raw) { '[moaclab-3d id="0123456789abcdef" ext="step" title="case.step"]' }
  fab!(:user)
  fab!(:group)

  before do
    SiteSetting.moaclab_tools_enabled = true
    SiteSetting.prevent_anons_from_downloading_files = false
  end

  def draw(raw: self.raw, **attributes)
    Fabricate(:post, raw: raw, cooked: PrettyText.cook(raw), **attributes)
  end

  it "lists public drawing topics and constructs a preview link" do
    post = draw
    get "/moaclab-cad/drawings.json"
    expect(response.status).to eq(200)
    item = response.parsed_body["drawings"].find { |entry| entry["id"] == post.topic_id }
    expect(item["topic_url"]).to eq("/t/topic/#{post.topic_id}")
    expect(item["preview_url"]).to include("id=0123456789abcdef")
    expect(response.headers["Cache-Control"]).to include("no-store")
  end

  it "excludes private messages, restricted categories and unlisted topics" do
    private_post = draw(topic: Fabricate(:private_message_topic, user: user))
    restricted = draw(topic: Fabricate(:topic, category: Fabricate(:private_category, group: group)))
    unlisted = draw(topic: Fabricate(:topic, visible: false))
    get "/moaclab-cad/drawings.json"
    expect(response.parsed_body["drawings"].map { |item| item["id"] }).not_to include(private_post.topic_id, restricted.topic_id, unlisted.topic_id)
  end

  it "does not collect code samples, replies, hidden or deleted posts" do
    code = draw(raw: "```\n#{raw}\n```")
    hidden = draw(hidden: true)
    deleted = draw
    deleted.trash!
    reply = draw(post_number: 2)
    get "/moaclab-cad/drawings.json"
    expect(response.parsed_body["drawings"]).to eq([])
  end

  it "filters formats, searches titles and reflects source edits" do
    post = draw
    get "/moaclab-cad/drawings.json", params: { format_filter: "dwg" }
    expect(response.parsed_body["drawings"]).to eq([])
    post.topic.update!(title: "Shared enclosure drawing")
    get "/moaclab-cad/drawings.json", params: { q: "Shared enclosure", format_filter: "step" }
    expect(response.parsed_body["drawings"].first["title"]).to eq("Shared enclosure drawing")
  end

  it "rejects unsupported and external model references" do
    library = DiscourseMoaclabTools::DrawingLibrary.new(Guardian.new)
    expect(library.preview_url({ "url" => "https://untrusted.example/uploads/private.step", "ext" => "step" })).to be_nil
    expect(library.preview_url({ "id" => "0123456789abcdef", "ext" => "exe" })).to be_nil
    expect(library.preview_url({ "id" => "0123456789abcdef", "ext" => "step", "listed" => "false" })).to be_nil
  end

  it "includes drawings-tag topics without a shortcode and previews native attachments" do
    SiteSetting.authorized_extensions = "jpg|jpeg|png|step"
    tag = Fabricate(:tag, name: "drawings")
    overview = draw(raw: "Open source drawing project")
    attached = draw(raw: "[plate.step|attachment](upload://abc123.step)")
    upload = Fabricate(:upload, original_filename: "plate.step", extension: "step", secure: false)
    attached.update!(cooked: "<p><a class=\"attachment\" href=\"#{Upload.short_path(sha1: upload.sha1, extension: 'step')}\">plate.step</a></p>")
    [overview, attached].each { |post| post.topic.tags << tag }
    get "/moaclab-cad/drawings.json"
    items = response.parsed_body["drawings"].index_by { |item| item["id"] }
    expect(items[overview.topic_id]["preview_url"]).to be_nil
    expect(items[attached.topic_id]["preview_url"]).to include(upload.base62_sha1)
    expect(items[attached.topic_id]["format"]).to eq("STEP")
    get "/moaclab-cad/drawings.json", params: { format_filter: "step" }
    expect(response.parsed_body["drawings"].map { |item| item["id"] }).to eq([attached.topic_id])
    SiteSetting.prevent_anons_from_downloading_files = true
    get "/moaclab-cad/drawings.json"
    expect(response.parsed_body["drawings"].find { |entry| entry["id"] == attached.topic_id }["preview_url"]).to be_nil
    SiteSetting.prevent_anons_from_downloading_files = false
    upload.update!(secure: true)
    get "/moaclab-cad/drawings.json", params: { format_filter: "step" }
    expect(response.parsed_body["drawings"]).to eq([])
    upload.destroy!
    get "/moaclab-cad/drawings.json"
    item = response.parsed_body["drawings"].find { |entry| entry["id"] == attached.topic_id }
    expect(item["preview_url"]).to be_nil
  end

  it "deduplicates tagged references and keeps tag visibility and opt-out rules" do
    tag = Fabricate(:tag, name: "drawings")
    public_post = draw
    restricted = draw(topic: Fabricate(:topic, category: Fabricate(:private_category, group: group)))
    unlisted = draw(topic: Fabricate(:topic, visible: false))
    opted_out = draw(raw: raw.sub("]", ' listed="false"]'))
    [public_post, restricted, unlisted, opted_out].each { |post| post.topic.tags << tag }
    get "/moaclab-cad/drawings.json"
    ids = response.parsed_body["drawings"].map { |item| item["id"] }
    expect(ids.count(public_post.topic_id)).to eq(1)
    expect(ids).not_to include(restricted.topic_id, unlisted.topic_id, opted_out.topic_id)
    public_post.update!(raw: "Overview", cooked: "<p>Overview</p>")
    public_post.topic.tags.clear
    get "/moaclab-cad/drawings.json"
    expect(response.parsed_body["drawings"].map { |item| item["id"] }).not_to include(public_post.topic_id)
  end
end
