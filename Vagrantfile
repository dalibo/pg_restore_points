Vagrant.configure("2") do |config|

    # Configuration pour la VM Debian
    config.vm.define "debian" do |debian|
      debian.vm.box = "generic/debian12"  # Utilise Debian 11 Bullseye
      debian.vm.hostname = "debian-vm"
      debian.vm.network "private_network", type: "dhcp"
      debian.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 2
      end
  
      # Partage NFS de ./ vers /app
      debian.vm.synced_folder "./", "/app", type: "nfs", nfs_version: 4, nfs_udp: false
  
      debian.vm.provision "shell", inline: <<-SHELL
        apt update
        apt install -y build-essential
      SHELL
    end
  
    # Configuration pour la VM Rocky Linux 9
    config.vm.define "rocky9" do |rocky|
      rocky.vm.box = "generic/rocky9"  # Utilise Rocky Linux 9
      rocky.vm.hostname = "rocky-vm"
      rocky.vm.network "private_network", type: "dhcp"
      rocky.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 2
      end
  
      # Partage NFS de ./ vers /app
      rocky.vm.synced_folder "./", "/app", type: "nfs", nfs_version: 4, nfs_udp: false
  
      rocky.vm.provision "shell", inline: <<-SHELL
        dnf update -y
        dnf groupinstall -y "Development Tools"
      SHELL
    end
  
  end
  