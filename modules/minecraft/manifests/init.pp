#NOTE: 	Tested as of Aug 28 2013, there is a possible security risk if the minecraft user is run as root.
#The security risk comes from running java as root, it depends on how much you want to trust java :) [and minecraft]
#


class minecraft {

  # exec{'/etc/init.d/minecraft start':
  #   require => [Exec['/sbin/updateMinecraft'], File['/sbin/updateMinecraft']],
  # } 
  # 
  # 
  # exec{'/sbin/updateMinecraft':
  #   require => [File['/sbin/updateMinecraft'], File['/etc/minecraft']],
  # }
	
  # file { '/etc/minecraft':
  #   owner   => root,
  #   group   => root,
  #   ensure => directory,  
  # }
	
  # file{'/etc/init.d/minecraft':
  #     owner   => root,
  #     group   => root,
  #     mode    => 0755,
  #     ensure  => file,
  #     source  => 'puppet:///modules/minecraft/minecraft',
  #   #require => [Package['screen'], Package['openjdk-6-jre'], File['/sbin/updateMinecraft']],
  # }
  #   
  # file {'/sbin/updateMinecraft':
  #     owner   => root,
  #     group   => root,
  #     mode    => 0755,
  #     ensure  => file,
  #     source  => 'puppet:///modules/minecraft/updateMinecraft.sh',    
  # }
	
	package{ 'default-jre-headless':
		ensure	=> installed,
	}		
	
	package{ 'screen':
		ensure	=> installed,
	}
	
}