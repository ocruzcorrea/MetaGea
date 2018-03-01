#!/bin/bash

#Instrucciones de uso
if [ $# -eq 0 ];
then
        echo "uso:
    separaHumano.sh <IN> <OUT>
donde:
           <IN>: direccion del directorio donde se encuentran
                 las carpetas de lecturas preprocesadas
          <OUT>: direccion del directorio donde se depositaran
                 las carpetas con lecturas humanas y no humanas
ejemplo:
    ./separaHumano.sh /home/user/proyecto/datosCrudos /home/user/proyecto/datosIntermedios"
        exit
fi

#Alias de variables
DIRin=$1
DIRout=$2
Start=$(pwd)
Ref="/home/ocruz/Public/hg19" #path y bowtie2 reference prefix

#Manejo de directorios
mkdir -p $DIRout

#Para cada carpeta dentro del directorio de entrada hacer
for h in $(ls $DIRin); do 
mkdir -p $DIRout/$h
cd $DIRin/$h
# separar las lecturas humanas y no humanas con bowtie2
# modo paired end para las lecturas pareadas no extendidas con flash
bowtie2 -x $Ref \
-1 $DIRin/$h/notCombined.filtered_1P.fastq.gz \
-2 $DIRin/$h/notCombined.filtered_2P.fastq.gz \
--un-conc-gz $DIRout/$h/notCombined_%P_nothuman.fastq.gz \
--al-conc-gz $DIRout/$h/notCombined_%P_human.fastq.gz \
> $DIRout/$h/notCombined_paired_human.sam

# modo single read para las lecturas no pareadas no extendidas con flash
bowtie2 -x $Ref \
-1 $DIRin/$h/notCombined.filtered_1U.fastq.gz \
-2 $DIRin/$h/notCombined.filtered_2U.fastq.gz \
--un-conc-gz $DIRout/$h/notCombined_%U_nothuman.fastq.gz \
--al-conc-gz $DIRout/$h/notCombined_%U_human.fastq.gz \
> $DIRout/$h/notCombined_unpaired_human.sam

# modo single read para las lecturas extendidas con flash
bowtie2 -x $Ref \
-U $DIRin/$h/extendedFrags.filtered.fastq.gz \
--un-gz $DIRout/$h/extendedFrags_nothuman.fastq.gz \
--al-gz $DIRout/$h/extendedFrags_human.fastq.gz \
> $DIRout/$h/extendedFrags_human.sam

done

# regresar al directorio donde se corrio el script
cd $Start
