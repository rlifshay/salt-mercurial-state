Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provider "virtualbox" do |v|
    v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end

  config.vm.synced_folder ".", "/srv/salt/mercurial"

  config.vm.provision "salt"
  config.vm.provision "salt-local", type: "shell", inline: "sed -ri '/^#?file_client:/ c file_client: local' /etc/salt/minion"
  config.vm.provision "highstate", type: "shell", keep_color: true, inline: "salt-call --force-color state.apply mercurial --state-output changes"
end
