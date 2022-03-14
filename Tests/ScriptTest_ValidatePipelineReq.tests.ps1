<#
    Purpose: Test the ValidatePipelineReq.ps1 (one of the pipeline scripts) with Az_LinuxVM_v3.
#>

Describe -Tag 'ScriptTest','ValidatePipelineReq','Az_LinuxVM_v3' 'ValidatePipelineReq.ps1 with Az_LinuxVM_v3' {

    #Test name
    $script:TestName = "ValidatePipelineReq"

    Context "Group:ValidatePipelineReq" {
        BeforeAll{
            $RepoRoot = $GlobalTestSettings["RepoRoot"]
            #This is the command that will be called.
            $InvokeExpression = "$RepoRoot\LVSDE\SupportingScripts\ValidatePipelineReq.ps1 -SupportedEditionCodes 'TestCode1,TestCode2,Az_LinuxVM_v3' -ActualEditionCodes 'TestCode2'"

            write-host "Invoking: $InvokeExpression"
            $Output = Invoke-Expression -Command $InvokeExpression
        }

        It "Output should be null or a PSObject ($Script:TestName)" {
            if ($null -eq $Output){
                $true | Should -Be $true
            }else{
                $Output | Should -BeOfType PSObject

                #Get output by using array index: write-host $Output[0]
            }
           
        }
        
    }
}
Describe -Tag 'ScriptTest','ValidatePipelineReq','Az_WindowsVM_v3' 'ValidatePipelineReq.ps1 with Az_WindowsVM_v3' {

    #Test name
    $script:TestName = "ValidatePipelineReq"

    Context "Group:ValidatePipelineReq" {
        BeforeAll{
            $RepoRoot = $GlobalTestSettings["RepoRoot"]
            #This is the command that will be called.
            $InvokeExpression = "$RepoRoot\LVSDE\SupportingScripts\ValidatePipelineReq.ps1 -SupportedEditionCodes 'TestCode1,TestCode2,Az_WindowsVM_v3' -ActualEditionCodes 'TestCode2'"

            write-host "Invoking: $InvokeExpression"
            $Output = Invoke-Expression -Command $InvokeExpression
        }

        It "Output should be null or a PSObject ($Script:TestName)" {
            if ($null -eq $Output){
                $true | Should -Be $true
            }else{
                $Output | Should -BeOfType PSObject

                #Get output by using array index: write-host $Output[0]
            }
           
        }
        
    }
}

    



