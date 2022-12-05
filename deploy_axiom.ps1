<#
.SYNOPSIS
    Create Axiom agent and exploy Axiom
.DESCRIPTION
    Leverage PowerShell to create Axiom agent from script and deploy agent.

    Disclaimer
    This is a sample script and is provided without any warranty. Please test scripts within test environment before using in real incident response scenarios. The author of this script has no affiliations with Microsoft,  the Microsoft Defender for Endpoint (MDE) product, Magent Forensics, or Magent Axiom. 
.PARAMETERS
    none
.USAGE
    deploy_axiom.ps1
.VERSION
    1.0
#>

$get_agent_status=(Get-Service -Name "AxAgent")

## Create Axiom Agent (AxAgent.exe) in Temp directory
function create_axiom_agent {
    ## Axiom Agent variables
    $axiom_agent_base64="INSERT_BASE64_AXIOM_HERE"
    $axiom_agent_file_path="C:\Windows\Temp\AxAgent.exe"

    [IO.File]::WriteAllBytes($axiom_agent_file_path, [Convert]::FromBase64String($axiom_agent_base64))
}

## Launch AxAgent.exe
function deploy_axiom_agent{
    ## Execute Axiom Agent
    cmd.exe /c C:\Windows\Temp\AxAgent.exe

    ## Print file information
    Write-Host "Axiom Agent should be deployed now, check status below for verification"
    $get_agent_status
}

# Main execution code to check the status of Axiom Agent and deploy Axiom Agent
if ($get_agent_status -eq $null) {
    create_axiom_agent;
    deploy_axiom_agent;
}
elseif ($get_agent_status.Status -ne "Running") {
    Write-Output "Starting Axiom Agent Service"
    Start-Service -Name AxAgent
}
elseif ($get_agent_status.Status -eq "Running") {
    Write-Output "Axiom Agent seems to already be running, please check "
}
