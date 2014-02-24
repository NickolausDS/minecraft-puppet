

define minecraft::config (
  $minecraftInitScriptName= "minecraft",
  $minecraftUsername= "minecraft",
  $minecraftPath="/etc/minecraft",
  $minecraftBackupPath="$minecraftPath/backup") {
    
    exec{"/etc/init.d/$minecraftInitScriptName start":
  		require	=> [Package['default-jre-headless'], Package['screen'], Exec['/sbin/updateMinecraft'], File['/sbin/updateMinecraft'], File["$minecraftPath"]],
  	  onlyif  => "/etc/init.d/$minecraftInitScriptName status | grep 'not running'"
  	}


    exec{'/sbin/updateMinecraft':
      require => [File['/sbin/updateMinecraft'], File['/etc/minecraft']],
    }
    
    user {"$minecraftUsername":
  		ensure 		=> 'present',
  	}
    
    file {"$minecraftPath":
  	owner	=> "$minecraftUsername",
  	group	=> "$minecraftUsername",
  	mode 	=> '0644',
  	ensure  => directory,
  	require => User["$minecraftUsername"],
    }
    
    file {"$minecraftBackupPath":
  	owner	=> "$minecraftUsername",
  	group	=> "$minecraftUsername",
  	mode 	=> '0644',
  	ensure  => directory,
  	require => File["$minecraftPath"],
    }
    
    file {'/sbin/updateMinecraft':
  	    owner   => root,
  	   	group   => root,
  	    mode    => 0755,
  	    ensure  => file,
  	    source  => 'puppet:///modules/minecraft/updateMinecraft.sh',		
  	}
    
    file {"/etc/init.d/$minecraftInitScriptName":
    content => template('minecraft/minecraft.erb'),
    owner	=> "root",
  	group	=> "root",
  	mode 	=> '0755',
    }
  }