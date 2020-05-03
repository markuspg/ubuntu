#!/bin/bash -eux

SSH_USERNAME=${SSH_USERNAME:-vagrant}

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
    echo "==> Installing Open VM Tools"
    apt-get install -y open-vm-tools open-vm-tools-desktop

    # Add /mnt/hgfs so the mount works automatically with Vagrant
    mkdir /mnt/hgfs
fi
