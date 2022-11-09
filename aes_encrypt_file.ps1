<#
.SYNOPSIS
    Create encrypted version of file in preparation for live response getfile 
.DESCRIPTION
    Leverage WIndows native .NET Framework AES function (Win 8+/Server 2012+) via PowerShell to encrypt file. This is to be used before the getfile command with Microsoft Defender for Endpoint (MDE) Live Response to prevent accidental detection and execution when retrieving malware. File is saved with local timestamp and .bad extension to prevent file name conflict. Directory encryption is NOT supported. Decryption can be performed through decryption script in the same repository or via third party tools like CyberChef (UTF8 Key and IV, CBC Mode, RAW Input and Output)

    Disclaimer
    This is a sample script and is provided without any warranty. Please test scripts within test environment before using in real incident response scenarios. The author of this script has no affiliations with Microsoft or the MDE product. 
.PARAMETERS
    -file
    Name of file with full path. Use quotes if path contains space
.USAGE
    aes_encrypt_file.ps1 -file "C:\Windows\Temp\test_file.exe"
    aes_encrypt_file.ps1 "C:\Windows\Temp\test_file.exe"
.CREDIT
    Idea for using built in .NET AES function to perform encryption came from this great article on Linkedin
    "https://www.linkedin.com/pulse/encrypting-data-exfiltration-windows-part-2-dustin-noe/"
.VERSION
    1.0
#>

# Input for file name with full path
Param (
[parameter(Mandatory=$true)][String]$file
)

# Remove quotes from $file input so variable is a usable file name with path
$formatted_file_name = $file.Replace("`"", "").Replace("`'", "")

# Test if file exists
$check_file = Test-Path -Path "$formatted_file_name" -PathType Leaf

# AES encrypted file creation process
function create_encrypted_file {
    # Extract original file name to add to encrypted name
    $extracted_file_name = [System.IO.Path]::GetFileName("$formatted_file_name")

    # Encryption variables
    $key = "abcdefghijklmnopqrstuvwxyz123456" # Please change if using in production
    $iv = "0000000000000000" # Please change if using in production
    $original_file = $formatted_file_name
    $encrypted_file = "C:\Windows\Temp\"+$extracted_file_name+(Get-Date -f _yyyy.MM.dd-HH.mm.ss.K | ForEach-Object { $_ -replace ":", "." })+".bad"

    # Hash original file before creating encrypted copy
    $original_file_hash = Get-FileHash $original_file | Format-List

    # AES Encryption Function
    [byte[]] $bytes = [System.IO.File]::ReadAllBytes($original_file)
    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = [System.text.Encoding]::ASCII.GetBytes($key)
    $aes.IV = [System.text.Encoding]::ASCII.GetBytes($iv)
    $encryptor = $aes.CreateEncryptor()
    $encrypted = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length)
    [System.IO.File]::WriteAllBytes($encrypted_file, $encrypted)

    # Hash newly created encrypted file
    $encrypted_file_hash = Get-FileHash $encrypted_file | Format-List

    # Provide hash information
    Write-Host "Original File Information"
    Write-Output $original_file_hash
    Write-Host "Encrypted File Information"
    Write-Output $encrypted_file_hash
    }

# Main execution code
if ($check_file -eq $true){
    create_encrypted_file
    }
else {
    Write-Host "File does not exist. Please check path and file name."
}