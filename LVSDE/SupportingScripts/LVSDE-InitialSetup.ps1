[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String] $BlobName,
    [Parameter(Mandatory=$true)]
    [string] $SASToken,
    [Parameter(Mandatory=$true)]
    [string] $RepoRoot,
    [Parameter(Mandatory=$true)]
    [String] $connectionInstanceId
)

#If Env AGENT_NAME is set, then the script is running in an Azure Pipeline.  The Az module is preloaded at a path.  See link below
#https://github.com/actions/virtual-environments/blob/main/images/win/Windows2019-Readme.md#azure-powershell-modules
if ($null -ne $env:AGENT_NAME){
    $env:PSModulePath = "$env:PSModulePath;C:\Modules\az_5.5.0"
}

Import-Module -name Az

#region Functions

write-host "Loading functions..."

function Get-TargetAzCredentials {
    param ([String] $Company,
    [String] $DefaultAzContext,
    [String] $SSCMPCUSResourceID)
  
    $CredentialsSet = $null

    #Get the company passed in from the requestedFor object.

    $lookupValue = $company.Replace(" ","-")
    $lookupValue = $lookupValue -replace "[^a-zA-Z0-9-]",""
    write-host "Using $company ($LookupValue) to lookup credentials."

    Get-AzContext -Name $DefaultAzContext | Select-AzContext

    $SSCUSKV = $SSCMPCUSResourceID
    $SSCUS = Get-AzResource -ResourceId $SSCUSKV

    $KVName = $SSCUS.Name
    write-host "Using $KVName for secrets."

    $StoredValue = Get-AzKeyVaultSecret -VaultName $KVName -Name $LookupValue -AsPlainText
    
    $StoredValue = ConvertFrom-JSON -InputObject $StoredValue

    #Set values for easy use later.  Using $Global scope because it makes testing way easier.
    $Global:TenantID = $StoredValue.Credential.TenantID
    $Global:SPAppID = $StoredValue.Credential.SPAppID
    $Global:SPSecret = $StoredValue.Credential.SPSecret

    #Make the details available to other processes.
    write-host "##vso[task.setvariable variable=ARM_TENANT_ID;issecret=true]$TenantID"
    write-host "##vso[task.setvariable variable=ARM_CLIENT_ID;issecret=true]$SPAppID"
    write-host "##vso[task.setvariable variable=ARM_CLIENT_SECRET;issecret=true]$SPSecret"

    $CredentialsSet = $StoredValue
       
    return $CredentialsSet
}

function Get-EditionCodeMapping {
    param (
        [Parameter(Mandatory=$true)]
        [String]$PathToMappingFile,
        [Parameter(Mandatory=$true)]
        [String]$EditionCode    
    )

    #Read the edition code to mapping file.
    $pathToDescriptor = $PathToMappingFile
    $FileContents = Get-Content -Path $pathToDescriptor -Raw
    $Mapping = ConvertFrom-JSON -InputObject $FileContents -AsHashtable

    $return = $Mapping[$EditionCode]

    if ($null -eq $return){
        write-host "Edition Code: $EditionCode"
        Write-Host "Path to mapping file: $PathToMappingFile"

        throw "Edition Code mapping not found."
    }

    return $return
}

function Get-EnvironmentSettings {
    param (
        [Parameter(Mandatory=$true)]
        [String]$PathToMappingFile,
        [Parameter(Mandatory=$true)]
        [String]$connectionInstanceId    
    )

    #Read the edition code to mapping file.
    $FileContents = Get-Content -Path $PathToMappingFile -Raw
    $Mapping = ConvertFrom-JSON -InputObject $FileContents -AsHashtable

    $return = $Mapping[$connectionInstanceId]

    if ($null -eq $return){
        write-host "DWPa Connection Instance ID: $connectionInstanceId"
        Write-Host "Path to mapping file: $PathToMappingFile"

        throw "Connection Instance ID not found."
    }

    return $return
}

function Update-DynamicVars {
    param (
        [Parameter(Mandatory=$true)]
        [String]$PathToDynamicVars,
        [Parameter(Mandatory=$true)]
        [Hashtable]$ValuesToUpdate    
    )

    $ValuesUpdated = 0
    $JSONDepth = 10

    $TempDynamicTFVars = Get-Content -Path $PathToDynamicTFVars -raw
    $DynamicTFVars = ConvertFrom-Json -InputObject $TempDynamicTFVars -AsHashtable -Depth $JSONDepth

    #The key should be the variable name.
    foreach ($VarName in $ValuesToUpdate.Keys) {

        #Do not add anything that's not already there because the TF will just fail.
        #Overwrite values in Dynamic TF Vars file (currently a hashtable).
        if ($DynamicTFVars.ContainsKey($VarName)){
            $DynamicTFVars[$VarName] = $ValuesToUpdate[$VarName]
            $ValuesUpdated += 1
        }else{
            write-host "WARNING: $VarName has not been updated.  All values to be updated need to exist in the Dynamic TF Vars file.  None are added." -BackgroundColor Yellow
        }
    }

    $DynamicTFVars = ConvertTo-Json -InputObject $DynamicTFVars -Depth $JSONDepth
    Out-file -FilePath $PathToDynamicTFVars -InputObject $DynamicTFVars -Force

    return $ValuesUpdated

}

function Get-DataDiskDatails {
     param (
        [Parameter(Mandatory=$true)]
        [Hashtable]$DiskType,
        [Parameter(Mandatory=$true)]
        [Hashtable]$DiskSize    
    )
    

    $ValuesDisk =  @{}
    $lunID = 10

    For ($i=1; $i -le $DiskType.Count; $i++) {
        $typeKey = "datadisk_type_"+$i
        $typeValue = $null
        $sizeKey = "datadisk_size_"+$i
        $sizeValue = $null

        $ValuesDiskObj = @{}
      
        if($DiskType.ContainsKey($typeKey)){

            $typeValue = $DiskType.$typeKey

            switch ($typeValue) {
                0  { $typeValue = 'Premium_LRS'}
                10 { $typeValue = 'Standard_LRS'}
                20 { $typeValue = 'StandardSSD_LRS'}
            }

            $typeKey = "managed_disk_type"
            
        }
        if($DiskSize.ContainsKey($sizeKey)){
            $sizeValue = $DiskSize.$sizeKey
            $sizeKey = "disk_size_gb"
        }
        
        if($null -ne $typeValue) {
            $ValuesDiskObj.Add("lunID", $lunID)
            $ValuesDiskObj.Add($typeKey, $typeValue)
            $ValuesDiskObj.Add($sizeKey, $sizeValue)
            $keyLundId = $lunID.tostring()
            $ValuesDisk.Add($keyLundId,$ValuesDiskObj)
            $lunID++ 
        }
    }
     
    return $ValuesDisk
}
#endregion

#region SetupEnvironmentSetting
#Load environment settings
if ($null -eq $connectionInstanceId){
    throw "An connectionInstanceId (Environment) is required to get settings."
}

$PathToEnvSettings = "$RepoRoot\LVSDE\SupportingScripts\JSONStarters\EnvironmentSettings.json"

#Get Environment from file.  If it does not exist, throw an error.
$EnvSettings = Get-EnvironmentSettings -PathToMappingFile $PathToEnvSettings -connectionInstanceId $connectionInstanceId

#Set environment values
$StorageAccountName = $EnvSettings.StorageAccountName
$ContainerName = $EnvSettings.ContainerName
$SSCMPCUSResourceID = $EnvSettings.SSCMPCUSResourceID
$AzDOServiceConnection = $EnvSettings.AzDOServiceConnection
$KeyVaultName = $EnvSettings.KeyVaultName

#The Pipeline variable names are different then the script values for same information.
#Set SR_SA_Name (Pipeline Variable)
Write-Host "##vso[task.setvariable variable=SR_SA_Name;]$StorageAccountName"

#Set SRBlobContainer (Pipeline Variable)
Write-Host "##vso[task.setvariable variable=SRBlobContainer;]$ContainerName"

#Set SSCMPCUSResourceID (Pipeline Variable)
Write-Host "##vso[task.setvariable variable=SSCMPCUSResourceID;]$SSCMPCUSResourceID"

#Set ServiceConnectionName (Pipeline Variable)
Write-Host "##vso[task.setvariable variable=ServiceConnectionName;]$AzDOServiceConnection"

#endregion

#region Service Request (Blob) handling
#Make sure the folder to put the blob in exists.
if (-not (Test-Path -Path $RepoRoot)){
    throw "The required destination foler does not exist.  Required Path: $RepoRoot"
}

write-host "Starting Service Request (Blob) handling..."

#Gathering information TAP
$tokenAPI= Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'SSCMPDWPaPAT' -AsPlainText

#Set Personal Access Token (TAP)
Write-Host "##vso[task.setvariable variable=TAPToken;isOutput=true;issecret=true]$tokenAPI"


#Setup Storage context

$AzRQStorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -SasToken $SASToken

#Get Blob.
# write-host "StorageAccountName = $StorageAccountName"
# write-host "SASToken = $SASToken"
# write-host "ContainerName = $ContainerName"
# write-host "BlobName = $BlobName"
# write-host "RepoRoot = $RepoRoot"
$BlobObj = Get-AzStorageBlobContent -Context $AzRQStorageContext -Container $ContainerName -blob $BlobName -Destination $RepoRoot -Force

#Validate Service Request schema
$FileContent = Get-Content -Path "$RepoRoot\$BlobName" -Raw
$SchemaFilePath = "$PSScriptRoot\JSONSchemas\DWPaVMRequestSchema.json"

write-host "Validating file contents against schema: $SchemaFilePath"
if (Test-Json -Json $FileContent -SchemaFile $SchemaFilePath){
    write-host "Valid Service Request downloaded."
}else{
    throw "Invalid Service Request downloaded."
}

#Make $SR an object useable in Powershell.
$SR = ConvertFrom-Json -InputObject $FileContent -AsHashtable -Depth 100

#endregion

#region Handle PipelineParameters
 
#Add sensitive variable names to this array so they do not get logged.
$SecureVariableNames = @("adminPassword")

$ValuesToUpdate = @{}
#Set Pipeline paramters.  The write-host command makes them available for other processes to consume.
$PipelineParams = $SR.inputs.PipelineParameters.inputs

if ($null -ne $PipelineParams){
    $DataDisksType = @{}
    $DataDisksSize = @{}
    foreach ($param in $PipelineParams) {
        $VarName = $param.key
        $VarValue = $param.value
        
        if($VarName -match "datadisk_type_"){  

            $DataDisksType.Add($VarName, $VarValue)

        }elseif($VarName -match "datadisk_size_"){

            $DataDisksSize.Add($VarName, $VarValue)

        }else{

            $ValuesToUpdate.Add($VarName, $VarValue)
        }
        
        #$ValuesToUpdate += @{$VarName = $VarValue}
        
        if ($VarName -In $SecureVariableNames){
            Write-Host "##vso[task.setvariable variable=$VarName;issecret=true]$VarValue"
        }else{
            Write-Host "##vso[task.setvariable variable=$VarName;]$VarValue"
        }
    }
   
    if( ($DataDisksType.Count -ne 0) -and ($DataDisksSize.Count -ne 0)){
        $DataDiskDatails = Get-DataDiskDatails -DiskType $DataDisksType -DiskSize $DataDisksSize
        $ValuesToUpdate.Add("data_disk_details", $DataDiskDatails)
    }
    

}else{
    throw "The pipeline parameters are null."
}

#endregion

#Sample $targetSubscription = "/subscriptions/57215661-2f9e-482f-9334-c092e02651ec"
$TargetSubscription = $ValuesToUpdate["subscription_id"]
if ($TargetSubscription.split("/").Length -gt 1){
    $TargetSubscription = $TargetSubscription.split("/")[2]
    write-host "##vso[task.setvariable variable=ARM_SUBSCRIPTION_ID;]$TargetSubscription"
    $ValuesToUpdate["subscription_id"] = $TargetSubscription
}

#region Get Target Credentials

#Get requested for company out of SR.
$requestedForCompany = $SR.inputs.ServiceContext.requestedFor.company
$env:requestedForCompany
if ($null -ne $requestedForCompany){
    Write-Host "##vso[task.setvariable variable=requestedForCompany;isOutput=true;]$requestedForCompany"          

}else{
    throw "The RequestedFor Company cannot be null."
}

# #Get requested for company out of SR.
$SRId = $SR.inputs.ServiceContext.serviceRequest.id
if ($null -ne $SRId){
    Write-Host "##vso[task.setvariable variable=SRId;isOutput=true;]$SRId"          
    $ValuesToUpdate["SRId"] = $SRId
}else{
    throw "The RequestedFor Company cannot be null."
}

#Context gets added to other context. Have to make sure it's the Customer context.
$AzContext = Get-AzContext
$DefaultAzContext = $AzContext.name
$TargetCredentials = Get-TargetAzCredentials -Company $requestedForCompany -DefaultAzContext $DefaultAzContext -SSCMPCUSResourceID $SSCMPCUSResourceID -SubID $TargetSubscription

if ($null -eq $TargetCredentials){
    throw "Credentials for $requestedForCompany have not been set correctly."
}

#endregion

#Set Pipeline paramters.  The write-host command makes them available for other processes to consume.
$EditionCode = $SR.inputs.EditionCode
if ($null -ne $EditionCode){
    Write-Host "##vso[task.setvariable variable=EditionCode;]$EditionCode"
}else{
    throw "The Edition Code cannot be null."
}

#region Setup Terraform

#Get the path to the Terraform folder.
$PathToMappingFile = "$PSScriptRoot/JSONStarters/EditionCodeToTFTemplateMapping.json"
$EditionCodeValues = Get-EditionCodeMapping -PathToMappingFile $PathToMappingFile -EditionCode $EditionCode
$TF_Directory = $EditionCodeValues.TF_Directory

#Set the full path to be used through the script.
$TF_Directory = "$RepoRoot\TF\$TF_Directory"

if (Test-Path -Path $TF_Directory -PathType Container){
    write-host "The path to the Terraform directory has been verified."

    write-host "##vso[task.setvariable variable=TF_Directory;]$TF_Directory"

}else{
    throw "The path to the Terraform directory does not exist.  Path: $TF_Directory"
}

#Copy default settings into dynamic.auto.tfvars.json.  All variables shold be set in this file.
$PathToDefaultTFVars = "$TF_Directory\vars\default.auto.tfvars.json"
$PathToDynamicTFVars = "$TF_Directory\dynamic.auto.tfvars.json"

if (Test-Path -Path $PathToDefaultTFVars -PathType Leaf){
    write-host "The path to the default set of values has been verified.  Path: $PathToDefaultTFVars"

    Copy-Item -path $PathToDefaultTFVars -Destination $PathToDynamicTFVars -Force

    Write-Host "##vso[task.setvariable variable=PathToDynamicTFVars;]$PathToDynamicTFVars"

}else{
    throw "The path to the default set of values does not exist.  Path: $PathToDefaultTFVars"
}

#Terraform configuration to reduce output in pipeline.
write-host "##vso[task.setvariable variable=TF_IN_AUTOMATION;]RunningInAutomation"

#endregion

#Region Set variables in dynamic.auto.tfvars.json

#add other stuff that needs to be updated
$ValuesToUpdate["tenant_id"] = $TargetCredentials.Credential.TenantID
$ValuesToUpdate["subscription_id"] = $TargetSubscription

$ValuesUpdatedCount = Update-DynamicVars -PathToDynamicVars $PathToDynamicTFVars -ValuesToUpdate $ValuesToUpdate

write-host "Updated $ValuesUpdatedCount dynamic variable values."

#endregion

#Region Subscription defaults
# Copy subscriptionid.auto.tfvars.json into $TF_Directory
# Terraform loads "Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames."
#   - See Variable Definition Precedence -> https://www.terraform.io/docs/language/values/variables.html#variable-definition-precedence
$PathToSubIDTFVars = "$TF_Directory\vars\SubIDs\$TargetSubscription.auto.tfvars.json"
$PathToSubIDTFVarsDest = "$TF_Directory\SubID.auto.tfvars.json"

if (Test-Path -Path $PathToSubIDTFVars -PathType Leaf){
    write-host "The path to the settings for $TargetSubscription been verified.  Path: $PathToSubIDTFVars"
    write-host "Terraform processes any *.auto.tfvars.json files in lexical order of their filenames.  SubID.auto.tfvars.json should be processed after dynamic.auto.tfvars.json."

    Copy-Item -path $PathToSubIDTFVars -Destination $PathToSubIDTFVarsDest -Force

    Write-Host "##vso[task.setvariable variable=PathToSubIDTFVarsDest;]$PathToSubIDTFVarsDest"

}else{
    write-host "The path to the settings for $TargetSubscription was not found. There are no defaults set for this subscription.  Path: $PathToSubIDTFVars"
}