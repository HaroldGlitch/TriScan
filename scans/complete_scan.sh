#!/bin/bash

# Determina la direccion IP del host para excluirla del analisis
my_ip=$(hostname -I | awk '{print $1}')

# Elegimos un directorio para guardar los resultados
results_dir="results"

# Se determina un subdirectorio para cada session de escaneo
session_dir=$(date +"%Y-%m-%d-%H:%M:%S")
full_session_dir="${results_dir}/${session_dir}"

# Se crean los directiorios en caso de no existir
mkdir -p $results_dir $full_session_dir

echo "Escaneo Completo iniciado"
# Registros para auditoria
echo "Escaneo iniciado por $(whoami) el $(date)" >> "${full_session_dir}/audit_log.txt"

# Funcion para ejecutar el escaneo Nmap
run_nmap_scan() {
  target=$1

  # Excluye al host del objetivo del escaneo
  if [ "$target" == "$my_ip" ]; then
    return
  fi

  rate=1000
  timing=4
  output_file="${full_session_dir}/nmap_results_${target}.txt"

  # Inicializa el archivo del reporte del escaneo
  echo "Resultados del escaneo completo Nmap para $target" > $output_file
  echo "-----------------------------" >> $output_file

  # Busca los puertos abiertos
  open_ports=$(nmap -Pn -p- --min-rate=$rate -T$timing $target | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)

  if [ -z "$open_ports" ]; then
    echo "No se encontraron puertos abiertos en la direcion ip $target" >> $output_file
    return
  fi

  echo "Puertos abiertos: $open_ports" >> $output_file

  # Detecta la version de los servicios en los puertos
  nmap -Pn -sV --version-all -p $open_ports $target >> $output_file

  # Detecta el sistema operativo
  nmap -Pn -O -p $open_ports $target >> $output_file

  # Se realiza un escaneo de vulnerabilidades
  nmap -sV -Pn --script=vuln,safe -p $open_ports $target >> $output_file

  # Escaneos adicionales
  nmap -Pn --traceroute -p $open_ports $target >> $output_file
  nmap -Pn -R -p $open_ports $target >> $output_file
  nmap -Pn -sU -p 53,67-69,161 $target >> $output_file  # Escaneo UDP para los puertos comunes
  nmap -Pn -sO $target >> $output_file

}

# Direccion de los objetivos .txt
input="hosts_results/nmap_target_list.txt"

# Revisa que el archivo exista
if [ ! -f "$input" ]; then
  echo "El archivo $input no ha sido encontrado!"
  exit 1
fi

# Lee los objetivos desde el archivo txt y ejecuta el escaneo para cada uno
while IFS= read -r target
do
  run_nmap_scan "$target" &

  # Limita el numero de trabajos en 2 plano a 10 para no sobrecargar el sistema
  max_jobs=10
  while [ $(jobs -r | wc -l) -gt $max_jobs ]; do
	echo "Escaneando $target... ($(date))"
	echo "Escaneando $target... ($(date))" >> "${full_session_dir}/audit_log.txt"
    sleep 1
  done

done < "$input"

# Espera a que todos los escaneos finalicen
wait

echo "Todos los escaneos se han completado. Los resultados fueron guardados en $full_session_dir."
echo "Escaneo finalizado $(date)" >> "${full_session_dir}/audit_log.txt"
