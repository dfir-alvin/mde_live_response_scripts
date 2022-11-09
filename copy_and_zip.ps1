<#
.SYNOPSIS
    Copy file or directory direct to Temp and create zip file of copied file or directory
.DESCRIPTION
    Leverage PowerShell's native compression module to copy and zip up a file or directory. This can be used before the getfile command with Microsoft Defender for Endpoint (MDE) Live Response to avoid using multiple getfile commands manually. Copying a file/directory first can be useful for files in use by other programs. File is saved with local timestamp and .zip extension to prevent file name conflict. Supports zipping of either file or directory. 

    Disclaimer
    This is a sample script and is provided without any warranty. Please test scripts within test environment before using in real incident response scenarios. The author of this script has no affiliations with Microsoft or the MDE product. 
.PARAMETERS
    -i
    name of file or directory to zip
.USAGE
    zip.ps1 -i "C:\Windows\Temp\Test"
    zip.ps1 "C:\Windows\Temp\Test"
.VERSION
    2.0
    Renamed variables and documentation for file and directory support.

    1.0
    Initial release
#>

# Input for file or directory
Param (
[parameter(Mandatory=$true)][String]$i
)

# Remove quotes from input so variable is usable
$formatted_input_name = $i.Replace("`"", "").Replace("`'", "")

# Test if file or directory exists
$existence_check = Test-Path -Path "$formatted_input_name"

# Variables (global for multi-function usage)
$copy_directory = "C:\Windows\Temp\"

# Copy file or directory to Temp directory
function copy_to_temp{

    Copy-Item -Path $formatted_input_name -Destination $copy_directory -Recurse -Force
    }

# Zip file or directory into new file
function create_zipped_file {

    # Zipping variables
    $input_file = $copy_directory+(Split-Path -Path $formatted_input_name -Leaf)
    $zipped_file = $copy_directory+(Split-Path -Path $formatted_input_name -Leaf)+(Get-Date -f _yyyy.MM.dd-HH.mm.ss.K | ForEach-Object { $_ -replace ":", "." })+".zip"

    #Compression process
    Compress-Archive -Path $input_file -DestinationPath $zipped_file -CompressionLevel Fastest

    # Hash newly created encrypted file
    $zipped_file_hash = Get-FileHash $zipped_file | Format-List

    # Provide hash information to user
    Write-Host "Encrypted File Information"
    Write-Output $zipped_file_hash
    }

# Delete temporary copy of file or directory from Temp directory
function clean_up{

    Remove-Item -Path ($copy_directory+"\"+(Split-Path -Path $formatted_input_name -Leaf)) -Recurse -Force
    }

# Main execution code
if ($existence_check -eq $true){
    copy_to_temp;
    create_zipped_file;
    clean_up
    }
else {
    Write-Host "File or directory does not exist. Please check input path provided."
    }