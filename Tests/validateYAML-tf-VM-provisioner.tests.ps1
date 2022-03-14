<#
    Purpose: Submit the YAML file to the API, and write the returned results to the location where it was read from.  
    .gitignore excludes .testoutput.yaml, whcih is the extension added by ValidateBuildYAML.
#>


Describe -Tag 'validateYAML' 'tf-VM-provisioner.yaml Pipeline Tests' {
    Context "Group:ValidateYAML" {
        BeforeAll {
            #Setup generic test configuration.
            $EditionCode = "Az_LinuxVM_v3"
            $BlobName = "Az_LinuxVM_v3__Long-View__base.1.json"
            $MaxRunTimInMinutes = 10     
            $PathToYAMLSource = "$PSScriptRoot\..\LVSDE\tf-VM-provisioner.yaml"       
            write-host "Starting Pipeline Tests for $EditionCode"

            $PathToMappingFile = $PSScriptRoot + "\JSONStarters\EditionCodeToBuildDef.json"
            $EditionCodeValues = Get-EditionCodeMapping -PathToMappingFile $PathToMappingFile -EditionCode $EditionCode
    
            #Setup values for calling pipeline.
            $Org = $EditionCodeValues.Organization
            $Project = $EditionCodeValues.Project
            $BuildDefinitionID = $EditionCodeValues.BuildDefinitionID
    
            write-host "Org: $Org; Project: $Project; Build definition ID: $BuildDefinitionID"               

            $BlobFilePath = $PSScriptRoot + "\DWPaServiceRequestBlobs\$EditionCode\$BlobName"

            #Upload the test Blob from 
            $Blob = UploadFileToBlobStorage -SAAccountName $GlobalTestSettings["SAAccountName"] -ContainerName $GlobalTestSettings["TestSRContainerName"] -BlobName $BlobName -BlobFilePath $BlobFilePath

            $BytesWritten = $Blob.Length
            $BlobName = $Blob.Name

            write-host "$BytesWritten written to $BlobName."

            $SASBlobToken = GetSASToken -SAAccountName $GlobalTestSettings["SAAccountName"] -ContainerName $GlobalTestSettings["TestSRContainerName"] -BlobName $BlobName

            $IsYAMLValid = ValidateBuildYAML -Org $Org -Project $Project -BuildDefinitionID $BuildDefinitionID -EditionCode $EditionCode -SASBlobToken $SASBlobToken -BlobName $BlobName -ContainerName $GlobalTestSettings["TestSRContainerName"] -yamlOverridePath $PathToYAMLSource -WriteYAMLToFile $True

        }

        It "YAML should be valid." {
            $IsYAMLValid | Should -be $true
        }
    }
}

    



