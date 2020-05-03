require_relative "../spec_helper"

describe "virtualbox template" do
  it "should use VMSVGA graphics adapter", :unless => os[:release] == "16.04" do
    expect(user_command("lspci | grep VGA").stdout).to match /VMware SVGA II Adapter/
  end
end
