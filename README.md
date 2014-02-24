##Puppet Minecraft

A friendly puppet module for Minecraft on Debian Linux!

###Testing on Vagrant

Assuming [vagrant](http://vagrantup.com), [Virtualbox](http://virtualbox.com), and [Puppet](https://downloads.puppetlabs.com/puppet/) are installed, it should be as easy as:

	git clone git@github.com:NickolausDS/minecraft-puppet.git
	cd minecraft-puppet.git
	vagrant up
	
It may take a while to set everything up. Not only does vagrant need to download a [basebox](http://www.vagrantbox.es/), puppet needs to install the java module, which is pretty big.

If everything worked correctly, you should be able to connect to your Minecraft server! Fire up Minecraft, and connect to "localhost"

###Deploying with Puppet

Deploying on a puppet server should be very straight forward. Simply drop the module among your other puppet modules, and include it in your main manifest. See the vagrantfile.pp for configuration instructions. 

