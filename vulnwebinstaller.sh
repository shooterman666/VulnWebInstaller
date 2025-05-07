#!/bin/bash/env
#made by shooterman666 aka Fujikawa Shinichi
#ini adalah script untuk membantu anda dalam instalasi web vulnerability untuk keperluan pentesting
#dan juga untuk keperluan belajar
#langsung saja mulai

set -euo pipefail
#fungsi untuk mendeteksi distro
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

#fungsi untuk instalasi docker engine 
install_docker() {
    local distro=$1
    case $distro in
        ubuntu|debian|linuxmint|pop|kali|parrot)
            echo -e "${GREEN}[+] melanjutkan instalasi docker engine...${NC}"
            sleep 1
            sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        centos|fedora|rhel)
            echo -e "${GREEN}[+] melanjutkan instalasi docker engine...${NC}"
            sleep 1
            sudo dnf update -y && sudo dnf install -y docker
            ;;
        arch|manjaro|blackarch)
            echo -e "${GREEN}[+] melanjutkan instalasi docker engine...${NC}"
            sleep 1
            sudo pacman -Syu --noconfirm && sudo pacman -S --noconfirm docker
            ;;
        *)
            echo "distro tidak dikenali. tolong laporkan distro apa yang anda pakai pada laman github
            www.github/com/shooterman666/vulnlabsetup."
            exit 1
            ;;
    esac
}

#fungsi untuk mengecek apakah docker sudah terinstall
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${GREEN}[+] docker tidak ditemukan. mengunduh dan menginstal dependency...${NC}"
        sleep 1
        install_docker "$1"
    else
        echo -e "${GREEN}[+] docker telah ditemukan. melanjutkan ke proses selanjutnya...${NC}"
        sleep 1
        exit 1
    fi
}

#fugsi menu
menu() { echo -e "${YELLOW}Pilih Menu:${NC}"
    echo " 1) Instalasi Web Vulnerability Apps"
    echo " 2) Jalankan Aplikasi"
    echo " 3) Hentikan Aplikasi"
    echo " 4) Status Aplikasi"
    echo " 5) Bersihkan Instalasi"
    echo " 6) Tambah Aplikasi Baru"
    echo " 7) Dokumentasi"
    echo " 8) Keluar"
    echo ""
}

#instalasi vulnerable web apps
webInstall() {
    echo -e "${GREEN}[+] Memulai instalasi aplikasi web...${NC}"
    sleep 1
    echo -e "${GREEN}[+] Silahkan pilih web vulnerable yang ada...${NC}"
    echo " 1) DVWA"
    echo " 2) bWAPP"
    echo " 3) OWASP Juice Shop"
    echo " 4) WebGoat"
    echo " 5) jika aplikasi yang anda inginkan tidak ada silahkan gunakan opsi tambah aplikasi baru"
    echo ""
    read -p "Pilih aplikasi (1-5): " app_choice
    case $app_choice in
        1)
            echo -e "${GREEN}[+] Menginstal DVWA...${NC}"
            sleep 1
            port=
            nama=""
            read -p "Masukkan port yang ingin digunakan (default 80): "
            read -p "Masukkan nama untuk container (default dvwa): "
            docker run -d -p $port:80 --name $name vulnerables/web-dvwa
            ;;
        2)
            echo -e "${GREEN}[+] Menginstal bWAPP...${NC}"
            sleep 1
            port=
            nama=""
            read -p "Masukkan port yang ingin digunakan (default 80): "
            read -p "Masukkan nama untuk container (default dvwa): "
            docker run -d -p $port:80 --name $name hackersploit/bwapp-docker
            ;;
        3)
            echo -e "${GREEN}[+] Menginstal OWASP Juice Shop...${NC}"
            sleep 1
            port=
            nama=""
            read -p "Masukkan port yang ingin digunakan (default 80): "
            read -p "Masukkan nama untuk container (default dvwa): "
            docker run -d -p $port:3000 --name $name bkimminich/juice-shop
            ;;
        4)
            echo -e "${GREEN}[+] Menginstal WebGoat...${NC}"
            sleep 1
            port=
            nama=""
            read -p "Masukkan port yang ingin digunakan (default 80): "
            read -p "Masukkan nama untuk container (default dvwa): "
            docker run -d -p $port:8080 --name $name webgoat/webgoat
            ;;
        *)
            echo "Pilihan tidak valid. Silakan coba lagi."
            ;;
    esac
    echo -e "${GREEN}[+] Instalasi aplikasi web selesai.${NC}"
    echo -e "${GREEN}[+] Anda dapat mengakses aplikasi di http://localhost:$port${NC}"
}

jalankanAplikasi() {
    read -p "Masukkan nama aplikasi yang ingin dijalankan: " app_name
    if [ -z "$app_name" ]; then
        echo "Nama aplikasi tidak boleh kosong."
        return
    fi 
    docker start $app_name
}

hentikanAplikasi() {
    read -p "Masukkan nama aplikasi yang ingin dijalankan: " app_name
    if [ -z "$app_name" ]; then
        echo "Nama aplikasi tidak boleh kosong."
        return
    fi
    docker stop $app_name
}

statusAplikasi() {
    # read -p "Masukkan nama aplikasi yang ingin dicek status: " app_name
    # if [ -z "$app_name" ]; then
    #     echo "Nama aplikasi tidak boleh kosong."
    #     return
    # fi
    # docker ps -a | grep $app_name
    read -p "Apakah anda ingin menampilkan semua aplikasi aplikasi yang sedang berjalan??(y/n)" balas
    if [[ $balas == "y"|"Y" ]]; then
        docker ps
        elif [[ $balas == "n"|"N" ]]; then
        read -p "Masukkan nama aplikasi yang ingin dicek...: " app_name
        if [ -z "$app_name" ]; then
            echo "Nama aplikasi tidak boleh kosong."
            return
        fi
        docker ps -a | grep $app_name
    else
        echo "Pilihan tidak valid. Silakan coba lagi."
    fi
    echo -e "${GREEN}[+] Status aplikasi ditampilkan.${NC}"
}

hapusAplikasi() {
    read -p "Masukkan nama aplikasi yang ingin dihapus: " app_name
    if [ -z "$app_name" ]; then
        echo "Nama aplikasi tidak boleh kosong."
        return
    fi
    docker stop $app_name
    docker rm $app_name
}

tambahAplikasi() {
    read -p "Silahkan masukkan docker image yang ingin ditambahkan: " docker_image
    read -p "Silahkan masukkan port yang ingin digunakan (host_port): " port
    read -p "Silahkan masukkan nama untuk container: " name

    if [[ -z "$docker_image" || -z "$port" || -z "$name" ]]; then
        echo "Semua input harus diisi!"
        return 1
    fi

    docker run -d -p "$port":80 --name "$name" "$docker_image"
}


dokumentasi() {
    echo "Sementara ini masih kosong"
}


#program utama
# Warna teks
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Clear terminal
clear

# Header CLI
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

#menampilkan menu

while true; do
    pilihan=""
    menu
    read -p "Masukkan menu: " pilihan

    case $pilihan in
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

    echo ""
    read -p "Tekan Enter untuk kembali ke menu..."
    clear
done
