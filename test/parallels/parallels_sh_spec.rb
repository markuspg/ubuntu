require_relative "../spec_helper"

describe "parallels.sh" do
  it "should install Parallels Tools" do
    expect(user_command("lsmod | grep prl_").stdout).to contain("prl_fs")
  end
end
