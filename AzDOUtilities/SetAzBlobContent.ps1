[CmdletBinding()]
param (
    [String]$SAAccountName = "saservicerequestsdev01",
    [string]$ContainerName = "servicerequests",
    [string]$BlobName = "TempFile.json",
    [string]$BlobFileContent = "Smaple content"
)  

$AzSAContext = New-AzStorageContext -ConnectionString $env:SRStorageAccountConnection

$TempFile = New-TemporaryFile
Set-Content -Path $TempFile -Value $BlobFileContent

$SRBlob = Set-AzStorageBlobContent -Context $AzSAContext -File $TempFile -Blob $BlobName -Container $ContainerName

$Length = $SRBlob.Length
$BlobName = $SRBlob.Name

write-host "$Length bytes written to $BlobName"




