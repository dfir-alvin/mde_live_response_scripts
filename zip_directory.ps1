<#
.SYNOPSIS
    Create zip file of a directory in preparation for MDE Live Response getfile
.DESCRIPTION
    Leverage PowerShell's native compression module to zip up a directory. This is to be used before the getfile command with Microsoft Defender for Endpoint (MDE) Live Response to avoid multiple getfile commands. File is saved with local timestamp and .zip extension to prevent file name conflict.

    Disclaimer
    This is a sample script and is provided without any warranty. Please test scripts within test environment before using in real incident response scenarios. The author of this script has no affiliations with Microsoft or the MDE product. 
.PARAMETERS
    -directory
    name of directory to zip
.USAGE
    zip_directory.ps1 directory "C:\Windows\Temp\Test"
.VERSION
    1.0
#>

# Input directory
Param (
[parameter(Mandatory=$true)][String]$directory
)

# Remove quotes from $directory input so variable is a usable directory
$formatted_directory_name = $directory.Replace("`"", "").Replace("`'", "")

# Test if directory exists
$check_directory = Test-Path -Path "$formatted_directory_name"

# Zip directory into new file
function create_zipped_file {

    # Zipping variables
    $input_directory = $formatted_directory_name
    $zipped_file = "C:\Windows\Temp\zip"+(Get-Date -f _yyyy.MM.dd-HH.mm.ss.K | ForEach-Object { $_ -replace ":", "." })+".zip"

    #Compress directory process
    Compress-Archive -Path $input_directory -DestinationPath $zipped_file -CompressionLevel Fastest

    # Hash newly created encrypted file
    $zipped_file_hash = Get-FileHash $zipped_file | Format-List

    # Provide hash information to user
    Write-Host "Encrypted File Information"
    Write-Output $zipped_file_hash
    }

# Main execution code
if ($check_directory -eq $true){
    create_zipped_file
    }
else {
    Write-Host "Directory does not exist. Please check directory path provided."
}