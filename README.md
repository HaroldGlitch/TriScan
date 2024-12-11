## Requisitos
Script para analisis de Nmap para sistemas operativos Linux

Para ejecturar TriScan lo primero que necesitas es tener wget instalado, si no lo tienes instalado utiliza el siguiente comando:

```
apt-get install wget
```

Una vez instalado se utiliza wget para descargar los archivos necesarios

```
wget https://drive.google.com/drive/folders/1ZOo7SnJ-1AlabS6oMLmtmxckez-Sn78z?usp=sharing
```

Luego de esto dentro de la carpeta de TriScan se ejecuta el archivo con los requisitos con privilegios de administrados

```
sudo ./requirements.sh
```

Luego de esto ya se podrautilizar el comando run cada vez que sea necesario para el analisis de la red

```
sudo ./run.sh
```
