require_relative "spec_helper"

describe "general box settings" do
  it "should have a root user" do
    expect(user("root")).to exist
  end

  it "should have a vagrant user" do
    expect(user("vagrant")).to exist
  end

  it "should turn off release upgrades" do
    expect(file("/etc/update-manager/release-upgrades").content).to match(/Prompt=never/)
  end
end
