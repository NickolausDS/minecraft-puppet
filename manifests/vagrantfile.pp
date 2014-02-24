


exec { "apt-update":
      command => "/usr/bin/apt-get update && /bin/touch /var/lib/apt/vagrant_has_run_update",
      unless  => "/bin/ls /var/lib/apt/vagrant_has_run_update",
  }

include minecraft



# minecraft::config {'/etc/minecraft':}

minecraft::config {'/etc/minecraft':
  minecraftUsername => 'minecraft',
  minecraftPath => '/etc/minecraft',
  minecraftBackupPath => '/etc/minecraft/backup',
}
