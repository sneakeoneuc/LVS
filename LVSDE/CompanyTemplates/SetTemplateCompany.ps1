[CmdletBinding()]
param (
    [String]$requestedForCompany
)  

write-host "-------Parameters-------"
foreach($boundParam in $PsBoundParameters.GetEnumerator() ){
    write-host "$($boundParam.Key) === $($boundParam.Value)"
} 
write-host "-------Parameters-------"
write-host "      "

 


Write-Host "The name company $requestedForCompany"    
Write-Host "##vso[task.setvariable variable=currentCompany;isOutput=true]$requestedForCompany"
Write-Host "Verifying path template."    

$nameTemplate = "$requestedForCompany-template.yml"
$nameTemplate = $nameTemplate.tolower().replace(" ", "")
$pathTemplate = $PSScriptRoot + "\$nameTemplate"

 


$templateExists = Test-Path -Path $pathTemplate 


If ($templateExists -eq $True) {
    Write-Host "The company's template exists. good $nameTemplate"
}
Else {
    Write-Host "The company's template doesn't exists. Will be ommited"
    }



Write-Host "##vso[task.setvariable variable=templateExists;isOutput=true]$templateExists" 
Write-Host "##vso[task.setvariable variable=pathTemplate;isOutput=true]$pathTemplate"
Write-Host "##vso[task.setvariable variable=nameTemplate;isOutput=true]$nameTemplate"
 


