# ====================================================================
# ESET Network Connectivity Checker (Berdasarkan ESET KB332)
# ====================================================================
Write-Host "Memulai ESET Network Connectivity Checker..." -ForegroundColor Cyan
Write-Host "Mengambil daftar endpoint dari KB332..." -ForegroundColor Cyan

# Daftar lengkap endpoint kritis berdasarkan KB332
$esetTargets = @(
    # 1. Update Modul & Detection Engine (Port 80)
    @{Host="update.eset.com"; Port=80; Service="Update Engine"},
    @{Host="pico.eset.com"; Port=80; Service="Pico Updates"},
    @{Host="download.eset.com"; Port=80; Service="Download Installer"},
    @{Host="um01.eset.com"; Port=80; Service="Update Server 1"},
    
    # 2. Aktivasi, Lisensi & PKI (Port 80 & 443)
    @{Host="pki.eset.com"; Port=80; Service="PKI Caching (First time)"},
    @{Host="edf.eset.com"; Port=443; Service="Live Installer & Aktivasi"},
    @{Host="iploc.eset.com"; Port=443; Service="IP Location Request"},
    @{Host="expire.eset.com"; Port=443; Service="Expiration Date Check"},
    
    # 3. ESET PROTECT & Cloud Management (Port 443)
    @{Host="protect.eset.com"; Port=443; Service="ESET PROTECT"},
    @{Host="identity.eset.com"; Port=443; Service="ESET Identity Server"},
    @{Host="eba.eset.com"; Port=443; Service="ESET Business Account"},
    @{Host="msp.eset.com"; Port=443; Service="ESET MSP Administrator"},
    @{Host="redirector.eset.systems"; Port=443; Service="Redirector"},
    
    # 4. ESET LiveGrid, Antispam & Notifikasi (Port 443 & 8883)
    @{Host="epns.eset.com"; Port=8883; Service="EPNS Wake-Up Calls"},
    @{Host="epns.eset.com"; Port=443; Service="EPNS Fallback"},
    
    # 5. Telemetry, Support & Bantuan (Port 443)
    @{Host="suppreq.eset.eu"; Port=443; Service="Support Requests"},
    @{Host="trace.eset.com"; Port=443; Service="Installation Statistics"},
    @{Host="gallup.eset.com"; Port=443; Service="Telemetry"},
    @{Host="help.eset.com"; Port=443; Service="Online Help"}
)

$report = @()
$successCount = 0
$failCount = 0

Write-Host "`nMemulai pengujian koneksi (Timeout: 3 detik per target)...`n" -ForegroundColor Yellow

foreach ($target in $esetTargets) {
    Write-Host "Menguji $($target.Host):$($target.Port) ($($target.Service))..." -NoNewline
    
    try {
        $result = Test-NetConnection -ComputerName $target.Host -Port $target.Port -WarningAction SilentlyContinue -InformationLevel Quiet
        
        if ($result) {
            Write-Host " [OK]" -ForegroundColor Green
            $status = "TERHUBUNG"
            $successCount++
        } else {
            Write-Host " [GAGAL]" -ForegroundColor Red
            $status = "DIBLOKIR/TIMEOUT"
            $failCount++
        }
    } catch {
        Write-Host " [ERROR DNS]" -ForegroundColor Magenta
        $status = "GAGAL RESOLUSI DNS"
        $failCount++
    }

    $report += [PSCustomObject]@{
        Service = $target.Service
        Hostname = $target.Host
        Port = $target.Port
        Protocol = "TCP"
        Status = $status
    }
}

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "HASIL RINGKASAN:" -ForegroundColor Cyan
Write-Host "Total Berhasil : $successCount" -ForegroundColor Green
Write-Host "Total Gagal    : $failCount" -ForegroundColor Red
Write-Host "========================================================`n" -ForegroundColor Cyan

# Ekspor hasil ke CSV untuk dokumentasi firewall
$csvPath = "$env:USERPROFILE\Desktop\ESET_Network_Check_Result.csv"
$report | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "Laporan detail telah disimpan ke: $csvPath" -ForegroundColor Green
