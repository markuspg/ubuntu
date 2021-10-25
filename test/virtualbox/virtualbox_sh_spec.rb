require_relative "../spec_helper"

describe "virtualbox template" do
  it "should install Virtualbox Guest Tools" do
    expect(user_command("lsmod | grep vboxguest").stdout).to match(/vboxguest/)
  end
end
