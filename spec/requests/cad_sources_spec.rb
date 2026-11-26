# frozen_string_literal: true

require "rails_helper"

describe "Moaclab private CAD sources" do
  fab!(:user)
  fab!(:moderator)
  fab!(:admin)

  let(:step_file) do
    path = Rails.root.join("tmp", "moaclab-source-spec-#{SecureRandom.hex(4)}.step")
    File.write(path, "ISO-10303-21;\nHEADER;\nENDSEC;\nEND-ISO-10303-21;\n")
    Rack::Test::UploadedFile.new(path, "application/octet-stream", original_filename: "bracket.step")
  end

  before do
    SiteSetting.moaclab_tools_enabled = true
    FileUtils.rm_rf(DiscourseMoaclabTools.source_storage_dir)
  end

  after { FileUtils.rm_rf(DiscourseMoaclabTools.source_storage_dir) }

  def upload_as(someone, file = step_file)
    sign_in(someone)
    post "/moaclab-cad/sources.json", params: { source: file }
    response.parsed_body
  end

  it "stores sources outside public/" do
    expect(DiscourseMoaclabTools.source_storage_dir.to_s).not_to include("/public/")
  end

  describe "upload" do
    it "requires login" do
      post "/moaclab-cad/sources.json", params: { source: step_file }
      expect(response.status).to eq(403)
    end

    it "stores the file and returns an id without a public url" do
      json = upload_as(user)
      expect(response.status).to eq(200)
      expect(json["ok"]).to eq(true)
      expect(json["id"]).to match(/\A[a-f0-9]{32}\z/)
      expect(json).not_to have_key("url")
      expect(File.file?(DiscourseMoaclabTools.source_storage_dir.join("#{json["id"]}.step"))).to eq(true)
    end

    it "rejects extensions outside the whitelist" do
      sign_in(user)
      file = Rack::Test::UploadedFile.new(step_file.path, "text/html", original_filename: "evil.html")
      post "/moaclab-cad/sources.json", params: { source: file }
      expect(response.status).to eq(400)
    end

    it "rejects files over the size limit" do
      SiteSetting.moaclab_cad_source_max_size_mb = 1
      big = Rails.root.join("tmp", "moaclab-source-big-#{SecureRandom.hex(4)}.step")
      File.binwrite(big, "0" * (1.megabyte + 1))
      upload_as(user, Rack::Test::UploadedFile.new(big, "application/octet-stream", original_filename: "big.step"))
      expect(response.status).to eq(413)
    end
  end

  describe "download" do
    let!(:source_id) { upload_as(user)["id"] }

    it "refuses anonymous visitors" do
      sign_out
      get "/moaclab-cad/sources/#{source_id}"
      expect(response.status).to eq(403)
    end

    it "refuses regular users, including the uploader" do
      sign_in(user)
      get "/moaclab-cad/sources/#{source_id}"
      expect(response.status).to eq(403)
    end

    it "refuses moderators by default" do
      sign_in(moderator)
      get "/moaclab-cad/sources/#{source_id}"
      expect(response.status).to eq(403)
    end

    it "lets admins download the original file as an attachment" do
      sign_in(admin)
      get "/moaclab-cad/sources/#{source_id}"
      expect(response.status).to eq(200)
      expect(response.body).to start_with("ISO-10303-21;")
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.headers["Content-Disposition"]).to include("bracket.step")
      expect(response.headers["Cache-Control"]).to include("no-store")
    end

    it "follows the configured download groups" do
      SiteSetting.moaclab_cad_source_download_groups = Group::AUTO_GROUPS[:staff].to_s
      sign_in(moderator)
      get "/moaclab-cad/sources/#{source_id}"
      expect(response.status).to eq(200)
    end

    it "returns 404 for unknown ids to permitted users" do
      sign_in(admin)
      get "/moaclab-cad/sources/#{"0" * 32}"
      expect(response.status).to eq(404)
    end
  end

  describe "current user serializer" do
    it "exposes can_download_moaclab_cad_sources" do
      sign_in(admin)
      get "/session/current.json"
      expect(response.parsed_body["current_user"]["can_download_moaclab_cad_sources"]).to eq(true)

      sign_in(user)
      get "/session/current.json"
      expect(response.parsed_body["current_user"]["can_download_moaclab_cad_sources"]).to eq(false)
    end
  end
end
