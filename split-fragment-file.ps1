# Ganti dengan jalur file installer yang ingin dipecah
$sourceFile = "C:\Users\check\Downloads\Scriptfragmentasi\installer.msi"
# Ganti dengan folder tujuan untuk menyimpan file bagian
$outputFolder = "C:\Users\check\Downloads\Fragmentasi"

# Membaca semua byte dari file sumber
$bytes = [System.IO.File]::ReadAllBytes($sourceFile)
$partSize = 512KB  # Ukuran setiap bagian (misalnya 10MB)

# Menghitung jumlah bagian
$totalParts = [math]::Ceiling($bytes.Length / $partSize)

# Memecah file
for ($i = 0; $i -lt $totalParts; $i++) {
    $partFileName = Join-Path $outputFolder ("a" + $i + ".msi")
    $start = $i * $partSize
    $length = [math]::Min($partSize, $bytes.Length - $start)
    
    # Membuat file bagian
    [System.IO.File]::WriteAllBytes($partFileName, $bytes[$start..($start + $length - 1)])
    Write-Host "File bagian $partFileName dibuat."
}
