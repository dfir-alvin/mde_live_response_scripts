<#
.SYNOPSIS
    Copy direct to temp and create zip file of copied directory in preparation for MDE Live Response getfile
.DESCRIPTION
    Leverage PowerShell's native copy module and compression module to zip up a directory. This is to be used before the getfile command with Microsoft Defender for Endpoint (MDE) Live Response to avoid multiple getfile commands. File is saved with local timestamp and .zip extension to prevent file name conflict.

    Disclaimer
    This is a sample script and is provided without any warranty. Please test scripts within test environment before using in real incident response scenarios. The author of this script has no affiliations with Microsoft or the MDE product. 
.PARAMETERS
    -directory
    name of directory to zip
.USAGE
    copy_and_zip_directory.ps1 directory "C:\Windows\Temp\Test"
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

# copy_directory variables (global for multi-function usage)
$copy_directory = "C:\Windows\Temp\"

# Copy directory to Temp directory
function copy_to_temp{

    Copy-Item -Path $formatted_directory_name -Destination $copy_directory -Force
}

# Zip directory into new file
function create_zipped_file {

    # Zipping variables
    $input_directory = $formatted_directory_name
    $zipped_file = $copy_directory+(Get-Date -f _yyyy.MM.dd-HH.mm.ss.K | ForEach-Object { $_ -replace ":", "." })+".zip"

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
    copy_to_temp
    create_zipped_file
    }
else {
    Write-Host "Directory does not exist. Please check directory path provided."
}