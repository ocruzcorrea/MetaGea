#! /bin/bash

#Instrucciones de uso
if [ $# -eq 0 ];
then
        echo "uso:
    calidadCarpetaSecuencias.sh <IN> <OUT>
donde:
           <IN>: direccion del directorio donde se encuentran
                 los archivos fastq que se quieren analizar
          <OUT>: direccion del directorio donde se depositaran
                 los archivos de fastqc
ejemplo:
    ./calidadCarpetaSecuencias.sh /home/user/proyecto/datosCrudos /home/user/proyecto/datosIntermedios"
        exit
fi

#Alias de variables
WORKdir=$1
WORKout=$2
Start=$(pwd)

#Manejo de directorios
mkdir -p $WORKout

#Hacer fastqc para cada archivo fastq dentro del directorio de entrada
cd $WORKdir
fastqc $(ls | grep 'fastq\(.gz\)\?$') -o $WORKout

#Regresar al lugar desde donde se corrio
cd $Start
