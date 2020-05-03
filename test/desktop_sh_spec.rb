require_relative "spec_helper"

describe "desktop.sh" do
  it "should enable auto-login" do
    if os[:release] == "16.04"
      expect(file("/etc/lightdm/lightdm.conf")).to contain "autologin-user=vagrant"
      expect(file("/etc/lightdm/lightdm.conf")).to contain "autologin-user-timeout=0"
    else
      expect(file("/etc/gdm3/custom.conf")).to contain "AutomaticLoginEnable = true"
      expect(file("/etc/gdm3/custom.conf")).to contain "AutomaticLogin = vagrant"
    end
  end

  it "should disable the screen saver" do
    expect(user_command("gsettings get org.gnome.desktop.session idle-delay").stdout).to match /0/
  end

  it "should add German input sources" do
    expect(user_command("gsettings get org.gnome.desktop.input-sources sources").stdout).to match /('xkb', 'de')/
  end
end
