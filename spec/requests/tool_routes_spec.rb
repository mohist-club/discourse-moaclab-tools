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
end
