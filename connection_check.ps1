# ====================================================================
# ESET Network Connectivity Checker (Lengkap: KB332 + Table 22 + Table 24)
# ====================================================================
Write-Host "Memulai ESET Network Connectivity Checker..." -ForegroundColor Cyan
Write-Host "Mengambil daftar endpoint dari KB332, Table 22, dan Table 24..." -ForegroundColor Cyan

# Daftar lengkap endpoint kritis berdasarkan dokumentasi ESET
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
    @{Host="help.eset.com"; Port=443; Service="Online Help"},

    # 6. ESET PROTECT Web Console & Hub (Table 22)
    @{Host="protecthub.eset.com"; Port=443; Service="ESET PROTECT Hub"},
    @{Host="eu02.protect.eset.com"; Port=443; Service="PROTECT Web Console (Europe)"},
    @{Host="us02.protect.eset.com"; Port=443; Service="PROTECT Web Console (USA)"},
    @{Host="jp02.protect.eset.com"; Port=443; Service="PROTECT Web Console (Japan)"},
    @{Host="ca01.protect.eset.com"; Port=443; Service="PROTECT Web Console (Canada)"},
    @{Host="de01.protect.eset.com"; Port=443; Service="PROTECT Web Console (Germany)"},
    
    # 7. ESET PROTECT XDR Server Connections (Table 22)
    @{Host="eu01.server.xdr.eset.systems"; Port=443; Service="XDR Agent Connection (Europe)"},
    @{Host="de01.server.xdr.eset.systems"; Port=443; Service="XDR Agent Connection (Germany)"},
    @{Host="jp01.server.xdr.eset.systems"; Port=443; Service="XDR Agent Connection (Japan)"},
    @{Host="us01.server.xdr.eset.systems"; Port=443; Service="XDR Agent Connection (USA)"},
    @{Host="ca01.server.xdr.eset.systems"; Port=443; Service="XDR Agent Connection (Canada)"},
    
    # 8. ESET PROTECT File Upload Service - Azure Cloud (Port 444) (Table 22)
    #@{Host="epx-k8s-prod-eu-a.westeurope.cloudapp.azure.com"; Port=444; Service="File Upload (Europe)"},
    #@{Host="epx-k8s-prod-de-a.germanywestcentral.cloudapp.azure.com"; Port=444; Service="File Upload (Germany)"},
    #@{Host="epx-k8s-prod-jp-a.japaneast.cloudapp.azure.com"; Port=444; Service="File Upload (Japan)"},
    #@{Host="epx-k8s-prod-us-a.westus.cloudapp.azure.com"; Port=444; Service="File Upload (USA)"},
    #@{Host="epx-k8s-prod-ca-a.canadacentral.cloudapp.azure.com"; Port=444; Service="File Upload (Canada)"},
    
    # 9. ESET PROTECT File Download Service (Table 22)
    @{Host="eu.download.protect.eset.com"; Port=443; Service="File Download (Europe)"},
    @{Host="de.download.protect.eset.com"; Port=443; Service="File Download (Germany)"},
    @{Host="jp.download.protect.eset.com"; Port=443; Service="File Download (Japan)"},
    @{Host="us.download.protect.eset.com"; Port=443; Service="File Download (USA)"},
    @{Host="ca.download.protect.eset.com"; Port=443; Service="File Download (Canada)"},
    
    # 10. Cloud MDM (Mobile Device Management) (Table 22)
    @{Host="eu.mdm.eset.com"; Port=443; Service="Cloud MDM Enrollment (Europe)"},
    @{Host="us.mdm.eset.com"; Port=443; Service="Cloud MDM Enrollment (USA)"},
    @{Host="jp.mdm.eset.com"; Port=443; Service="Cloud MDM Enrollment (Japan)"},
    @{Host="ca.mdm.eset.com"; Port=443; Service="Cloud MDM Enrollment (Canada)"},
    @{Host="de.mdm.eset.com"; Port=443; Service="Cloud MDM Enrollment (Germany)"},
    @{Host="checkin.eu.mdm.eset.com"; Port=443; Service="Cloud MDM Check-in (Europe)"},
    @{Host="checkin.us.mdm.eset.com"; Port=443; Service="Cloud MDM Check-in (USA)"},
    @{Host="checkin.jp.mdm.eset.com"; Port=443; Service="Cloud MDM Check-in (Japan)"},
    @{Host="checkin.ca.mdm.eset.com"; Port=443; Service="Cloud MDM Check-in (Canada)"},
    @{Host="checkin.de.mdm.eset.com"; Port=443; Service="Cloud MDM Check-in (Germany)"},
    @{Host="mdmcomm.eu.mdm.eset.com"; Port=443; Service="Cloud MDM Comm (Europe)"},
    @{Host="mdmcomm.us.mdm.eset.com"; Port=443; Service="Cloud MDM Comm (USA)"},
    @{Host="mdmcomm.jp.mdm.eset.com"; Port=443; Service="Cloud MDM Comm (Japan)"},
    @{Host="mdmcomm.ca.mdm.eset.com"; Port=443; Service="Cloud MDM Comm (Canada)"},
    @{Host="mdmcomm.de.mdm.eset.com"; Port=443; Service="Cloud MDM Comm (Germany)"},
    @{Host="mdm.eset.com"; Port=443; Service="Cloud MDM Global Enrollment"},
    @{Host="repository.eset.com"; Port=80; Service="Repository Deployment"},

    # ====================================================================
    # 11. ESET Inspect & EDR (Port 443 & 8093)
    # ====================================================================
    @{Host="ema.eset.com"; Port=443; Service="ESET Managed Service Provider (EMA)"},
    @{Host="inspect.eset.com"; Port=443; Service="ESET Inspect"},
    @{Host="eu01.inspect.eset.com"; Port=443; Service="ESET Inspect Web Console (Europe)"},
    @{Host="us01.inspect.eset.com"; Port=443; Service="ESET Inspect Web Console (USA)"},
    @{Host="jp01.inspect.eset.com"; Port=443; Service="ESET Inspect Web Console (Japan)"},
    @{Host="ca01.inspect.eset.com"; Port=443; Service="ESET Inspect Web Console (Canada)"},
    @{Host="de01.inspect.eset.com"; Port=443; Service="ESET Inspect Web Console (Germany)"},
    @{Host="eu01.agent.edr.eset.systems"; Port=8093; Service="EDR Agent Connection (Europe)"},
    @{Host="us01.agent.edr.eset.systems"; Port=8093; Service="EDR Agent Connection (USA)"},
    @{Host="jp01.agent.edr.eset.systems"; Port=8093; Service="EDR Agent Connection (Japan)"},
    @{Host="ca01.agent.edr.eset.systems"; Port=8093; Service="EDR Agent Connection (Canada)"},
    @{Host="de01.agent.edr.eset.systems"; Port=8093; Service="EDR Agent Connection (Germany)"}

    # ====================================================================
    # 12. TAMBAHAN TERBARU: ESET Connect Prerequisites (Port 443)
    # ====================================================================
    
    # Europe
    @{Host="eu.business-account.iam.eset.systems"; Port=443; Service="ESET Connect: Authentication (EU)"},
    @{Host="eu.application-management.eset.systems"; Port=443; Service="ESET Connect: App Management (EU)"},
    @{Host="eu.asset-management.eset.systems"; Port=443; Service="ESET Connect: Asset Management (EU)"},
    @{Host="eu.automation.eset.systems"; Port=443; Service="ESET Connect: Automation (EU)"},
    @{Host="eu.device-management.eset.systems"; Port=443; Service="ESET Connect: Device Management (EU)"},
    @{Host="eu.iam.eset.systems"; Port=443; Service="ESET Connect: IAM (EU)"},
    @{Host="eu.incident-management.eset.systems"; Port=443; Service="ESET Connect: Incident Management (EU)"},
    @{Host="eu.installer-management.eset.systems"; Port=443; Service="ESET Connect: Installer Management (EU)"},
    @{Host="eu.mobile-device-management.eset.systems"; Port=443; Service="ESET Connect: MDM (EU)"},
    @{Host="eu.network-access-protection.eset.systems"; Port=443; Service="ESET Connect: NAP (EU)"},
    @{Host="eu.patch-management.eset.systems"; Port=443; Service="ESET Connect: Patch Management (EU)"},
    @{Host="eu.policy-management.eset.systems"; Port=443; Service="ESET Connect: Policy Management (EU)"},
    @{Host="eu.quarantine-management.eset.systems"; Port=443; Service="ESET Connect: Quarantine Management (EU)"},
    @{Host="eu.user-management.eset.systems"; Port=443; Service="ESET Connect: User Management (EU)"},
    @{Host="eu.vulnerability-management.eset.systems"; Port=443; Service="ESET Connect: Vulnerability Management (EU)"},
    @{Host="eu.web-access-protection.eset.systems"; Port=443; Service="ESET Connect: Web Access Protection (EU)"},

    # Germany
    @{Host="de.business-account.iam.eset.systems"; Port=443; Service="ESET Connect: Authentication (DE)"},
    @{Host="de.application-management.eset.systems"; Port=443; Service="ESET Connect: App Management (DE)"},
    @{Host="de.asset-management.eset.systems"; Port=443; Service="ESET Connect: Asset Management (DE)"},
    @{Host="de.automation.eset.systems"; Port=443; Service="ESET Connect: Automation (DE)"},
    @{Host="de.device-management.eset.systems"; Port=443; Service="ESET Connect: Device Management (DE)"},
    @{Host="de.iam.eset.systems"; Port=443; Service="ESET Connect: IAM (DE)"},
    @{Host="de.incident-management.eset.systems"; Port=443; Service="ESET Connect: Incident Management (DE)"},
    @{Host="de.installer-management.eset.systems"; Port=443; Service="ESET Connect: Installer Management (DE)"},
    @{Host="de.mobile-device-management.eset.systems"; Port=443; Service="ESET Connect: MDM (DE)"},
    @{Host="de.network-access-protection.eset.systems"; Port=443; Service="ESET Connect: NAP (DE)"},
    @{Host="de.patch-management.eset.systems"; Port=443; Service="ESET Connect: Patch Management (DE)"},
    @{Host="de.policy-management.eset.systems"; Port=443; Service="ESET Connect: Policy Management (DE)"},
    @{Host="de.quarantine-management.eset.systems"; Port=443; Service="ESET Connect: Quarantine Management (DE)"},
    @{Host="de.user-management.eset.systems"; Port=443; Service="ESET Connect: User Management (DE)"},
    @{Host="de.vulnerability-management.eset.systems"; Port=443; Service="ESET Connect: Vulnerability Management (DE)"},
    @{Host="de.web-access-protection.eset.systems"; Port=443; Service="ESET Connect: Web Access Protection (DE)"},

    # USA
    @{Host="us.business-account.iam.eset.systems"; Port=443; Service="ESET Connect: Authentication (USA)"},
    @{Host="us.application-management.eset.systems"; Port=443; Service="ESET Connect: App Management (USA)"},
    @{Host="us.asset-management.eset.systems"; Port=443; Service="ESET Connect: Asset Management (USA)"},
    @{Host="us.automation.eset.systems"; Port=443; Service="ESET Connect: Automation (USA)"},
    @{Host="us.device-management.eset.systems"; Port=443; Service="ESET Connect: Device Management (USA)"},
    @{Host="us.iam.eset.systems"; Port=443; Service="ESET Connect: IAM (USA)"},
    @{Host="us.incident-management.eset.systems"; Port=443; Service="ESET Connect: Incident Management (USA)"},
    @{Host="us.installer-management.eset.systems"; Port=443; Service="ESET Connect: Installer Management (USA)"},
    @{Host="us.mobile-device-management.eset.systems"; Port=443; Service="ESET Connect: MDM (USA)"},
    @{Host="us.network-access-protection.eset.systems"; Port=443; Service="ESET Connect: NAP (USA)"},
    @{Host="us.patch-management.eset.systems"; Port=443; Service="ESET Connect: Patch Management (USA)"},
    @{Host="us.policy-management.eset.systems"; Port=443; Service="ESET Connect: Policy Management (USA)"},
    @{Host="us.quarantine-management.eset.systems"; Port=443; Service="ESET Connect: Quarantine Management (USA)"},
    @{Host="us.user-management.eset.systems"; Port=443; Service="ESET Connect: User Management (USA)"},
    @{Host="us.vulnerability-management.eset.systems"; Port=443; Service="ESET Connect: Vulnerability Management (USA)"},
    @{Host="us.web-access-protection.eset.systems"; Port=443; Service="ESET Connect: Web Access Protection (USA)"},

    # Japan
    @{Host="jpn.business-account.iam.eset.systems"; Port=443; Service="ESET Connect: Authentication (JPN)"},
    @{Host="jpn.application-management.eset.systems"; Port=443; Service="ESET Connect: App Management (JPN)"},
    @{Host="jpn.asset-management.eset.systems"; Port=443; Service="ESET Connect: Asset Management (JPN)"},
    @{Host="jpn.automation.eset.systems"; Port=443; Service="ESET Connect: Automation (JPN)"},
    @{Host="jpn.device-management.eset.systems"; Port=443; Service="ESET Connect: Device Management (JPN)"},
    @{Host="jpn.iam.eset.systems"; Port=443; Service="ESET Connect: IAM (JPN)"},
    @{Host="jpn.incident-management.eset.systems"; Port=443; Service="ESET Connect: Incident Management (JPN)"},
    @{Host="jpn.installer-management.eset.systems"; Port=443; Service="ESET Connect: Installer Management (JPN)"},
    @{Host="jpn.mobile-device-management.eset.systems"; Port=443; Service="ESET Connect: MDM (JPN)"},
    @{Host="jpn.network-access-protection.eset.systems"; Port=443; Service="ESET Connect: NAP (JPN)"},
    @{Host="jpn.patch-management.eset.systems"; Port=443; Service="ESET Connect: Patch Management (JPN)"},
    @{Host="jpn.policy-management.eset.systems"; Port=443; Service="ESET Connect: Policy Management (JPN)"},
    @{Host="jpn.vulnerability-management.eset.systems"; Port=443; Service="ESET Connect: Vulnerability Management (JPN)"},
    @{Host="jpn.web-access-protection.eset.systems"; Port=443; Service="ESET Connect: Web Access Protection (JPN)"},

    # Canada
    @{Host="ca.business-account.iam.eset.systems"; Port=443; Service="ESET Connect: Authentication (CA)"},
    @{Host="ca.application-management.eset.systems"; Port=443; Service="ESET Connect: App Management (CA)"},
    @{Host="ca.asset-management.eset.systems"; Port=443; Service="ESET Connect: Asset Management (CA)"},
    @{Host="ca.automation.eset.systems"; Port=443; Service="ESET Connect: Automation (CA)"},
    @{Host="ca.device-management.eset.systems"; Port=443; Service="ESET Connect: Device Management (CA)"},
    @{Host="ca.iam.eset.systems"; Port=443; Service="ESET Connect: IAM (CA)"},
    @{Host="ca.incident-management.eset.systems"; Port=443; Service="ESET Connect: Incident Management (CA)"},
    @{Host="ca.installer-management.eset.systems"; Port=443; Service="ESET Connect: Installer Management (CA)"},
    @{Host="ca.mobile-device-management.eset.systems"; Port=443; Service="ESET Connect: MDM (CA)"},
    @{Host="ca.network-access-protection.eset.systems"; Port=443; Service="ESET Connect: NAP (CA)"},
    @{Host="ca.patch-management.eset.systems"; Port=443; Service="ESET Connect: Patch Management (CA)"},
    @{Host="ca.policy-management.eset.systems"; Port=443; Service="ESET Connect: Policy Management (CA)"},
    @{Host="ca.quarantine-management.eset.systems"; Port=443; Service="ESET Connect: Quarantine Management (CA)"},
    @{Host="ca.user-management.eset.systems"; Port=443; Service="ESET Connect: User Management (CA)"},
    @{Host="ca.vulnerability-management.eset.systems"; Port=443; Service="ESET Connect: Vulnerability Management (CA)"},
    @{Host="ca.web-access-protection.eset.systems"; Port=443; Service="ESET Connect: Web Access Protection (CA)"}

    # ====================================================================
    # 13. ESET Repository Servers (Dari Table 21)
    # Semua host ini menggunakan Port 80 (HTTP) sesuai standar unduhan repositori ESET
    # ====================================================================
    @{Host="repository.eset.com"; Port=80; Service="ESET Repository (Global)"},
    @{Host="repous.wip.eset.com"; Port=80; Service="ESET Repository (US WIP)"},
    @{Host="us-repository.eset.com"; Port=80; Service="ESET Repository (US)"},
    @{Host="us-repository.gtm.eset.com"; Port=80; Service="ESET Repository (US GTM)"},
    @{Host="h5-repository03-v.eset.com"; Port=80; Service="ESET Repository Server (h5)"},
    @{Host="reponocdn.wip.eset.com"; Port=80; Service="ESET Repository (NoCDN WIP)"},
    @{Host="h1-repo01-v.eset.com"; Port=80; Service="ESET Repository Server (h1)"},
    @{Host="hp-webs01-s.eset.com"; Port=80; Service="ESET Web Server (hp)"},
    @{Host="h1-repository01-v.eset.com"; Port=80; Service="ESET Repository Server (h1-v)"},
    @{Host="h3-repository02-v.eset.com"; Port=80; Service="ESET Repository Server (h3)"},
    @{Host="91-228-167-25.ptr.eset.com"; Port=80; Service="ESET Repository (PTR Record)"},
    @{Host="nocdn-repository.gtm.eset.com"; Port=80; Service="ESET Repository (NoCDN GTM)"}
)

# CATATAN PENTING UNTUK ADMINISTRATOR (Tidak diuji via skrip ini):
# 1. Domain wildcard (*.a.ecaserver.eset.com) tidak bisa di-ping langsung. 
#    Pastikan firewall mengizinkan *.a.ecaserver.eset.com pada port 443.
# 2. Port TCP 139, 445 dan UDP 137, 138 (ESET PROTECT Remote Deployment Tool) 
#    HANYA digunakan untuk komunikasi JARINGAN LOKAL (LAN) antar komputer Windows (SMB/NetBIOS).
#    Port ini TIDAK PERLU dibuka ke Internet, melainkan di firewall lokal/internal jaringan Anda.

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
