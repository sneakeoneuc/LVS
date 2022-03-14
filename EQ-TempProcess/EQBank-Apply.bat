echo off
REM Get current directory in a more readable format.
set curdir=%~dp0

REM EDIT HERE #1
REM Set path to Terraform v14.8
set pathToTF=C:\temp\

REM EDIT HERE #2
REM Enter the VM name.  It is used to as part of the state file name.  The vm_name should also be defined in the tfvars file.
set vm_name=azvm143it01

REM EDIT HERE #3
REM Set the tfvars file.
set TFVars=%curdir%\EQBank_Az_WindowsVM-azvm143it01.tfvars

REM EDIT HERE #4
REM Set the ARM_SUBSCRIPTION_ID for Terraform Login.  Must match tfvars file.
Set ARM_SUBSCRIPTION_ID=c82c18dc-6080-4480-992b-f6544b5789af

REM EDIT HERE #5
REM Set the path to the Terraform directory.  
REM WIndows = ..\TF\EQBank_Az_WindowsVM_v2
REM Linux = ..\TF\EQBank_Az_LinuxVM_v1
Set TFDir=..\TF\Az_WindowsVM_v3



Echo "Setting Terraform environment variables"
REM From https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity
REM Set ARM_USE_MSI=true
Set ARM_USE_MSI=false

REM These are AcmeAdvanture Details
Set ARM_TENANT_ID=8ce6cd64-f1d8-43f8-a8be-9de82f375ee9
REM Set ARM_SUBSCRIPTION_ID=c82c18dc-6080-4480-992b-f6544b5789af
Set ARM_CLIENT_ID=c82c18dc-6080-4480-992b-f6544b5789af
REM Set ARM_CLIENT_SECRET=Local Env Variable
REM Set /P ARM_CLIENT_SECRET=Set the local secret:
REM Test Login
REM az login --service-principal -u %ARM_CLIENT_ID% -p %ARM_CLIENT_SECRET% --tenant %ARM_TENANT_ID%

%pathToTF%terraform.exe -chdir=%TFDir% apply -var-file=%TFVars%
