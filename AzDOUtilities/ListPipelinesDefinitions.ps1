[CmdletBinding()]
param (
    [String]$Org = "lvs1code",
    [String]$Project = "CloudManagementPlatform"
)

#Example of listing available Pipelines
#https://docs.microsoft.com/en-us/rest/api/azure/devops/pipelines/pipelines/list?view=azure-devops-rest-6.0

#Using PAT Authentication.
$PAT = $env:DevOpsPAT
$B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$PAT"))

#Build URL to be called.
$APIURL = "https://dev.azure.com/{{Org}}/{{Project}}/_apis/pipelines?api-version=6.0-preview.1"

$APIURL = $APIURL -replace "{{Org}}", $Org
$APIURL = $APIURL -replace "{{Project}}", $Project
$APIURL = $APIURL -replace "{{BuildDefinitionID}}", $BuildDefinitionID

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic $B64Pat")

$response = Invoke-RestMethod $APIURL -Method 'GET' -Headers $headers
$response | ConvertTo-Json -Depth 5