[CmdletBinding()]
param (
    [String]$Org = "lvs1code",
    [String]$Project = "CloudManagementPlatform",
    [Int]$BuildID = 1205
)

#Gets a pipeline, optionally at the specified version
#https://docs.microsoft.com/en-us/rest/api/azure/devops/build/definitions/get?view=azure-devops-rest-6.0

#Using PAT Authentication.
$PAT = $env:DevOpsPAT
$B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$PAT"))

#Build URL to be called.
$APIURL = "https://dev.azure.com/{{Org}}/{{Project}}/_apis/build/builds/{{BuildID}}?api-version=6.0"

$APIURL = $APIURL -replace "{{Org}}", $Org
$APIURL = $APIURL -replace "{{Project}}", $Project
$APIURL = $APIURL -replace "{{BuildID}}", $BuildID

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic $B64Pat")
$headers.Add("Content-Type", "application/json")

$response = Invoke-RestMethod $APIURL -Method 'GET' -Headers $headers
$response | ConvertTo-Json -Depth 5