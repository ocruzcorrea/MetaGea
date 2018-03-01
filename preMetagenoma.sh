#!/bin/bash

#Instrucciones de uso
if [ $# -eq 0 ];
then
        echo "uso:
    preMetagenoma.sh <IN> <OUT>
donde:
           <IN>: direccion del directorio donde se encuentran
                 las carpetas de muestras donde estan los fastq
          <OUT>: direccion del directorio donde se depositaran
                 las carpetas con archivos fastqc
ejemplo:
    ./preMetagenoma.sh /home/user/proyecto/datosCrudos /home/user/proyecto/datosIntermedios"
        exit
fi

#Alias de variables
DIRin=$1
DIRout=$2
Start=$(pwd)

#Manejo de directorios
mkdir -p $DIRout

#Para cada carpeta dentro del directorio de entrada hacer
for h in $(ls $DIRin); do 
mkdir -p $DIRout/$h
cd $DIRin/$h

# cat de las lecturas R1 y R2
cat $(ls | grep 'fastq\(.gz\)\?$' | grep 'R1') > $DIRout/$h/merged_R1.fastq.gz
cat $(ls | grep 'fastq\(.gz\)\?$' | grep 'R2') > $DIRout/$h/merged_R2.fastq.gz

# hacer overlap de los archivos de lecturas
flash $DIRout/$h/merged_R1.fastq.gz $DIRout/$h/merged_R2.fastq.gz \
-d $DIRout/$h -t 4 -z

# Remover secuencias adaptadoras y regiones de baja calidad
# Modo paired end para lecturas no extendidas
java -jar /usr/local/bin/Trimmomatic-0.36/trimmomatic-0.36.jar PE -threads 4 -phred33 $DIRout/$h/out.notCombined_1.fastq.gz $DIRout/$h/out.notCombined_2.fastq.gz -baseout $DIRout/$h/notCombined.filtered.fastq.gz ILLUMINACLIP:/usr/local/bin/Trimmomatic-0.36/adapters/all_adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# Modo single read para lecturas extendidas
java -jar /usr/local/bin/Trimmomatic-0.36/trimmomatic-0.36.jar SE -threads 4 -phred33 $DIRout/$h/out.extendedFrags.fastq.gz $DIRout/$h/extendedFrags.filtered.fastq.gz ILLUMINACLIP:/usr/local/bin/Trimmomatic-0.36/adapters/all_adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
# regresar al nivel anterior de directorios
#cd ..
done

# regresar al directorio donde se corrio el script
cd $Start
