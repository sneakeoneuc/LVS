<#
    Purpose: Test the SetupLVSDE.ps1 (one of the pipeline scripts) with Az_LinuxVM_v3.
#>

Describe -Tag 'Az_LinuxVM_v3' "Run Az_LinuxVM_v3 Tests" {

    $script:EditionCode = "Az_LinuxVM_v3"
    #Test name
    $script:TestName = "LVSDE-InitialSetup ($script:EditionCode)"
  
    Context "Group:$script:EditionCode - $TestFileName" {
        BeforeAll{

            $EditionCode = "Az_LinuxVM_v3"

            #Get a list of files. 
            $PathToTests = $GlobalTestSettings["RepoRoot"] + "\Tests\DWPaServiceRequestBlobs\$EditionCode"
        
            $RequestFileNames = Get-ChildItem -Path $PathToTests -Name -Include *.json

            #Loop through the tests, and run once per file.
            $NumberOfFiles = $RequestFileNames.count
            write-host "Found $NumberOfFiles files."     

            #General Setup
            $ContainerName= $GlobalTestSettings["TestSRContainerName"]
            $DestinationFolderParent = "C:\temp"
            $DestinationFolerName = "PipelineTests"
            $DestinationFolder = "$DestinationFolderParent\$DestinationFolerName"
            $SAAccountName = $GlobalTestSettings["SAAccountName"]
            $RepoRoot = $GlobalTestSettings["RepoRoot"]
            $SSCMPCUSResourceID = $env:SSCMPCUSResourceID
            $connectionInstanceId = $GlobalTestSettings["connectionInstanceId"]

            #Set the path to the edition code Terraform
            $TFDir = "$RepoRoot\TF\$EditionCode"

            $DateFolderName = (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")
            $TFPlanOutFolder = "C:\Temp\$EditionCode\$DateFolderName"


            if (-not (Test-Path -Path $TFPlanOutFolder)){
                New-Item -ItemType Directory -Path $TFPlanOutFolder
            }
        
            Write-Host "Terraform plan output path: $TFPlanOut" -ForegroundColor Green
        }

        It "Test Terraform with different requests ($Script:TestName)" {

            foreach ($SampleSR in $RequestFileNames) {
                
                #region Setup Terraform folder.

                $BlobName = $SampleSR
                
                $BlobFilePath = $GlobalTestSettings["RepoRoot"] + "\Tests\DWPaServiceRequestBlobs\$EditionCode\$BlobName"

                if ($null -eq $BlobName){
                    throw "BlobName is null."
                }

                $BlobNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($BlobName)
                $TFOutFileName = "$EditionCode-$BlobNameWithoutExtension-TFPlan"
                $TFOutfile = "$TFPlanOutFolder\$TFOutFileName"

                write-host "Starting tests for $BlobName" -ForegroundColor Cyan
                Write-Host "Test file: $BlobFilePath"

                ClearTFState($TFDir)
                ClearAutoTFVarsJSON($TFDir)
                #endregion #######################################################################################

                #region Process Request ##########################################################################

                $SASToken = GetSASToken -SAAccountName $SAAccountName -ContainerName $ContainerName -GetContainerToken

                #Upload the test Blob from 
                $Blob = UploadFileToBlobStorage -SAAccountName $GlobalTestSettings["SAAccountName"] -ContainerName $GlobalTestSettings["TestSRContainerName"] -BlobName $BlobName -BlobFilePath $BlobFilePath

                #This is a hack for testing.  The variables get set in the $InvokeExpression script below, and then used later for the Terraform.
                #These values must match what's in dynamics.auto.tfvars.json.
                $Global:TenantID = "NOT SET"
                $Global:SPSecret = "NOT SET"
                $Global:SPAppID = "NOT SET"

                #This is the command that will be called.
                $InvokeExpression = "$RepoRoot\LVSDE\SupportingScripts\LVSDE-InitialSetup.ps1 -BlobName '$BlobName' -SASToken '$SASToken' -RepoRoot '$RepoRoot' -connectionInstanceId '$connectionInstanceId'"
        
                if (-not (Test-Path -Path $DestinationFolder)){
                    New-Item -Path $DestinationFolder -Name $DestinationFolerName -ItemType "directory"
                }

                $Output = Invoke-Expression -Command $InvokeExpression

                if ($null -eq $Output){
                    $true | Should -Be $true
                }else{
                    $Output | Should -BeOfType PSObject

                }

                #endregion #######################################################################################


                #region Terraform Init ##########################################################################

                $env:ARM_CLIENT_ID = $SPAppID
                $env:ARM_CLIENT_SECRET = $SPSecret
                $env:ARM_TENANT_ID = $TenantID

                write-host "ARM_CLIENT_ID = $env:ARM_CLIENT_ID" -ForegroundColor Green
                write-host "ARM_TENANT_ID = $env:ARM_TENANT_ID" -ForegroundColor Green

                #This is the command that will be called.
                $InvokeExpression = "terraform -chdir=$TFDir init -input=false"

                write-host "Invoking: $InvokeExpression"
                $Output = Invoke-Expression -Command $InvokeExpression
                $ExitCode = $LASTEXITCODE

                write-host "Command existed with $ExitCode"
                if ($ExitCode -ne 0){
                    write-host $output
                }

                #Exist code should be 0 if there's no problems with Init
                $ExitCode | should -be 0

                if ($null -eq $Output){
                    $true | Should -Be $true
                }else{

                    $Output | Should -BeOfType PSObject

                    #Get output by using array index: write-host $Output[0]
                }
                #endregion #######################################################################################                


                #region Terraform Plan ##########################################################################

                # $InvokeExpression = "terraform -chdir=$TFDir plan -input=false -no-color -out=$TFOutfile"
    
                # write-host "Invoking: $InvokeExpression"
                # $Output = Invoke-Expression -Command $InvokeExpression
                # $ExitCode = $LASTEXITCODE

                $TFPlanArgs = @(
                    "-chdir=$TFDir",`
                    "plan",`
                    "-input=false",`
                    "-no-color",`
                    "-out=$TFOutfile"
                )

                $Output = Start-Process -FilePath "terraform.exe" -ArgumentList $TFPlanArgs -NoNewWindow -Wait #-UseNewEnvironment
    

                $ExitCode = $LASTEXITCODE
                write-host "Command existed with $ExitCode"
                if ($ExitCode -ne 0){
                    write-host $output
                }
    
                #Exist code should be 0 if there's no problems with Init
                $ExitCode | should -be 0
    
                if ($null -eq $Output){
                    $true | Should -Be $true
                }else{
    
                    $Output | Should -BeOfType PSObject
    
                    #Get output by using array index: write-host $Output[0]
                }
                #endregion #######################################################################################                

            }
           
        }


        It "Evaluate result of terraform fmt ($Script:TestName)" {
            #This is the command that will be called.
            $InvokeExpression = "terraform fmt $TFDir"

            write-host "Invoking: $InvokeExpression"
            $Output = Invoke-Expression -Command $InvokeExpression
            $ExitCode = $LASTEXITCODE

            write-host "Command existed with $ExitCode"
            if ($ExitCode -ne 0){
                write-host $output
            }

            #Exist code should be 0 if there's no problems with Init
            $ExitCode | should -be 0

            if ($null -eq $Output){
                $true | Should -Be $true
            }else{

                $Output | Should -BeOfType PSObject

                #Get output by using array index: write-host $Output[0]
            }

        }
    }
}
