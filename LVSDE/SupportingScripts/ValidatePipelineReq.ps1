[CmdletBinding()]
param (
    [String] $SupportedEditionCodes,
    [String] $ActualEditionCodes
)

$EditionCodes = $SupportedEditionCodes.Split(",")

if ($PSVersionTable.PSVersion.Major -ne 7){
    throw "Powershell must be version 7."
}

if ($PSVersionTable.PSEdition -ne "Core"){
    throw "Powershell edition must be Core"
}

#write-host  $EditionCodes[0].GetType() 
if ($EditionCodes[0].GetType() -eq "System.String"){
    throw "Error splitting edition codes."
}else{
    Write-Host "This pipeline supports the following codes:"
    foreach ($code in $EditionCodes) {
        Write-Host $code
    }

    if ($EditionCodes.Contains($ActualEditionCodes)){
        write-host "$ActualEditionCodes supported."
    }else {
        throw "Edition code:$ActualEditionCodes is not supported."
    }
}
