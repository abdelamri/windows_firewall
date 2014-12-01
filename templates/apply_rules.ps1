#Import-Module "C:\ProgramData\PuppetLabs\puppet\var\files\windows_firewall_cmdlt.ps1"
$PuppetRules = @()

#Apply rules
<% @networks.sort.each do |key, network| -%>
    <%- if network['ensure'] == "present" -%>
        Ensure-PuppetFirewallRulePresent -Rule (Build-PuppetFirewallRule -Name '<%= key %>')
        $PuppetRules += '<%= key %>'
	<%- else -%>
        Ensure-PuppetFirewallRuleAbsent -Rule (Build-PuppetFirewallRule -Name '<%= key %>')
	<%- end -%>
<% end -%>

#Disable system rules not in puppet
Disable-SystemFirewallRule -PuppetRules $PuppetRules