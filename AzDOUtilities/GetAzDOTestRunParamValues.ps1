#Setup generic test configuration.
$EditionCode = "Az_LinuxVM_v3"
$BlobName = "12213.json"
$SAAccountName = "sasrvreqdwpacmpdev01"
$TestSRContainerName = "servicerequests" 

#Upload the test Blob from 

function GetSASToken {
    param (
        [String]$SAAccountName,
        [string]$ContainerName,
        [string]$BlobName
    )  
  
    $AzSAContext = New-AzStorageContext -ConnectionString $env:SRStorageAccountConnection
  
    $CurrentUTCTime = [DateTime]::UtcNow
    $expiryTime = $CurrentUTCTime.AddHours(12)
    $SASBlobToken = New-AzStorageBlobSASToken -Protocol HttpsOnly -Context $AzSAContext -Container $ContainerName -Blob $BlobName -ExpiryTime $expiryTime -Permission "rw"
  
    return $SASBlobToken
  }

$SASBlobToken = GetSASToken -SAAccountName $SAAccountName -ContainerName $TestSRContainerName -BlobName $BlobName

write-host ""
write-host "Edition Code: $EditionCode"
write-host ""
write-host "SAS Token Code: $SASBlobToken"
write-host ""
write-host "Blob Name: $BlobName"
write-host ""
write-host "Test SR Container Name: $TestSRContainerName"
write-host ""