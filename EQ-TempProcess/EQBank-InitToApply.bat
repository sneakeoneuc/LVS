echo off
REM Get current directory in a more readable format.
set curdir=%~dp0

REM EDIT HERE #1
REM Set path to Terraform v14.8
set pathToTF=C:\ProgramData\chocolatey\bin\

REM EDIT HERE #2
REM Enter the VM name.  It is used to as part of the state file name.  The vm_name should also be defined in the tfvars file.
set vm_name=VM-01

REM EDIT HERE #3
REM Set the tfvars file.
set TFVars=%curdir%\EQBank_Az_WindowsVM-Sample2.tfvars

REM EDIT HERE #4
REM Set the ARM_SUBSCRIPTION_ID for Terraform Login.  Must match tfvars file.
Set ARM_SUBSCRIPTION_ID=f36f2006-db98-4aab-ba10-c40685705d65

REM EDIT HERE #5
REM Set the path to the Terraform directory.  
REM WIndows = ..\TF\EQBank_Az_WindowsVM_v2
REM Linux = ..\TF\EQBank_Az_LinuxVM_v1
Set TFDir=..\TF\EQBank_Az_WindowsVM_v2



REM Set the statekey to VM-Name + random number key.
SET /A RandomNum=%RANDOM%
set stateKey=%vm_name%-%RandomNum%

REM Backend setup using Azure Provider: Authenticating using a Service Principal with a Client Secret
REM https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
set backend=%curdir%\EQBank-Dev-Backend.tfvars

Echo "Setting Terraform environment variables"
REM From https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity
REM Set ARM_USE_MSI=true
Set ARM_USE_MSI=false

REM These are EQ Bank details Details
Set ARM_TENANT_ID=9b0ad93b-3d88-4102-a9ae-5782b6f0a134
REM Set ARM_SUBSCRIPTION_ID=f36f2006-db98-4aab-ba10-c40685705d65
Set ARM_CLIENT_ID=15cbaede-237d-46ab-a9a6-b119eb6a86ba
REM Set ARM_CLIENT_SECRET=Local Env Variable
REM Test Login
REM az login --service-principal -u %ARM_CLIENT_ID% -p %ARM_CLIENT_SECRET% --tenant %ARM_TENANT_ID%

REM Each time script is run, it re-inits the backend.  That's not typical for Terraform, but this is for new builds every time so it works.
%pathToTF%terraform.exe -chdir=%TFDir% init -backend-config=%backend% -backend-config="key=%stateKey%" -reconfigure
REM %pathToTF%terraform.exe -chdir=%TFDir% validate
REM %pathToTF%terraform.exe -chdir=%TFDir% fmt
REM %pathToTF%terraform.exe -chdir=%TFDir% plan -detailed-exitcode -var-file=%TFVars%
%pathToTF%terraform.exe -chdir=%TFDir% apply -var-file=%TFVars%