# Folder tempat file bagian disimpan
$inputFolder = "C:\Users\check\Downloads\Fragmentasi"  # Ganti dengan jalur folder yang sesuai
# Nama file output gabungan
$outputFile = "C:\Users\check\Downloads\Scriptfragmentasi\combined_installer.msi"  # Ganti dengan nama file yang diinginkan

# Menggabungkan file
Write-Host "Menggabungkan file menjadi $outputFile..."

# Membuat atau mengosongkan file output
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

# Membuka file output untuk menulis
$fileStream = [System.IO.File]::Open($outputFile, 'Create')

# Mengambil semua file bagian dan mengurutkannya berdasarkan angka di nama file
$files = Get-ChildItem -Path $inputFolder | Where-Object { $_.Name -match '^a(\d+)\.msi$' } | Sort-Object {
    # Ekstrak angka dari nama file dan urutkan secara numerik
    [int]($_.Name -replace '^a(\d+)\.msi$', '$1')
}

# Menulis isi dari setiap file bagian ke file output
foreach ($file in $files) {
    Write-Host "Menambahkan $($file.Name)..."
    
    # Membaca isi file bagian dan menambahkannya ke file output
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $fileStream.Write($bytes, 0, $bytes.Length)
}

# Menutup file output
$fileStream.Close()

Write-Host "Penggabungan selesai. File gabungan tersimpan di $outputFile."
