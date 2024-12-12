## Requisitos
Script para analisis de Nmap para sistemas operativos Linux

Para ejecturar TriScan lo primero que necesitas descargar los archivos necesarios, en caso de no tener git instalarlo primero
```
git clone https://github.com/HaroldGlitch/TriScan.git
```

Luego de esto dentro de la carpeta de TriScan se ejecuta el archivo con los requisitos con privilegios de administrados
```
cd TriScan
```
```
sudo chmod +x ./requirements.sh
```
```
sudo ./requirements.sh
```

Luego de esto dentro de la carpeta de TriScan se ejecuta el archivo con los requisitos con privilegios de administrados

```
sudo ./run.sh
```

## Manual de uso
**requirements.sh**
    - Es el que se encarga de instalar los requirimientos minimos para el correcto funcionamiento del proyecto

**run.sh**
    - Script principal desde donde se realiazan los escaneos

**fast_scan.sh**
    - Realiza un escaneo rapido de los 1000 primeros puertos a los equipos encontrados
	
**complete_scan.sh**
    - Realiza un escaneo de todos los equipos encontrados con sus respectivas vulnerabilidades, puede tardar un tiempo en ejecutarse debido a la naturaleza del escaneo

**stealthy.sh**
    - Realiza un escaneo sigiloso de los 1000 primeros puertos, para evitar los IDS/IPD, puede tardar un tiempo en ejecutarse debido a la naturaleza del escaneo
