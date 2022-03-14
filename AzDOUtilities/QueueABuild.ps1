[CmdletBinding()]
param (
    [String]$Org = "lvs1code",
    [String]$Project = "CloudManagementPlatform",
    [Int]$BuildDefinitionID = 52,
    [string]$EditionCode="TempValue",
    [string]$SASBlobToken="TempValue",
    [string]$BlobName="TempValue",
    [string]$ContainerName="TempValue"
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
$pathToAzDOBodyTemplate = $PSScriptRoot + "\JSONStarters\AzDOQueueBody.json"
$AzDOBody = Get-Content -Path $pathToAzDOBodyTemplate -Raw
$AzDOBody = ConvertFrom-JSON -InputObject $AzDOBody -AsHashtable

#Set Body which end up being parameters in the Pipeline
$TemplateParamters = $AzDOBody.templateParameters
$TemplateParamters.EditionCode = $EditionCode
$TemplateParamters.SRSASToken = $SASBlobToken
$TemplateParamters.SRBlobName = $BlobName
$TemplateParamters.SRBlobContainer = $ContainerName
$AzDOBody = convertTo-JSON -InputObject $AzDOBody -Depth 5


$response = Invoke-RestMethod $APIURL -Method 'POST' -Headers $headers -Body $AzDOBody
$response | ConvertTo-Json -Depth 5