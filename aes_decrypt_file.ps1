<#
.SYNOPSIS
    Create decrypted version of file created from aes_decrypt_file.ps1
.DESCRIPTION
    Disclaimer
    This is a sample script and is provided without any warranty. Please test scripts within test environment before using in real incident response scenarios. The author of this script has no affiliations with Microsoft or the MDE product. 
.PARAMETERS
    -file
    Name of file with full path. Use quotes if path contains space
.USAGE
    "aes_decrypt_file.ps1 -file C:\Windows\Temp\test_file.bad"
    "aes_decrypt_file.ps1 C:\Windows\Temp\test_file.bad"
.VERSION
    1.0
#>

# File name with full path parameter
Param (
[parameter(Mandatory=$true)][String]$file
)

# Remove quotes from $file so variable is a usable file name with path
$formatted_file_name = $file.Replace("`"", "").Replace("`'", "")

# Test if file exists
$check_file = Test-Path -Path "$formatted_file_name" -PathType Leaf

# Extract current file directory to be used for decrypted file
$current_file_directory = [System.IO.Path]::GetDirectoryName("$formatted_file_name")

# AES decryption function
function decrypt_file {
    # Extract original file name to add to encrypted name
    $extracted_file_name = [System.IO.Path]::GetFileName("$formatted_file_name")
    $original_file_name = $extracted_file_name -replace '_.{26}\.bad',''
    $decrypted_file = $current_file_directory+"\"+$original_file_name

    # Decryption variables
    $key = "abcdefghijklmnopqrstuvwxyz123456" # Please change if using in production
    $iv = "0000000000000000" # Please change if using in production

    # AES Encryption Function
    [byte[]] $bytes = [System.IO.File]::ReadAllBytes($formatted_file_name)
    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = [System.text.Encoding]::ASCII.GetBytes($key)
    $aes.IV = [System.text.Encoding]::ASCII.GetBytes($iv)
    $decryptor = $aes.CreateDecryptor()
    $encrypted = $decryptor.TransformFinalBlock($bytes, 0, $bytes.Length)
    [System.IO.File]::WriteAllBytes($decrypted_file, $encrypted)

    # Hash newly created encrypted file
    $decrypted_file_hash = Get-FileHash $decrypted_file | Format-List

    # Provide hash information
    Write-Host "Encrypted File Information"
    Write-Output $decrypted_file_hash
    }

# Main execution code
if ($check_file -eq $true){
    decrypt_file
    }
else {
    Write-Host "File does not exist. Please check path and file name."
}
