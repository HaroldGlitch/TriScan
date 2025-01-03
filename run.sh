#!/bin/bash

# Configuración
rate=300
results_dir="hosts_results"
mkdir -p $results_dir
log_file="${results_dir}/audit_log.txt"
output_file="${results_dir}/nmap_target_list.txt"

# Función para comprobar si el usuario tiene permisos de root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Este script necesita ejecutarse como root. Usa sudo."
        exit 1
    fi
}

check_root
# Detectar la subred automáticamente
ip_info=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')
if [ -z "$ip_info" ]; then
    echo "Error: No se pudo determinar la subred. Saliendo."
    exit 1
fi
subnet=$ip_info

# Escanea los Hosts de la red
scan_hosts() {
	# Escaneo con Nmap
	echo "Iniciando escaneo en la subred $subnet..."
	if ! nmap -sn --max-rate=$rate $subnet -oG - | awk '/Up$/{print $2}' > $output_file; then
		echo "Error ejecutando nmap. Revisa la configuración de red."
		exit 1
	fi
	# Registro en archivo de auditoría
	echo "Escaneo iniciado por $(whoami) el $(date) en la subred $subnet" >> $log_file

	# Comprobar si se encontraron hosts vivos
	if [ ! -s "$output_file" ]; then
		echo "No se encontraron hosts activos."
		exit 1
	fi
	echo "Hosts activos encontrados y guardados en $output_file."
}

# Selección del tipo de escaneo
choose_scan() {
	echo "Selecciona el tipo de escaneo a realizar:"
	echo "1) Escaneo completo"
	echo "2) Escaneo rápido"
	echo "3) Escaneo sigiloso"

	read -p "Introduce tu elección [1-3]: " choice

	case $choice in
		1)
			./scans/complete_scan.sh
			;;
		2)
			./scans/fast_scan.sh
			;;
		3)
			./scans/stealthy_scan.sh
			;;
		*)
			echo "Opción inválida. Saliendo."
			exit 1
			;;
	esac

	echo "El escaneo seleccionado ha sido completado."
	re-scan
}
# Vuelve a escanear la red con los host ya identificados
re-scan(){
	while true; do
		# Preguntar al usuario
		read -p "¿Desea realizar otro escaneo? (s/n): " answer

		case $answer in
			[sS]|[sS][iI])
				choose_scan
				;;
			[nN]|[nN][oO])
				echo "Saliendo..."
				exit 0
				;;
			*)
				echo "Por favor, responda 's' para sí o 'n' para no."
				;;
		esac
	done
}

# Comprobar si hay host activos
if [ ! -s "$output_file" ]; then
	touch $output_file
	scan_hosts
	choose_scan
fi
echo "Se encontraron Host activos."

# Selección del tipo de escaneo
echo "Selecciona una de las siguientes opciones"
echo "1) Volver a escanear la red"
echo "2) Usar estos hosts"
echo "3) Salir"

read -p "Introduce tu elección [1-3]: " choice

case $choice in
    1)
	# Limpiar y preparar el archivo de salida
	> $output_file
	scan_hosts
	choose_scan
        ;;
	2)
        choose_scan
        ;;
    *)
        echo "Saliendo."
        exit 1
        ;;
esac
