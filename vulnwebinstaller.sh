#!/usr/bin/env bash
#made by shooterman666 aka Fujikawa Shinichi
#ini adalah script untuk membantu anda dalam instalasi web vulnerability untuk keperluan pentesting
#dan juga untuk keperluan belajar
#langsung saja mulai

set -euo pipefail

#Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#Deteksi Distro
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

#Install Docker Engine
install_docker() {
    local distro=$1
    echo -e "${GREEN}[+] Instalasi Docker Engine untuk ${distro}...${NC}"
    sleep 1

    case "$distro" in
        ubuntu|debian|linuxmint|pop|kali|parrot)
            sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        centos|fedora|rhel)
            sudo dnf update -y && sudo dnf install -y docker
            ;;
        arch|manjaro|blackarch)
            sudo pacman -Syu --noconfirm docker
            ;;
        *)
            echo -e "${RED}Distro tidak dikenali.${NC}"
            echo "Laporkan di: github.com/shooterman666/vulnlabsetup"
            exit 1
            ;;
    esac
}

#Cek dan install docker jika perlu
check_docker() {
    local distro
    distro=$(detect_distro)
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}[!] Docker tidak ditemukan. Menginstal...${NC}"
        install_docker "$distro"
    else
        echo -e "${GREEN}[+] Docker sudah terpasang.${NC}"
    fi
}

#Menu
menu() {
    echo -e "${YELLOW}Pilih Menu:${NC}"
    echo " 1) Instalasi Web Vulnerability Apps"
    echo " 2) Jalankan Aplikasi"
    echo " 3) Hentikan Aplikasi"
    echo " 4) Status Aplikasi"
    echo " 5) Bersihkan (hapus) Aplikasi"
    echo " 6) Tambah Aplikasi Baru"
    echo " 7) Dokumentasi"
    echo " 8) Keluar"
    echo ""
}

#Fungsi Instalasi Web Apps
webInstall() {
    echo -e "${GREEN}[+] Memulai instalasi aplikasi web...${NC}"
    sleep 1
    echo -e "${CYAN}Pilih aplikasi:${NC}"
    echo " 1) DVWA"
    echo " 2) bWAPP"
    echo " 3) OWASP Juice Shop"
    echo " 4) WebGoat"
    echo " 5) Kembali ke menu utama"
    echo ""
    read -p "Pilihan (1-5): " app_choice

    [[ ! "$app_choice" =~ ^[1-5]$ ]] && { echo -e "${RED}Pilihan tidak valid!${NC}"; return; }

    # default values
    local port name image
    case "$app_choice" in
        1) image="vulnerables/web-dvwa"; default_port=80; default_name="dvwa" ;;
        2) image="hackersploit/bwapp-docker"; default_port=80; default_name="bwapp" ;;
        3) image="bkimminich/juice-shop"; default_port=3000; default_name="juice-shop" ;;
        4) image="webgoat/webgoat"; default_port=8080; default_name="webgoat" ;;
        5) return ;;
    esac

    read -p "Port (default ${default_port}): " port
    port=${port:-$default_port}

    read -p "Nama container (default ${default_name}): " name
    name=${name:-$default_name}

    echo -e "${GREEN}[+] Menarik image dan menjalankan ${name}...${NC}"
    docker run -d -p "${port}:80" --name "${name}" "${image}"

    echo -e "${GREEN}[+] Selesai! Akses di: http://localhost:${port}${NC}"
}

#Fungsi Jalankan Aplikasi
jalankanAplikasi() {
    read -p "Nama container yang ingin dijalankan: " app_name
    if [ -z "$app_name" ]; then
        echo -e "${RED}Nama tidak boleh kosong!${NC}"
        return
    fi
    docker start "$app_name" && echo -e "${GREEN}[+] ${app_name} dijalankan.${NC}"
}

#Fungsi Hentikan Aplikasi
hentikanAplikasi() {
    read -p "Nama container yang ingin dihentikan: " app_name
    if [ -z "$app_name" ]; then
        echo -e "${RED}Nama tidak boleh kosong!${NC}"
        return
    fi
    docker stop "$app_name" && echo -e "${YELLOW}[!] ${app_name} dihentikan.${NC}"
}

#Fungsi Status Aplikasi
statusAplikasi() {
    read -p "Tampilkan semua container yang berjalan? (y/n): " jawab
    if [[ "$jawab" =~ ^[Yy]$ ]]; then
        docker ps
    elif [[ "$jawab" =~ ^[Nn]$ ]]; then
        read -p "Masukkan nama container: " app_name
        docker ps -a | grep "$app_name" || echo -e "${RED}Container ${app_name} tidak ditemukan.${NC}"
    else
        echo -e "${RED}Pilihan tidak valid!${NC}"
    fi
}

#Fungsi Hapus Aplikasi
hapusAplikasi() {
    read -p "Nama container yang ingin dihapus: " app_name
    if [ -z "$app_name" ]; then
        echo -e "${RED}Nama tidak boleh kosong!${NC}"
        return
    fi
    docker stop "$app_name" 2>/dev/null || true
    docker rm "$app_name" && echo -e "${GREEN}[+] ${app_name} dihapus.${NC}"
}

#Fungsi Tambah Aplikasi Baru
tambahAplikasi() {
    read -p "Docker image (e.g. nginx:latest): " docker_image
    read -p "Port host (e.g. 8081): " port
    read -p "Nama container: " name

    if [[ -z "$docker_image" || -z "$port" || -z "$name" ]]; then
        echo -e "${RED}Semua input wajib diisi!${NC}"
        return
    fi

    docker run -d -p "${port}:80" --name "${name}" "${docker_image}"
    echo -e "${GREEN}[+] ${name} berjalan di port ${port}.${NC}"
}

#Fungsi Dokumentasi
dokumentasi() {
    cat <<-EOF
    Dokumentasi singkat:
    - DVWA:      http://localhost:80
    - bWAPP:     http://localhost:80
    - JuiceShop: http://localhost:3000
    - WebGoat:   http://localhost:8080

    Repo: https://github.com/shooterman666/vulnlabsetup
EOF
}

#Program Utama
clear
echo -e "${CYAN}"
echo "==========================================="
echo "      🚀 Deploy Vulnerable Web Apps       "
echo "==========================================="
echo -e "${NC}"

echo -e "${GREEN}[+] Starting setup process...${NC}"
echo -e "${GREEN}[+] Pembuat: Fujikawa Shinichi ${NC}"
echo -e "${GREEN}[+] Email: fujikawashinichi1@gmail.com${NC}"
echo -e "${GREEN}[+] Note: silahkan gunakan ini untuk membantu proses praktikum${NC}"
echo -e "${GREEN}[+] web pentesting kalian. happy hacking!!!${NC}"
sleep 1

# Daftar aplikasi (dummy, nanti bisa kamu sesuaikan)
echo -e "${CYAN}[*] Web vulnerable yang biasanya di-setup:${NC}"
echo "  - DVWA"
echo "  - bWAPP"
echo "  - OWASP Juice Shop"
echo "  - WebGoat"
echo ""
sleep 1

check_docker

while true; do
    echo
    menu
    read -p "Masukkan pilihan [1-8]: " pilihan
    echo

    case "$pilihan" in
        1) webInstall ;;
        2) jalankanAplikasi ;;
        3) hentikanAplikasi ;;
        4) statusAplikasi ;;
        5) hapusAplikasi ;;
        6) tambahAplikasi ;;
        7) dokumentasi ;;
        8) echo -e "${GREEN}Keluar. Sampai jumpa!${NC}"; exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid! Silakan coba lagi.${NC}" ;;
    esac

    read -p "Tekan Enter untuk kembali ke menu..."
    clear
done
