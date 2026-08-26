# frozen_string_literal: true

require "rails_helper"

describe "Moaclab tool routes" do
  before { SiteSetting.moaclab_tools_enabled = true }

  it "serves the Discourse application shell for Typing" do
    get "/typing"
    expect(response.status).to eq(200)
    expect(response.media_type).to eq("text/html")
  end

  it "serves the Discourse application shell for Viewer" do
    get "/viewer"
    expect(response.status).to eq(200)
    expect(response.media_type).to eq("text/html")
  end

  it "publishes the versioned CAD Viewer runtime" do
    get "/plugins/discourse-moaclab-tools/viewer/v051/viewer-bundle-v051.js"
    expect(response.status).to eq(200)
    expect(%w[application/javascript text/javascript]).to include(response.media_type)
  end

  it "publishes the OCCT WebAssembly decoder" do
    get "/plugins/discourse-moaclab-tools/viewer/v051/occt-import-js-v051.wasm"
    expect(response.status).to eq(200)
    expect(response.media_type).to eq("application/wasm")
  end

  it "rejects malformed CAD model ids" do
    get "/moaclab-cad/models/not-a-model"
    expect(response.status).to eq(404)
  end
end
