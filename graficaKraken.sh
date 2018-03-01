#!/bin/bash

if [ $# -eq 0 ];
then
        echo "uso:
    graficaKraken.sh <IN> <OUT>
donde:
           <IN>: direccion del directorio donde se encuentran
                 las carpetas de resultados de kraken unidas
          <OUT>: direccion del directorio donde se depositaran
                 los archivos con graficas

ejemplo:
    ./graficaKraken.sh /home/user/proyecto/datosCrudos /home/user/proyecto/Resultados"
        exit
fi

WORKdir=$1
WORKout=$2
Start=$(pwd) #En esta ruta debe estar plot_mergedKraken.R el cual es llamado

##Manejo de directorios
mkdir -p $WORKout

##Fecha y hora de inicio
echo +++++
echo Analysis started on $(date)

##Cambiar al directorio de entrada
cd $WORKdir

##Loop para cada carpeta que contiene archivos de lecturas
for h in $(ls); do
        cd $h

        ## Crear carpeta de muestra en el directorio de salida
        mkdir -p $WORKout/$h

        echo +++++
        echo PROCESANDO MUESTRA $h

        echo +++++
        echo Graficando resultados de kraken
        cd $WORKout/$h
        R --vanilla --slave --args $WORKdir/$h/minikraken_merged_results.txt $h < $Start/plot_mergedKraken.R

        ##Regresar a la carpeta de trabajo
        cd $WORKdir
done

cd $Start

##Fecha y hora de termino
echo Analysis finished on $(date)
