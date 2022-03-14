echo off
set curdir=%~dp0
REM SET /A RandomNum=%RANDOM%
REM set stateKey=vm-%RandomNum%
rem set pathToTF=C:\temp\
Set TFDir=..\TF\EQBank_Az_LinuxVM_v1



REM File setup
set backend=%curdir%\EQBank-Dev-Backend.tfvars
set TFVars=%curdir%tfvars\Test-Acme-EQBank_Az_WindowsVM_v2.2.tfvars
rem SET /A RandomNum=%RANDOM% * 100 / 32768 + 1

Echo "Setting Terraform environment variables"
REM From https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity
REM Set ARM_USE_MSI=true
Set ARM_USE_MSI=false

REM These are AcmeAdvanture Details
Set ARM_TENANT_ID=9b0ad93b-3d88-4102-a9ae-5782b6f0a134
Set ARM_SUBSCRIPTION_ID=934265e8-fa75-4a37-8593-c07028b52dd2
Set ARM_CLIENT_ID=9b16df2d-8f44-4c45-8347-e8b1e77c4ba8
REM Set ARM_CLIENT_SECRET=Local Env Variable
REM Test Login
REM az login --service-principal -u %ARM_CLIENT_ID% -p %ARM_CLIENT_SECRET% --tenant %ARM_TENANT_ID%

%pathToTF%terraform.exe -chdir=%TFDir% apply -var-file=%TFVars%
