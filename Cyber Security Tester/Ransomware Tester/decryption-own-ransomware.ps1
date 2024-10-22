# Fungsi untuk mendekripsi file
function Decrypt-File {
    param (
        [string]$EncryptedFilePath,
        [byte[]]$AesKey,
        [byte[]]$AesIV
    )

    # Baca isi file terenkripsi
    $EncryptedBytes = [System.IO.File]::ReadAllBytes($EncryptedFilePath)

    # Buat objek AES
    $Aes = [System.Security.Cryptography.Aes]::Create()
    $Aes.Key = $AesKey
    $Aes.IV = $AesIV

    # Decryptor
    $Decryptor = $Aes.CreateDecryptor()

    # Proses dekripsi
    $DecryptedBytes = $Decryptor.TransformFinalBlock($EncryptedBytes, 0, $EncryptedBytes.Length)

    # Simpan file terdekripsi (menghilangkan ekstensi .bbga4a1)
    $DecryptedFilePath = $EncryptedFilePath -replace '\.bbga4a1$', ''
    [System.IO.File]::WriteAllBytes($DecryptedFilePath, $DecryptedBytes)

    # Hapus file terenkripsi (opsional)
    Remove-Item $EncryptedFilePath
}

# Load kunci dan IV dari file
$AesKey = Get-Content -Path "C:\Users\ram-check\Downloads\Simulation-Ransomware\key.bin" -Encoding Byte
$AesIV = Get-Content -Path "C:\Users\ram-check\Downloads\Simulation-Ransomware\iv.bin" -Encoding Byte

# Proses dekripsi semua file .bbga4a1 dalam folder
$FolderPath = "C:\Users\ram-check\Downloads\File"
$Files = Get-ChildItem -Path $FolderPath -Filter *.bbga4a1 -File

foreach ($File in $Files) {
    Decrypt-File -EncryptedFilePath $File.FullName -AesKey $AesKey -AesIV $AesIV
}

Write-Host "Dekripsi selesai."
