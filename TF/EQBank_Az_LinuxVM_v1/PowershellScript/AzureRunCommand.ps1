<#
.SYNOPSIS
    Run Shell Commands Remotely for Servers in Azure

.DESCRIPTION
    N/A

.EXAMPLE
    The example below shows the command so you can run the Powershell Function

    PS C:\> Run-AzureRunCommand -ResourceGroup bobprodtesting -VMName bmprodlinux2 -RunShellScripts RunShellScript -pathToScripts C:\GitRepo\CMP-LVSDE-TF-VM\TF\EQBank_Az_LinuxVM_v1\ShellScripts

.NOTES
    Author: Bob Marshall - Long View Systems.  
    Last Edit: 2021-05-15
    Version 1.0 - Initial Release
    Company: Long View Systems

#>

## Delcaring the Function name.

Function Run-AzureRunCommand {

    [cmdletbinding()]

## Defining Parameters for Function to use. All params are string in this Function but they can be: 

Param (

    [string]$ResourceGroup,
    
    [string]$VMName,

    [string]$RunShellScripts,

    [string]$pathToScripts,

    [string]$Parameters,
    
    [string]$username,

    [string]$password

    [Parameter(Mandatory)]
    [string]$subscription
)

## End of Parameters

## Creating IF Statement for TAG Paramater

if ($subscription -eq "5f3f8954-3d12-43a1-9764-3b2a15ba7891")

    {

            $TagValue = "CANC_LINUX_HUB"

    }

if ($subscription -eq "f36f2006-db98-4aab-ba10-c40685705d65")

    {

            $TagValue = "CANC_LINUX_NONPROD"

    }

if ($subscription -eq "b1de526c-8106-444b-8817-ee5d7c48600d")

    {

            $TagValue = "CANC_LINUX_PROD"

    }

if ($subscription -eq "38275a7b-9c5a-4165-af19-91834e76b5c3")

    {

            $TagValue = "CANE_LINUX_HUB"

    }

if ($subscription -eq "934265e8-fa75-4a37-8593-c07028b52dd2")

    {

            $TagValue = "CANE_LINUX_NONPROD"

    }

if ($subscription -eq "934265e8-fa75-4a37-8593-c07028b52dd2")

    {

            $TagValue = "CANE_LINUX_PROD"

    }


## Setting Parameters for Encoding in Base64

    $fileContent = [IO.File]::ReadAllText("$pathToScripts\MicrosoftDefenderATPOnboardingLinuxServer.py")

    $fileInBase64=[System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($fileContent))

## Setting Directory Path with Scripts can be local or network (I think)

    $ScriptDirectory = Get-ChildItem -Path $pathToScripts\*.sh

## Creating a ForEach Loop to run each of the scripts inside the folder.

    foreach ($Scripts in $ScriptDirectory){

## Running the command in Azure to 

    Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroup -Name $VMName -CommandId $RunShellScripts -ScriptPath $Scripts -Parameter @{"arg1" = "$($fileInBase64)" ; "arg2"= "$($TagValue)"} -Verbose

    }

}

 