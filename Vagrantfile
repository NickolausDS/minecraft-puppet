Vagrant::Config.run do |config|
    config.vm.box = "debian-wheezy"
    config.vm.box_url = "http://ergonlogic.com/files/boxes/debian-current.box"
    config.vm.forward_port 80, 8080
    config.vm.forward_port 443, 8888
    config.vm.forward_port 25565, 25565


    config.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "vagrantfile.pp"
      puppet.module_path = "modules"
    end 


end
