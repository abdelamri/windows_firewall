class windows_firewall (
    $profile_state = 'on',
    $in_policy = 'BlockInbound',
    $out_policy = 'AllowOutbound',
    $networks = hiera_hash('windows_networks'),
){
    case $::operatingsystemversion {
        /(Windows Server 2008|Windows Server 2012)/: {
            $firewall_name = 'MpsSvc'

            service { 'windows_firewall':
                ensure => 'running',
                name => $firewall_name,
                enable => true,
            }->
            class { 'windows_firewall::profile':
                profile_state => $profile_state,
            }->
            class { 'windows_firewall::policy':
                in_policy => $in_policy,
                out_policy => $out_policy,
            }->
            file { "C:/ProgramData/PuppetLabs/puppet/var/files":
                ensure => directory,
            }->
            file { "C:/ProgramData/PuppetLabs/puppet/var/files/windows_firewall_cmdlt.ps1":
                ensure => present,
                source_permissions => ignore,
                source => "puppet:///modules/windows_firewall/windows_firewall_cmdlt.ps1",
            }->
            exec { 'apply_rules':
                command => template('windows_firewall/apply_rules.ps1'),
                unless => template('windows_firewall/apply_rules.ps1'),
                provider => powershell,				
            }
        }
        default: {
            notify {"${::operatingsystemversion} not supported": }
        }
    }
}