#!/bin/bash

set -e
# =========================
# =========================
# =========================
# =========================
# =========================
# ===============================
#  SCRIPT DYOR USE WISELY USE
# ===============================
# =========================
# =========================
# =========================
# =========================
# =========================
# INIT
# =========================
BACKUP_DIR="/root/tuning-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p $BACKUP_DIR

echo "[*] Backup konfigurasi asal..."
cp /etc/sysctl.conf          $BACKUP_DIR/ 2>/dev/null || true
cp /etc/security/limits.conf $BACKUP_DIR/ 2>/dev/null || true
cp /etc/systemd/system.conf  $BACKUP_DIR/ 2>/dev/null || true
cp /etc/default/grub         $BACKUP_DIR/ 2>/dev/null || true

# =========================
# FUNCTIONS
# =========================

layer_cpu() {
  echo "[*] Layer 1 — CPU governor..."
  apt install -y cpufrequtils irqbalance > /dev/null 2>&1
  for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
      echo performance > $f 2>/dev/null || true
  done
  systemctl enable --now irqbalance
}

layer_network() {
  echo "[*] Layer 2 — sysctl network..."
  cat > /etc/sysctl.d/99-ubuntu-highload.conf << 'SYSCTL'
fs.file-max = 2097152
fs.nr_open = 1048576
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.core.netdev_max_backlog = 250000
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
net.ipv4.tcp_fastopen = 3
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
vm.swappiness = 10
net.ipv4.ip_local_port_range = 1024 65535
SYSCTL
  sysctl --system > /dev/null 2>&1
}

layer_limits() {
  echo "[*] Layer 3 — OS limits..."
  cat >> /etc/security/limits.conf << 'LIMITS'
* soft nofile 1048576
* hard nofile 1048576
* soft nproc unlimited
* hard nproc unlimited
LIMITS
  sed -i 's/#DefaultLimitNOFILE=/DefaultLimitNOFILE=1048576/' /etc/systemd/system.conf
}

run_all() {
  layer_cpu
  layer_network
  layer_limits
}

# =========================
# MENU
# =========================

while true; do
  clear
  echo "======================================"
  echo " Ubuntu High Load Tuning - CLI Wizard"
  echo "======================================"
  echo "1. Run ALL tuning"
  echo "2. CPU tuning"
  echo "3. Network tuning"
  echo "4. OS Limits tuning"
  echo "7. Exit"
  echo "======================================"
  read -p "Pilih opsi [1-7]: " choice

  case $choice in
    1) run_all ;;
    2) layer_cpu ;;
    3) layer_network ;;
    4) layer_limits ;;
    7) exit 0 ;;
    *) echo "Pilihan tidak valid"; sleep 1 ;;
  esac

  echo ""
  read -p "Tekan ENTER untuk kembali ke menu..."
done
