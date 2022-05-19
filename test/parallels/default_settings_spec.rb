require_relative "../spec_helper"

describe "parallels template" do
  it "should use Virtio graphics adapter" do
    expect(user_command("lspci | grep VGA").stdout).to match(/Red Hat, Inc. Virtio GPU/)
  end
end
