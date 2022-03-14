# 	POST-BUILD ACTIVITIES & SCRIPTS - WINDOWS SPECIFIC	6	POST-BUILD ACTIVITIES & SCRIPTS - WINDOWS SPECIFIC

The following PowerShell scripts can be executed via the Azure Management Portal. Each script must be executed and can be done so by browsing to the VM within the portal and selecting "Run Command" in the left-hand nav bar, then "RunPowerShellScript" near the top of the main panel.


#### 1.1	DISABLE TLS 1.0 AND TLS 1.1 CIPHERS

Copy entire script and run in RunCommand > RunPowerShellScript (Azure Portal)
```shell
# Disable weak cyphers
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Null"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Null" -name "Enabled" -value 0 -PropertyType "Dword"

md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56" -name "Enabled" -value 0 -PropertyType "Dword"

md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128" -name "Enabled" -value 0 -PropertyType "Dword"

md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56/128"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128" -name "Enabled" -value 0 -PropertyType "Dword"

md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128" -name "Enabled" -value 0 -PropertyType "Dword"

md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128" -name "Enabled" -value 0 -PropertyType "Dword"

md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128" -name "Enabled" -value 0 -PropertyType "Dword"

md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128" -name "Enabled" -value 0 -PropertyType "Dword"

md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128" -name "Enabled" -value 0 -PropertyType "Dword"

md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168/168"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168/168" -name "Enabled" -value 0 -PropertyType "Dword"

#
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168"
New-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" -name "Enabled" -value 0 -PropertyType "Dword"

#enable 
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128/128"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128/128" -name "Enabled" -value 1 -PropertyType "Dword"

md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256"
md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256/256"
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256/256" -name "Enabled" -value 1 -PropertyType "Dword" 


```


#### 1.2	QUALYS - WINDOWS
Once the Windows VM is set up, install the Qualys agent using the commands below.

We have set up the binaries on the Azure Storage file share that can be downloaded from the VM directly, using the commands below. Note that all commands will need to be run on your new Windows server.  You will need to log in to your new server from the jump box, using the username and password that the Terraform script generated.  Launch PowerShell and run as Local Administrator.

Create the Qualys folder locally to the Server:
```bash
New-Item -Path "C:\" -Name "Qualys" -ItemType "directory" -ErrorAction SilentlyContinue
````
Download the Qualys Agent:
```bash
Invoke-WebRequest -Uri “https://azrgcnceqbnpbinst.blob.core.windows.net/qualys/QualysCloudAgent-4.0.0.411.exe?sp=racwl&st=2021-02-26T14:41:57Z&se=2022-02-27T14:41:00Z&sv=2020-02-10&sr=b&sig=4yOVdRm%2BlklDBsjIQyb%2ByTa8XHPx2Bx4EWrHx801q0o%3D”  -OutFile C:\Qualys\QualysCloudAgent.exe
```

Install & Associate with Qualys Management Console: (run in regular Windows command prompt)
```bash
Cmd
cd C:\Qualys && QualysCloudAgent.exe CustomerId={0cb7051c-fad2-fc12-8033-bda23989997f} ActivationId={00efd15a-2e57-4144-b909-27c30861a329}
```


#### 1.3	WAD (WINDOWS AZURE DIAGNOSTICS) EXTENSION

Start by copying the following files to your working folder on the jumpbx.  (Ignore the fact that the filenames reference Canada Central and NonProd; they’re used for all regions and all environments, for all Windows builds.) 

**Source: ** F:\Codes\Extensions\WindowsDiagnostic

** Destination **(Working directory - your choice):

Edit the PowerShell file as follows:
```bash
$subscription_id = '<<subscription ID>>'
Set-AzContext -Subscription $subscription_id
Connect-AzAccount

#For STORAGE ACCOUNT
$diagnosticsstorage_name = "azcnceqbseceventhub01np"
$diagnosticsstorage_key = "3zXxsTzb0iqTfGt/esa+wKsIbDgzjZd0y85ihLeNFWvm9HJRgegXkwpqt4KP2iDN17qdrEfV28P4dhqsaO56Cw=="

#JSON FILE DIAGNOSTIC PATH
$diagnosticsconfig_path = "F:\Codes\Extensions\WindowsDiagnostic\WAD-DiagnosticsPubConfig-CanadaCentral-nonPROD.json"

#RESOURCE GROUP
$vm_resourcegroup = "<EDITVM-RGNAMEHERE>"

#VM_NAME
$vm_name = "<EDITVM-NAMEHERE>"


#Deploy Extension
Set-AzVMDiagnosticsExtension -VMName $vm_name -ResourceGroupName $vm_resourcegroup -DiagnosticsConfigurationPath $diagnosticsconfig_path -StorageAccountName $diagnosticsstorage_name -StorageAccountKey $diagnosticsstorage_key
```
Run the Powershell code to install the extensions.

<br>

**check if extensions is already installed**
```bash
Get-AzVMExtension -ResourceGroupName $vm_resourcegroup -VMName $vm_name  -Name "Microsoft.Insights.VMDiagnosticsSettings"
```

**Remove extensions**
```bash
Remove-AzVMDiagnosticsExtension -ResourceGroupName $vm_resourcegroup -VMName $vm_name | Update-AzVM
```


**Confirm installation:**
1.	Check that the extension shows as installed, with “**Provisioning succeeded**”, in the Azure portal.
 
2.	Log in to your new server, and fire up PowerShell.
3.	Use the following command:
`Get-AzVMExtension -ResourceGroupName "ResourceGroup11" -VMName "VirtualMachineName"`
4.	Examine the output, which will include a list of installed extensions.  You want to see “ProvisioningState: Succeeded”.


#### 1.4	LOGICMONITOR MONITORING
1.	Create ‘lvsmon’ local user account (credentials in PasswordSafe)
2.	Add ‘lvsmon’ to local Administrator’s group
3.	Allow PING – open in powershell (administrator mode)

```bash
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" -enabled True
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv6-In)" -enabled True
```
4.	Allow WinRM - run **gpedit.msc **> (Navigate to  **Computer Configurations > Administrative Templates  > Windows Components > Windows Remote Management (WinRM) > WinRM Service >**  *Allow remote server management through WinRM*)

5.	Enable  WinRM - Winrm quickconfig (press y to enable   - or just run winrm quickconfig -quiet)

			Verify settings with - **winrm enumerate winrm/config/listener**
			
6.	Enable WM +  Defender Firewall Remote Management

```bash
Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)"
Enable-NetFirewallRule -DisplayGroup "Windows Defender Firewall Remote Management"

```
**Note:** might fail with ‘Defender’ remove and run: *Enable-NetFirewallRule -DisplayGroup "Windows Firewall Remote Management"*

7.	Restart services.

```bash
Restart-Service wmiApSrv -force
Restart-Service Winmgmt -force
Restart-Service WinRM  -force
```

**Note:** Errors may be encountered- on last 3 lines. Proceed (or manually stop and restart the services)

#### 1.5	EXPAND DISKS
Disk  encryption will encrypt the existing data only (~29GB) leaving the remaining space unallocated.
Open Computer Management (compmgmt.msc)
In Storage > Disk Management, find Disk 0 and extend volume to maximum available space (wizard driven)


