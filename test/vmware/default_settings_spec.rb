require_relative "../spec_helper"

describe "vmware template" do
  it "should use VMSVGA graphics adapter" do
    expect(user_command("lspci | grep VGA").stdout).to match /VMware SVGA II Adapter/
  end
end
