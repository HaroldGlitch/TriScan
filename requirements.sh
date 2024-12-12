#!/bin/bash

# Función para comprobar si el usuario tiene permisos de root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Este script necesita ejecutarse como root. Usa sudo."
        exit 1
    fi
}

# Función para determinar el gestor de paquetes
get_package_manager() {
    if command -v apt > /dev/null; then
        echo "apt"
    elif command -v yum > /dev/null; then
        echo "yum"
    elif command -v dnf > /dev/null; then
        echo "dnf"
    elif command -v pacman > /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Comprobar si nmap está instalado
check_nmap() {
    if command -v nmap > /dev/null; then
        echo "Nmap ya está instalado en este sistema."
    else
        echo "Nmap no está instalado. Procediendo con la instalación..."
		install_nmap
    fi
}

# Instalar nmap según el gestor de paquetes
install_nmap() {
    package_manager=$(get_package_manager)

    case $package_manager in
        apt)
            apt update && apt install -y nmap
            ;;
        yum)
            yum install -y nmap
            ;;
        dnf)
            dnf install -y nmap
            ;;
        pacman)
            pacman -Sy --noconfirm nmap
            ;;
        *)
            echo "No se pudo determinar el gestor de paquetes. Instala nmap manualmente."
            exit 1
            ;;
    esac
}

# Evalua si el script de vulnerabilidades esta instalada, en caso de que no lo instala
check_vulners() {
  vulners_path="/usr/share/nmap/scripts/vulners.nse"
  if [ -f "$vulners_path" ]; then
    echo "El script de vulnerabilidades se encuentra instalado."
  else
    echo "El script de vulnerabilidades no se ha podido encontrar. Instalando..."
    install_vulners
  fi
}
# Instala el script de vulnerabilidades y actualiza la base de datos de nmap
install_vulners() {
  wget -O /usr/share/nmap/scripts/vulners.nse https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
  nmap --script-updatedb
  echo "El script de vulnerabilidades ha sido instalado."
}

# Cambia los permisos de ejecucion de los script utilizados para el analisis
set_execution_permissions() {
  chmod +x ./run.sh ./scans/complete_scan.sh ./scans/fast_scan.sh ./scans/stealthy_scan.sh 
  echo "Se han modificado los permisos de ejecucion de los archivos necesarios"
}

# Ejecución del script
check_root
check_nmap

# Revisa si las vulnerabilidades estan instaladas, en caso contrario las descarga
check_vulners

# Cambia lso permisos de ejecucion de los script que se utilizan durante la ejecucion del programa
set_execution_permissions