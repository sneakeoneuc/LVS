Param([string[]]$ExcludeTags,
[switch]$Run_Az_LinuxVM_v3_Tests,
[switch]$Run_Az_WindowsVM_v3_Tests
)

#Tags can be used to exclude tests.  The tag needs to be defined on the test.
# Sample tags: Az_LinuxVM_v3','RunPipeline','Params_Test_v2','ScriptTest'
#Global valaues


if ($Run_Az_LinuxVM_v3_Tests){
    $ExcludeTags = @('Az_WindowsVM_v3', 'Params_Test_v2', 'validateYAML')
    #write-host "Excluding tests tagged with $ExcludeTags."
}elseif ($Run_Az_WindowsVM_v3_Tests){
    $ExcludeTags = @('Az_LinuxVM_v3', 'Params_Test_v2', 'validateYAML')
}

if ($null -ne $ExcludeTags){
    write-host "Excluding tests tagged with $ExcludeTags."
}else{
    write-host "Running all tests."
}

$global:GlobalTestSettings = @{
    SAAccountName = "SETBELOW" #"sasrvreqdwpacmpdev01"
    TestSRContainerName = "servicerequests" 
    RepoRoot = "$PSScriptRoot\.."
    connectionInstanceId = "DEV"
}

if ($null -eq (Get-InstalledModule -Name "Pester" -MinimumVersion 5.0 -ErrorAction SilentlyContinue)) {

    Install-Module -Name Pester -force

    if ($null -eq (Get-InstalledModule -Name "Pester" -MinimumVersion 5.0 -ErrorAction SilentlyContinue)){
        throw "Pester version 5.0 or greater required."
    }

}else{
    Write-Host "Pester module found.  Starting tests."
    
    #PAT required.
    $global:PAT = $env:DevOpsPAT

    if ($null -eq $PAT){
        throw "PAT required to test running Pipelines."
    }

    if ($null -eq $env:SRStorageAccountConnection){
        throw "ENV:SRStorageAccountConnection required to connecto to Storage Account.  Set environment variable locally.  Connection string can be pulled from Storage Account."
    }else{
        $AzSAContext = New-AzStorageContext -ConnectionString $env:SRStorageAccountConnection
        $GlobalTestSettings["SAAccountName"] = $AzSAContext.StorageAccountName

        $SAAccountName = $GlobalTestSettings["SAAccountName"]

        write-host "Using Storage Account: $SAAccountName"

    }

    if ($null -eq $env:SSCMPCUSResourceID){
        throw "ENV:SSCMPCUSResourceID required to get credentials.  It should be set to the Resource ID of kv-SSCMPCUS-Dev-01 Key Vault."
    }else{
        #Write a warning if testing locally, and not signed in with LVS ID.  Causes errors.
        $AzContext = Get-AzContext
        $LocalTenantID = $AzContext.Tenant.Id

        if (($LocalTenantID -ne 'fd6fb306-2acd-4fae-a721-c8f5714b622e')){
            write-host "WARNING: Not signed into LVS tenant.  Can cause errors because debugger runs as local account.  Run Connect-AzAccount -Tenant 'fd6fb306-2acd-4fae-a721-c8f5714b622e'.  Current Tenant: $LocalTenantID"  -ForegroundColor Black -BackgroundColor Yellow
        }

        #This is to test if local Azure account is logged in and useable.
        $TestAccess = Get-AzResource -ResourceId $env:SSCMPCUSResourceID -ErrorAction Stop
    }

    # if ($null -eq $env:ARM_CLIENT_ID){
    #     write-host "Use this command to test 'az login --service-principal -u %ARM_CLIENT_ID% -p %ARM_CLIENT_SECRET% --tenant %ARM_TENANT_ID%'" -ForegroundColor yellow
    #     throw "ENV:%ARM_CLIENT_ID% required to test Terraform."
    # }elseif($null -eq $env:ARM_CLIENT_SECRET){
    #     write-host "Use this command to test 'az login --service-principal -u %ARM_CLIENT_ID% -p %ARM_CLIENT_SECRET% --tenant %ARM_TENANT_ID%'" -ForegroundColor yellow
    #     throw "ENV:%ARM_CLIENT_ID% required to test Terraform."
    # }elseif($null -eq $env:ARM_TENANT_ID) {
    #     write-host "Use this command to test 'az login --service-principal -u %ARM_CLIENT_ID% -p %ARM_CLIENT_SECRET% --tenant %ARM_TENANT_ID%'" -ForegroundColor yellow
    #     throw "ENV:%ARM_TENANT_ID% required to test Terraform."
    # }

    #Load functions
    . "./SetupFunctions.ps1"  

    #Do the work
    Invoke-Pester $PSScriptRoot -ExcludeTagFilter $ExcludeTags #-Output Detailed
}

