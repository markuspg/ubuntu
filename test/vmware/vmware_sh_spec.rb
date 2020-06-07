require_relative "../spec_helper"

describe "vmware.sh" do
  it "should install openvm tools" do
    expect(package("open-vm-tools")).to be_installed
    expect(package("open-vm-tools-desktop")).to be_installed
  end
end
