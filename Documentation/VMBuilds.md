# 1	BUILD A VM
## 1.1	CREATE YOUR WORKSPACE  
1.	Log in to Checkpoint VPN. The instructions are in the OurClients portal, at:
OurClients > Equitable Bank > Managed Services Library > Access Instruction 
2.	RDP in to the Terraform Jumpbox with your own credentials.
3.	A Shared Repo has been created. [ PCI-Bank-VM-builds](https://github.com/sneakeoneuc/PCI-Bank-VM-builds.git " PCI-Bank-VM-builds")
4.	Launch Visual Studio Code (Install it if not already present)
5.	To Clone the repository - Do the following:
a.	Once open, press `CTRL + Shift + P`
b.	Search for `Git Clone`
c.	Paste the URL from above



## 1.2	EDIT SCRIPTS
VM Requests will come in as tickets (INC###)
Current expectation is to complete builds and QA process, and hand VMs over to requestors, within 8 business hours.
Within the INC, a VM Request Form will be submitted with VM requirements.

Edit the following files as needed with relevant info from the Request Form.
1.	EQBank-InitToPlan.bat
2.	EQBank-Apply.bat
3.	tfvars Sample file - (copy required OStype sample file then rename copy as needed)

**Working folder:** C:\GitRepo\CMP-LVSDE-TF-VM\EQ-TempProcess

## 1.3	RUN TERRAFORM
Once the files are in your working folder, edited, and saved, open terminal. 


1.	Navigate to your working folder that contains your tfvars files 
2.	Run EQBank-InitToPlan.bat (**Note:** Inspect code carefully for destroy or changes)
3.	Run EQBank-Apply.bat (**Note:** Inspect code carefully for destroy or changes)
4.	If ok, type yes when prompted

VM will now be built.
Once built you can test login through the VPN and Jump box.
Search for your new VM in the Azure portal:
Try logging in to your new VM from the jumpbox.  Use SSH for Linux, or RDP for Windows.

**Important!** Do not commit changes.
After your VM is deployed, navigate to Source Control and discard changes


------------

# 2	ENVIRONMENT PATH SETUP:
#### (ONE TIME SETUP required for each engineer/technician)
On the Build VM, setup the following user environment paths (credentials in PasswordSafe)

1.	In **Control Panel**, search for and then select: **System**
2.	Click the **Advanced system** settings link. (click** yes** if any UAC windows popup)
3.	Click **Environment Variables**.
4.	Below the section ***User Variables*** for..  click **New.**
5.	Add Variable called **ARM_CLIENT_SECRET**
6.	Click **OK**. 
7.	Create another Variable called **ARM_SAS_TOKEN**
8.	Click **OK**.
9.	Close all remaining windows by clicking **OK**.




# 2.1	TERRAFORM INSTALL AND SETUP
All steps and instructions in this section are here for reference purposes only.  They have already been performed as a one-time action by the architects, and we do not anticipate needing to perform them again, unless there is some significant overall of EQ Bank Azure environment.

**Note:** The following has been configured on the build box
terraform.exe version 14.9 has been placed in the Path.  This should only be done once. (**placed in  C:\Temp**)
**Terraform Download link:** https://www.terraform.io/downloads.html

Now set the path environment variable in windows to use it from the command prompt and PowerShell:
1.	Under Control Panel (Ensure you select all) -> System -> Advanced System Settings:
2.	Under the Advanced tab select Environment Variables, select **Path** under system variables. Add the path to where you placed the terraform.exe.

Once done, start a new cmd or powershell prompt and ensure you can run terraform.




# 3	CIS MARKET PLACE ACCEPTANCE
CIS Marketplace images will be used for all Windows and Linux builds that are required by EQ. To use the CIS image for a subscription it needs to be accepted. You can do this from both the Azure Portal and command line.

**Command Line Option:**
Login to Azure cli:
`az login --use-device-code`
Set the subscription:
`set --subscription=”Enter subscription ID Here”`
Locate the CIS image you want to use:
Windows:
`az vm image list -f Windows -l canadacentral -p center-for-internet-security-inc --all`
Linux:
`az vm image list -f CentOS -l canadacentral -p center-for-internet-security-inc --all`

This will output a list of images.

Ensure your subscription is set for PowerShell:
`Select-AzSubscription -subscriptionid "Enter subscription ID Here"a

Accept the CIS version you want:
Example:
`Get-AzMarketplaceTerms -Publisher "center-for-internet-security-inc" -Product "cis-windows-server-2016-v1-0-0-l2" -name "cis-ws2016-l2" | Set-AzMarketplaceTerms –Accept`

**Note:** If you get cmdlet errors ensure you import the Az module following the instructions below into your powershell, and ensure you also install the Azure CLI:
https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-2.7.0

