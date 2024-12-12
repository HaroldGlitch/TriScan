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

echo "Escaneo Rapido iniciado"
# Registros para auditoria
echo "Escaneo iniciado por $(whoami) el $(date)" >> "${full_session_dir}/audit_log.txt"

# Funcion para ejecutar el escaneo Nmap
run_fast_nmap_scan() {
  target=$1

  # Excluye al host del objetivo del escaneo
  if [ "$target" == "$my_ip" ]; then
    return
  fi

  rate=1000
  timing=4
  output_file="${full_session_dir}/nmap_results_${target}.txt"

  # Inicializa el archivo del reporte del escaneo
  echo "Resultados del escaneo rapido Nmap para $target" > $output_file
  echo "----------------------------------" >> $output_file

  # Escaneo rapido tipo TCP scan para los primeros 1000 puertos
  nmap -Pn --top-ports 1000 --min-rate=$rate -T$timing $target >> $output_file

  # Detecta la version de los servicios en los puertos
  nmap -Pn -sV --version-light -F $target >> $output_file

  # Detecta el sistema operativo
  nmap -Pn -O -F $target >> $output_file
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
  run_fast_nmap_scan "$target" &

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
