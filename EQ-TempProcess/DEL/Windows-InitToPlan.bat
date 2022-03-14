echo off
rem set pathToTF=C:\temp\
set pathToTF=C:\ProgramData\chocolatey\bin\
set curdir=%~dp0
SET /A RandomNum=%RANDOM%
set stateKey=vm-%RandomNum%
Set TFDir=..\TF\EQBank_Az_WindowsVM_v2

REM File setup
set backend=%curdir%\EQBank-Dev-Backend.tfvars
set TFVars=%curdir%\EQBank_Az_WindowsVM-Sample2.tfvars
rem SET /A RandomNum=%RANDOM% * 100 / 32768 + 1

Echo "Setting Terraform environment variables"
REM From https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity
REM Set ARM_USE_MSI=true
Set ARM_USE_MSI=false

REM These are EQ Bank details Details
Set ARM_TENANT_ID=9b0ad93b-3d88-4102-a9ae-5782b6f0a134
Set ARM_SUBSCRIPTION_ID=934265e8-fa75-4a37-8593-c07028b52dd2
Set ARM_CLIENT_ID=9b16df2d-8f44-4c45-8347-e8b1e77c4ba8
REM Set ARM_CLIENT_SECRET=Local Env Variable
REM Test Login
REM az login --service-principal -u %ARM_CLIENT_ID% -p %ARM_CLIENT_SECRET% --tenant %ARM_TENANT_ID%

REM Each time script is run, it re-inits the backend.  That's not typical for Terraform, but this is for new builds every time so it works.
%pathToTF%terraform -chdir=%TFDir% init -backend-config=%backend% -backend-config="key=%stateKey%" -reconfigure
%pathToTF%terraform -chdir=%TFDir% validate
%pathToTF%terraform -chdir=%TFDir% fmt
%pathToTF%terraform -chdir=%TFDir% plan -detailed-exitcode -var-file=%TFVars%
