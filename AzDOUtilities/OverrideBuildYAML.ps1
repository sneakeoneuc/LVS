[CmdletBinding()]
param (
    [String]$Org = "lvs1code",
    [String]$Project = "CloudManagementPlatform",
    [Int]$BuildDefinitionID = 52,
    [string]$EditionCode="TempValue",
    [string]$SASBlobToken="TempValue",
    [string]$BlobName="TempValue",
    [string]$ContainerName="TempValue",
    [string]$yamlOverridePath = "C:\GitRepos\CMP-LVSDE-Template\Pipelines\ParamsTest.yaml",
    [boolean]$WriteYAMLToFile = $true
)     

#Gets a pipeline, optionally at the specified version
#https://docs.microsoft.com/en-us/rest/api/azure/devops/pipelines/runs/run%20pipeline?view=azure-devops-rest-6.0

#Using PAT Authentication.
$PAT = $env:DevOpsPAT
$B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$PAT"))

#Build URL to be called.
$APIURL = "https://dev.azure.com/{{Org}}/{{Project}}/_apis/pipelines/{{BuildDefinitionID}}/runs?api-version=6.0-preview.1"

$APIURL = $APIURL -replace "{{Org}}", $Org
$APIURL = $APIURL -replace "{{Project}}", $Project
$APIURL = $APIURL -replace "{{BuildDefinitionID}}", $BuildDefinitionID

#Build headers to pass.
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic $B64Pat")
$headers.Add("Content-Type", "application/json")    

#Build the body using the template.
$pathToAzDOBodyTemplate = $PSScriptRoot + "\JSONStarters\AzDOOverrideBuildYAMLBody.json"
$AzDOBody = Get-Content -Path $pathToAzDOBodyTemplate -Raw
$AzDOBody = ConvertFrom-JSON -InputObject $AzDOBody -AsHashtable


#Get yamlOverride file
write-host $yamlOverridePath

$yamlOverrideContents = Get-Content -Path $yamlOverridePath -Raw
$yamlOverrideContents = $yamlOverrideContents -replace '"',''''

#Set Override in body
$AzDOBody.yamlOverride = $yamlOverrideContents

#Set Body which end up being parameters in the Pipeline
$TemplateParamters = $AzDOBody.templateParameters
$TemplateParamters.EditionCode = $EditionCode
$TemplateParamters.SRSASToken = $SASBlobToken
$TemplateParamters.SRBlobName = $BlobName
$TemplateParamters.SRBlobContainer = $ContainerName
$AzDOBody = convertTo-JSON -InputObject $AzDOBody -Depth 5

#Call API.
$InvokeRestError = $false
try{
    $response = Invoke-RestMethod $APIURL -Method 'POST' -Headers $headers -Body $AzDOBody
}catch {
    Write-Host "An error occurred:" -ForegroundColor Red

    write-host "$_" -ForegroundColor Red

    $InvokeRestError = $true
}

#Write return as a file so you can see it.  Gets written to the same path with filename as filename_Fullyaml.yaml.
if(-not $InvokeRestError){
    if ($WriteYAMLToFile){
        $DateTimeForFileName = (get-date).tostring("MM-dd-yyyy_hh.mm.ss")
        $yamlFile = Split-Path -Path $yamlOverridePath -Leaf
        $yamlPath = Split-Path -Path $yamlOverridePath -Parent
        $fileNameOnly = [System.IO.Path]::GetFileNameWithoutExtension($yamlFile)
        $newFileName = $fileNameOnly + "_Fullyaml ($DateTimeForFileName).yaml"
        $newFullPath = "$yamlPath\$newFileName"
        
        Set-Content -Path $newFullPath -Value $response.finalYaml
    
        write-host "YAML written to $newFullPath"
    }else{
        write-host $response.finalYaml
    }
}



