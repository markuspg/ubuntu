
Vagrant.configure("2") do |config|
    config.vm.define "vagrant-ubuntu1404-desktop"
    config.vm.box = "ubuntu1404-desktop"
 
    config.vm.provider :virtualbox do |v, override|
        v.gui = true
        v.customize ["modifyvm", :id, "--name", "Boxcutter Ubuntu 14.04"]
        v.customize ["modifyvm", :id, "--memory", 2048]
        v.customize ["modifyvm", :id, "--cpus", Etc.nprocessors]
        v.customize ["modifyvm", :id, "--vram", "256"]
        v.customize ["modifyvm", :id, "--accelerate3d", "on"]
        v.customize ["modifyvm", :id, "--ioapic", "on"]
        v.customize ["modifyvm", :id, "--rtcuseutc", "on"]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end

    ["vmware_fusion", "vmware_workstation"].each do |provider|
      config.vm.provider provider do |v, override|
        v.gui = true
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "1"
        v.vmx["cpuid.coresPerSocket"] = "1"
        v.vmx["RemoteDisplay.vnc.enabled"] = "false"
        v.vmx["RemoteDisplay.vnc.port"] = "5900"
        v.vmx["scsi0.virtualDev"] = "lsilogic"
        v.vmx["mks.enable3d"] = "TRUE"
      end
    end
end
