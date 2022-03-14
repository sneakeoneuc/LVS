echo off
REM Get current directory in a more readable format.
set curdir=%~dp0

REM Enter the VM name.  It is used to as part of the state file name.  The vm_name should also be defined in the tfvars.json file.
set vm_name=VM-2222

REM EDIT HERE #3
REM Set the tfvars file.
set TFVars=%curdir%tfvars.json\Test-Acme-Az_LinuxVM_v3.1.tfvars.json

REM EDIT HERE #4
REM Set the ARM_SUBSCRIPTION_ID for Terraform Login.  Must match tfvars file.
Set ARM_SUBSCRIPTION_ID=57215661-2f9e-482f-9334-c092e02651ec

REM EDIT HERE #5
REM Set the path to the Terraform directory.  
REM WIndows = ..\TF\EQBank_Az_WindowsVM_v2
REM Linux = ..\TF\EQBank_Az_LinuxVM_v1
Set TFDir=..\..\TF\EQBank_Az_LinuxVM_v1

REM Set the statekey to VM-Name + random number key.
SET /A RandomNum=%RANDOM%
set stateKey=%vm_name%-%RandomNum%

REM Backend setup using Azure Provider: Authenticating using a Service Principal with a Client Secret
REM https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
set backend=%curdir%\..\..\TF\Backends\LVSDE-Dev-Backend.tfvars

Echo "Setting Terraform environment variables"
REM From https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity
REM Set ARM_USE_MSI=true
Set ARM_USE_MSI=false

REM These are AcmeAdvanture Details
Set ARM_TENANT_ID=5806bd64-fde5-449f-9a07-655a9b15ae50
REM Set ARM_SUBSCRIPTION_ID=57215661-2f9e-482f-9334-c092e02651ec
Set ARM_CLIENT_ID=afacf60e-caee-4591-ae8c-e63140f843ca
REM Set ARM_CLIENT_SECRET=Local Env Variable
REM Test Login
REM az login --service-principal -u %ARM_CLIENT_ID% -p %ARM_CLIENT_SECRET% --tenant %ARM_TENANT_ID%

REM Each time script is run, it re-inits the backend.  That's not typical for Terraform, but this is for new builds every time so it works.
REM %pathToTF%terraform.exe -chdir=%TFDir% init -backend-config=%backend% -backend-config="key=%stateKey%" -reconfigure
%pathToTF%terraform.exe -chdir=%TFDir% init
%pathToTF%terraform.exe -chdir=%TFDir% validate
%pathToTF%terraform.exe -chdir=%TFDir% fmt
%pathToTF%terraform.exe -chdir=%TFDir% plan -detailed-exitcode -var-file=%TFVars%