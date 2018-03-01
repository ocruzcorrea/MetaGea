#!/bin/bash

if [ $# -eq 0 ];
then
        echo "uso:
    combinaKraken.sh <IN> <OUT>
donde:
           <IN>: direccion del directorio donde se encuentran
                 los reportes de resultados de kraken
		 (formato MPA mostrando los organismos con ceros)
          <OUT>: direccion del directorio donde se depositaran
                 los archivos con resultados

ejemplo:
    ./combinaKraken.sh /home/user/proyecto/datosCrudos /home/user/proyecto/Resultados"
        exit
fi

WORKdir=$1
WORKout=$2
Start=$(pwd)

##Manejo de directorios
mkdir -p $WORKout

##Fecha y hora de inicio
echo +++++
echo Analysis started on $(date)

##Cambiar al directorio de entrada
cd $WORKdir

##Loop para cada carpeta que contiene reportes de kraken
for h in $(ls); do
	cd $h

	## Crear carpeta de muestra en el directorio de salida
	mkdir -p $WORKout/$h

	echo +++++
	echo PROCESANDO MUESTRA $h

	echo +++++
	##Combinar reportes de minikraken
	echo Combinando reportes de resultados de kraken. Clasificacion con Minikraken database

	#Crear encabezado (Organismo, nombre de archivo)
	echo Organismo $(basename -s _results.txt -a $(ls *_results.txt)) > $WORKout/$h/minikraken_merged_results.txt

	#Cortar columna de organismos del primer archivo y pegar el numerode secuencias de cada archivo
	awk '{ a[FNR] = (a[FNR] ? a[FNR] FS : $1 FS) $2 } END { for(i=1;i<=FNR;i++) print a[i] }' $(ls *_results.txt) >> $WORKout/$h/minikraken_merged_results.txt

	##Regresar a la carpeta de trabajo
	cd $WORKdir
done

cd $Start

##Fecha y hora de termino
echo Analysis finished on $(date)
