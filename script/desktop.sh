#!/bin/bash -eux

if [[ ! "$DESKTOP" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
    exit
fi

SSH_USER=${SSH_USERNAME:-vagrant}

echo "==> Checking version of Ubuntu"
. /etc/lsb-release

echo "==> Installing ubuntu-desktop"
apt-get install -y ubuntu-desktop

USERNAME=${SSH_USER}
LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf
GDM_CUSTOM_CONFIG=/etc/gdm3/custom.conf

# Ubuntu 18.04, 20.04 and 22.04 use GDM
if [ -f $GDM_CUSTOM_CONFIG ]; then
    mkdir -p $(dirname ${GDM_CUSTOM_CONFIG})
    >$GDM_CUSTOM_CONFIG
    echo "[daemon]" >>$GDM_CUSTOM_CONFIG
    echo "# Enabling automatic login" >>$GDM_CUSTOM_CONFIG
    echo "AutomaticLoginEnable = true" >>$GDM_CUSTOM_CONFIG
    echo "AutomaticLogin = ${USERNAME}" >>$GDM_CUSTOM_CONFIG
fi

if [ -d /etc/xdg/autostart/ ]; then
    echo "==> Disabling screen blanking"
    NODPMS_CONFIG=/etc/xdg/autostart/nodpms.desktop
    echo "[Desktop Entry]" >>$NODPMS_CONFIG
    echo "Type=Application" >>$NODPMS_CONFIG
    echo "Name=nodpms" >>$NODPMS_CONFIG
    echo "Comment=" >>$NODPMS_CONFIG
    echo "Exec=xset -dpms s off s noblank s 0 0 s noexpose" >>$NODPMS_CONFIG
    echo "Hidden=false" >>$NODPMS_CONFIG
    echo "NoDisplay=false" >>$NODPMS_CONFIG
    echo "X-GNOME-Autostart-enabled=true" >>$NODPMS_CONFIG

    echo "==> Disabling screensaver"
    IDLE_DELAY_CONFIG=/etc/xdg/autostart/idle-delay.desktop
    echo "[Desktop Entry]" >>$IDLE_DELAY_CONFIG
    echo "Type=Application" >>$IDLE_DELAY_CONFIG
    echo "Name=idle-delay" >>$IDLE_DELAY_CONFIG
    echo "Comment=" >>$IDLE_DELAY_CONFIG
    echo "Exec=gsettings set org.gnome.desktop.session idle-delay 0" >>$IDLE_DELAY_CONFIG
    echo "Hidden=false" >>$IDLE_DELAY_CONFIG
    echo "NoDisplay=false" >>$IDLE_DELAY_CONFIG
    echo "X-GNOME-Autostart-enabled=true" >>$IDLE_DELAY_CONFIG

    echo "==> Add German input source and make it default"
    INPUT_SOURCE_CONFIG=/etc/xdg/autostart/input-source.desktop
    echo "[Desktop Entry]" >>$INPUT_SOURCE_CONFIG
    echo "Type=Application" >>$INPUT_SOURCE_CONFIG
    echo "Name=input-source" >>$INPUT_SOURCE_CONFIG
    echo "Comment=" >>$INPUT_SOURCE_CONFIG
    echo "Exec=gsettings set org.gnome.desktop.input-sources sources \"[('xkb', 'de'), ('xkb', 'us')]\"" >>$INPUT_SOURCE_CONFIG
    echo "Hidden=false" >>$INPUT_SOURCE_CONFIG
    echo "NoDisplay=false" >>$INPUT_SOURCE_CONFIG
    echo "AutostartCondition=unless-exists gnome-initial-setup-done" >>$INPUT_SOURCE_CONFIG
    echo "X-GNOME-Autostart-enabled=true" >>$INPUT_SOURCE_CONFIG
fi
