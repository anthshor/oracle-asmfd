vm_name = "whister.zoomer"
vm_disk_data = 1
vm_disk_fra = 1
Vagrant.configure(2) do |config|
  vm_disk = vm_disk_data+vm_disk_fra
  config.vm.box = "anthshor/ol6-oracledb"
  config.vm.hostname = vm_name
  config.vm.synced_folder "~/proxy", "/proxy"
  config.vm.network "private_network", ip: "192.168.33.11" 
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '4096']
    vb.name=vm_name
    (1..vm_disk).each do |i|
      disk="asmdisk#{i}.vdi"
      port=i
      vb.customize ['createhd', '--filename', disk, '--size', '5128'] unless File.exists?(disk)
      vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', port, '--device', '0', '--type', 'hdd', '--medium', disk]
    end
  end
  config.vm.provision "shell",  path: "install_grid.sh"
  config.vm.provision "shell",  path: "provision_asm.sh"
  config.vm.provision "shell",  path: "install_db.sh"
  config.vm.provision "shell",  path: "provision_db.sh"
  config.vm.provision "shell",  path: "create_db.sh"
end
