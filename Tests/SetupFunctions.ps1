function New-AzDORun {
    param (
      [Parameter(Mandatory=$true)]
      [String]$Org,
      [Parameter(Mandatory=$true)]
      [String]$Project,
      [Parameter(Mandatory=$true)]
      [String]$BuildDefinitionID,        
      [Parameter(Mandatory=$true)]
      [String]$Body,
      [Parameter(Mandatory=$true)]
      [String]$PAT  
    )
    
      #Convert PAT to Base64String.
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
      
      #$Body = convertTo-JSON -InputObject $Body -Depth 5
  
      #write-host "Function Body:"
      #write-host $Body
      #write-host $APIURL
      #write-host $PAT
      #Call URL

      $response = Invoke-RestMethod $APIURL -Method 'POST' -Headers $headers -Body $Body
      
      return $Response

    }

function Get-PipelineRequestBodies {
    param ([String] $RequestBodiesFolder)

    $TestPath = $PSScriptRoot +"\$RequestBodiesFolder"

    $ReqBodies = @{}

    Get-ChildItem $TestPath -Filter *.json | 

    Foreach-Object {
        
        $content = Get-Content -Raw $_.FullName
        $ReqBodies[$_.Name] = $content

    }
    
    if ($ReqBodies.count -eq 0){
        throw "Tests are required for $RequestBodiesFolder."
    }

    return $ReqBodies
}

function GetSASToken {
  param (
      [String]$SAAccountName,
      [string]$ContainerName,
      [string]$BlobName = "",
      [Switch]$GetContainerToken = $false
  )  

  $AzSAContext = New-AzStorageContext -ConnectionString $env:SRStorageAccountConnection

  $CurrentUTCTime = [DateTime]::UtcNow
  $expiryTime = $CurrentUTCTime.AddHours(12)
  if($GetContainerToken){
    $SASBlobToken = New-AzStorageContainerSASToken -Protocol HttpsOnly -Context $AzSAContext -Container $ContainerName -ExpiryTime $expiryTime -Permission "rw"
  }else{
    $SASBlobToken = New-AzStorageBlobSASToken -Protocol HttpsOnly -Context $AzSAContext -Container $ContainerName -Blob $BlobName -ExpiryTime $expiryTime -Permission "rw"
  }
  
  return $SASBlobToken
}

function ClearTFState {
  [CmdletBinding()]
  param (
      [String]$FolderPath
  )

  $FileExt = (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")

  #Delete files and folders related to TFSTate.
  $Path = "$FolderPath\.terraform"
  if (Test-Path -Path $path){
    Remove-Item -LiteralPath $Path -Force -Recurse
  }

  $Path = "$FolderPath\.terraform.lock.hcl"
  if (Test-Path -Path $path){
    Remove-Item -LiteralPath $Path -Force
  }

  $Path = "$FolderPath\terraform.tfstate.backup"
  if (Test-Path -Path $path){
    Rename-Item -Path $Path -NewName "terraform.tfstate.backup.$FileExt" -Force
  }

  $Path = "$FolderPath\terraform.tfstate"
  if (Test-Path -Path $path){
    Rename-Item -Path $Path -NewName "terraform.tfstate.$FileExt" -Force
  }

}

function ClearAutoTFVarsJSON {
  [CmdletBinding()]
  param (
      [String]$FolderPath
  )

  $FileExt = (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")

  #Delete files and folders related to TFSTate.
  $Path = "$FolderPath\dynamic.auto.tfvars.json"
  if (Test-Path -Path $path){
    Remove-Item -LiteralPath $Path -Force -Recurse
  }

  $Path = "$FolderPath\SubID.auto.tfvars.json"
  if (Test-Path -Path $path){
    Remove-Item -LiteralPath $Path -Force
  }
}

function UploadFileToBlobStorage {
  param (
      [String]$SAAccountName,
      [string]$ContainerName,
      [string]$BlobName,
      [string]$BlobFilePath
  )  

  $AzSAContext = New-AzStorageContext -ConnectionString $env:SRStorageAccountConnection

  #$TempFile = New-TemporaryFile
  #Set-Content -Path $TempFile -Value $BlobFileContent

  $SRBlob = Set-AzStorageBlobContent -Context $AzSAContext -File $BlobFilePath -Blob $BlobName -Container $ContainerName -Force

  return $SRBlob
}

function Get-EditionCodeMapping {
  param (
    [Parameter(Mandatory=$true)]
    [String]$PathToMappingFile,
    [Parameter(Mandatory=$true)]
    [String]$EditionCode    
  )
  
  #Read the edition code to mapping file.
  $pathToDescriptor = $PathToMappingFile
  $FileContents = Get-Content -Path $pathToDescriptor -Raw
  $Mapping = ConvertFrom-JSON -InputObject $FileContents -AsHashtable

  $return = $Mapping[$EditionCode]

  return $return
}

function Get-BuildByID {
  param (
    [Parameter(Mandatory=$true)]
    [String]$Org,
    [Parameter(Mandatory=$true)]
    [String]$Project,
    [Parameter(Mandatory=$true)]
    [String]$BuildID,        
    [Parameter(Mandatory=$true)]
    [String]$PAT  
  )

  #Gets a pipeline, optionally at the specified version
  #https://docs.microsoft.com/en-us/rest/api/azure/devops/build/definitions/get?view=azure-devops-rest-6.0

  #Using PAT Authentication.
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

  return $response
  
}

function ValidateBuildYAML {
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
  $YAMLIsValid = $false
  try{
      $response = Invoke-RestMethod $APIURL -Method 'POST' -Headers $headers -Body $AzDOBody
      $YAMLIsValid = $true
  }catch {
      Write-Host "An error occurred:" -ForegroundColor Red

      write-host "$_" -ForegroundColor Red


  }

  #Write return as a file so you can see it.  Gets written to the same path with filename as filename_Fullyaml.yaml.
  if($YAMLIsValid){
      if ($WriteYAMLToFile){
          $DateTimeForFileName = (get-date).tostring("MM-dd-yyyy_hh.mm.ss")
          $yamlFile = Split-Path -Path $yamlOverridePath -Leaf
          $yamlPath = Split-Path -Path $yamlOverridePath -Parent
          $fileNameOnly = [System.IO.Path]::GetFileNameWithoutExtension($yamlFile)
          $newFileName = $fileNameOnly + "($DateTimeForFileName).testoutput.yaml"
          $newFullPath = "$yamlPath\$newFileName"
          
          Set-Content -Path $newFullPath -Value $response.finalYaml
      
          write-host "YAML written to $newFullPath"
      }else{
          write-host $response.finalYaml
      }
  }

  return $YAMLIsValid
 
}