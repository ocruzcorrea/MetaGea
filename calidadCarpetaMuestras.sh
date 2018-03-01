#! /bin/bash

#Instrucciones de uso
if [ $# -eq 0 ];
then
        echo "uso:
    calidadCarpetaMuestras.sh <IN> <OUT>
donde:
           <IN>: direccion del directorio donde se encuentran
                 las carpetas de muestras donde estan los fastq
          <OUT>: direccion del directorio donde se depositaran
                 las carpetas con archivos fastqc
ejemplo:
    ./calidadCarpetaMuestras.sh /home/user/proyecto/datosCrudos /home/user/proyecto/datosIntermedios"
        exit
fi

#Alias de variables
WORKdir=$1
WORKout=$2
Start=$(pwd)

#Manejo de directorios
mkdir -p $WORKout

#Hacer calidadCarpetaSecuencias.sh para cada carpeta dentro del directorio de entrada
for h in $(ls $WORKdir); do ./calidadCarpetaSecuencias $(dirname $WORKdir)/$h $WORKout/$h
