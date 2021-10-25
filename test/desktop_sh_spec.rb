require_relative "spec_helper"

describe "desktop.sh" do
  it "should enable auto-login" do
    expect(file("/etc/gdm3/custom.conf")).to contain "AutomaticLoginEnable = true"
    expect(file("/etc/gdm3/custom.conf")).to contain "AutomaticLogin = vagrant"
  end

  it "should disable the screen saver" do
    expect(user_command("gsettings get org.gnome.desktop.session idle-delay").stdout).to match(/0/)
  end

  it "should add German input sources" do
    expect(user_command("gsettings get org.gnome.desktop.input-sources sources").stdout).to match(/('xkb', 'de')/)
  end
end
