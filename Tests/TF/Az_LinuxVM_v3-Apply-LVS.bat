

echo off
set curdir=%~dp0
REM SET /A RandomNum=%RANDOM%
REM set stateKey=vm-%RandomNum%
Set TFDir=..\..\TF\EQBank_Az_LinuxVM_v1



REM File setup
set backend=%curdir%\LVSDE-Dev-Backend.tfvars
set TFVars=%curdir%tfvars\Test-Acme-EQBank_Az_LinuxVM_v1.1.tfvars
rem SET /A RandomNum=%RANDOM% * 100 / 32768 + 1

Echo "Setting Terraform environment variables"
REM From https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity
REM Set ARM_USE_MSI=true
Set ARM_USE_MSI=false

REM These are AcmeAdvanture Details
Set ARM_TENANT_ID=5806bd64-fde5-449f-9a07-655a9b15ae50
Set ARM_SUBSCRIPTION_ID=57215661-2f9e-482f-9334-c092e02651ec
Set ARM_CLIENT_ID=afacf60e-caee-4591-ae8c-e63140f843ca
REM Set ARM_CLIENT_SECRET=Local Env Variable
REM Test Login
REM az login --service-principal -u %ARM_CLIENT_ID% -p %ARM_CLIENT_SECRET% --tenant %ARM_TENANT_ID%

terraform -chdir=%TFDir% apply -var-file=%TFVars%
