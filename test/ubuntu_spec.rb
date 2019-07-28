require_relative "spec_helper"

describe "box" do
  it "should have a root user" do
    expect(user "root").to exist
  end

  it "should turn off release upgrades" do
    expect(file("/etc/update-manager/release-upgrades").content).to match(/Prompt=never/)
  end
end
