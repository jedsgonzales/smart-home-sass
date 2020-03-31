# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  #config.vm.box = "ubuntu/trusty64"
  config.vm.box = "ubuntu/xenial64"
  #config.vm.box = "ubuntu/zesty64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 3035, host: 3035
  config.vm.network "forwarded_port", guest: 3306, host: 3306

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.42"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.synced_folder ".", "/home/vagrant/code"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
	vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = "1536"
    vb.cpus = 2
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.ssh.insert_key = false
  config.ssh.private_key_path = ["vagrant/vagrant", "D:/Vagrant/insecure_private_key"]
  config.vm.provision "file", source: "./vagrant/vagrant.pub", destination: "~/.ssh/authorized_keys"

  config.vm.provision "shell", inline: <<-SHELL
	  sudo sed -i -e "\\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
	  sudo service ssh restart

    sudo apt-get update
    sudo apt-get install -y curl zlib1g-dev liblzma-dev libgmp-dev libxslt-dev libxml2-dev patch
    sudo apt-get install -y software-properties-common build-essential libgmp-dev python-software-properties
    sudo apt-get install -y libcurl4-openssl-dev ruby-dev mysql-client libmysqlclient-dev nodejs

    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

    sudo apt-get install -y nodejs

    # ---------------------------------------
    #          PostGreSQL Setup
    # ---------------------------------------
    sudo apt install postgresql postgresql-contrib libpq-dev

    # create postgres role and password
    psql -c "create role root with createdb login password 'vagrant'"
    psql -d "app_test" -c "CREATE EXTENSION IF NOT EXISTS 'pgcrypto'"
    psql -d "app_development" -c "CREATE EXTENSION IF NOT EXISTS 'pgcrypto'"

    # ---------------------------------------
    #          MySQL Setup
    # ---------------------------------------

    # Setting MySQL root user password root/root
    # debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
    # debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'

    # Installing packages
    # apt-get install -y mysql-server mysql-client

    # Allow External Connections on your MySQL Service
    # sudo sed -i -e 's/bind-addres/#bind-address/g' /etc/mysql/mysql.conf.d/mysqld.cnf
    # sudo sed -i -e 's/skip-external-locking/#skip-external-locking/g' /etc/mysql/mysql.conf.d/mysqld.cnf
    # mysql -u root -pvagrant -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'vagrant'; FLUSH privileges;"
    # sudo service mysql restart
    # create client database
    # mysql -u root -pvagrant -e "CREATE DATABASE app_development;"
    # mysql -u root -pvagrant -e "CREATE DATABASE app_test;"

    # export DEBIAN_FRONTEND=noninteractive
    # MYSQL_ROOT_PASSWORD='?'
    # echo debconf mysql-server/root_password password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections
    # echo debconf mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections
    # sudo apt-get install -y mysql-server > /dev/null

    sudo apt-add-repository -y ppa:rael-gc/rvm
    sudo apt-get update
    sudo apt-get install -y rvm
    sudo usermod -a -G rvm vagrant
    source /etc/profile.d/rvm.sh
    rvm requirements
    rvm install 2.6.3
    rvm use 2.6.3
    rvm gemset create code
    rvm use ruby-2.6.3@code --default
    gem install bundler
    gem install passenger
    gem install execjs

    npm install -g yarn
  SHELL
end
