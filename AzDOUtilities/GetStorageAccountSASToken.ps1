[CmdletBinding()]
param (
    [String]$SAAccountName = "saservicerequestsdev01",
    [string]$ContainerName = "servicerequests",
    [string]$BlobName = "10721.json"
)  

$AzSAContext = New-AzStorageContext -ConnectionString $env:SRStorageAccountConnection

$CurrentUTCTime = [DateTime]::UtcNow

$expiryTime = $CurrentUTCTime.AddHours(12)
$SASBlobToken = New-AzStorageBlobSASToken -Protocol HttpsOnly -Context $AzSAContext -Container $ContainerName -Blob $BlobName -ExpiryTime $expiryTime -Permission "rw"


$SASBlobToken

#New-AzStorageBlobSASToken -Protocol HttpsOnly -Context $AzSAContext -Container $ContainerName -Blob $BlobName -Permission "rwd"


