[CmdletBinding()]
param (
    [String][Parameter (Mandatory = $true)] $Org = "lvs1code",
    [String][Parameter (Mandatory = $true)] $Project = "CloudManagementPlatform",
    [Int][Parameter (Mandatory = $true)]    $PipeLineId = 156,     
    [Int][Parameter (Mandatory = $true)]    $PipeLineVersion = 1,  
    [String][Parameter (Mandatory = $true)] $RefName = "dev-test",
    [String][Parameter (Mandatory = $true)] $CompanyName ,
    [String][Parameter (Mandatory = $true)] $NameTemplate ,
    [String][Parameter (Mandatory = $true)] $Msg,
    [String][Parameter (Mandatory = $true)] $PersonalToken

)

write-host "-------"
foreach($boundParam in $PsBoundParameters.GetEnumerator() ){
    write-host "$($boundParam.Key) = $($boundParam.Value)"
}
write-host "-------"
write-host "      "

#Runs a pipeline
#https://docs.microsoft.com/en-us/rest/api/azure/devops/pipelines/runs/run-pipeline?view=azure-devops-rest-6.0#request-body

   
$B64Pat=[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$PersonalToken"))

#Build URL to be called.
$APIURL = "https://dev.azure.com/{{organization}}/{{project}}/_apis/pipelines/{{pipelineId}}/runs?pipelineVersion={{pipelineVersion}}&api-version=6.0-preview.1"

$APIURL = $APIURL -replace "{{organization}}", $Org
$APIURL = $APIURL -replace "{{project}}", $Project 
$APIURL = $APIURL -replace "{{pipelineId}}", $PipeLineId
$APIURL = $APIURL -replace "{{pipelineVersion}}", $PipeLineVersion

$jsonRequest = @{}


$bodyResources= @{
    "repositories" = @{
        "self" =@{
            "refName"= $RefName
        }
    }
}
$bodyParameteres= @{ }
 
    
$bodyParameteres.Add("companyName",$CompanyName)
$bodyParameteres.Add("nameTemplate",$NameTemplate)
$bodyParameteres.Add("msg",$Msg)



$jsonRequest.Add("resources",$bodyResources)
$jsonRequest.Add("templateParameters",$bodyParameteres)
 


$definitionJson = $($jsonRequest | ConvertTo-Json -Depth 10)

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic $B64Pat")
$headers.Add("Content-Type", "application/json")

Invoke-RestMethod -Uri $APIURL -Method POST  -Headers $headers  `
    -ContentType "application/json" `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($definitionJson)) 
