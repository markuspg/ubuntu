Vagrant.configure("2") do |config|
  config.vm.define "ubuntu1604-desktop"
  config.vm.box = "fasmat/ubuntu1604-desktop"

  config.vm.provider :virtualbox do |v|
    v.gui = true
    v.linked_clone = true
    v.memory = 4096
    v.cpus = 4

    v.customize ["modifyvm", :id, "--vram", "256"]
    v.customize ["modifyvm", :id, "--accelerate3d", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
    v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
  end

  config.vm.provider :vmware_desktop do |v|
    v.gui = true
    v.linked_clone = true
    v.vmx["memsize"] = "4096"
    v.vmx["numvcpus"] = "4"

    v.vmx["RemoteDisplay.vnc.enabled"] = "false"
    v.vmx["RemoteDisplay.vnc.port"] = "5900"
    v.vmx["scsi0.virtualDev"] = "lsilogic"
    v.vmx["mks.enable3d"] = "TRUE"
  end
end
