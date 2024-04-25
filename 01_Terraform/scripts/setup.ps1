# Test-WSMan

$Zertifikat = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -KeyAlgorithm RSA -KeyLength 4096 -CertStoreLocation "Cert:\LocalMachine\My" -FriendlyName "WinRM Zertifikat zur Verwaltung via Ansible"

$Thumbprint = $Zertifikat.Thumbprint
$WinRM_Port = 5986

winrm quickconfig -q -force

$WinRmHttps = "@{Hostname=`"$env:COMPUTERNAME`";CertificateThumbprint=`"$Thumbprint`"}"
winrm create winrm/config/Listener?Address=*+Transport=HTTPS $WinRmHttps

#####################################
## https://www.visualstudiogeeks.com/devops/how-to-configure-winrm-for-https-manually
## https://docs.vmware.com/en/vRealize-Orchestrator/8.11/com.vmware.vrealize.orchestrator-use-plugins.doc/GUID-2F7DA33F-E427-4B22-8946-03793C05A097.html
# winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="host_name";CertificateThumbprint="certificate_thumbprint"}

Enable-WSManCredSSP -Role Server -Force

# Open Firewall Ports
New-NetFirewallRule -Display 'GH-Windows Remote Management (HTTPS-In)' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $WinRM_Port