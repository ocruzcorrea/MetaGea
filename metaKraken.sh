#!/bin/bash

if [ $# -eq 0 ];
then
        echo "uso:
    metaKraken.sh <IN> <OUT>
donde:
           <IN>: direccion del directorio donde se encuentran
                 las carpetas de lecturas pre-procesadas
		 (con flash trimmomatic y bowtie para remover humano)
          <OUT>: direccion del directorio donde se depositaran
                 los archivos con resultados

ejemplo:
    ./metaKraken.sh /home/user/proyecto/datosCrudos /home/user/proyecto/Resultados"
        exit
fi

WORKdir=$1
WORKout=$2
Start=$(pwd)

##Informacion de rutas del programa Kraken y las bases de datos
krakenDir="/usr/local/kraken"
krakenDBdir="/export/home/ocruz"

##Manejo de directorios
mkdir -p $WORKout

##Fecha y hora de inicio
echo +++++
echo Analysis started on $(date)

##Cambiar al directorio de carpetas de lecturas pre-procesadas
cd $WORKdir

##Loop para cada carpeta que contiene archivos de lecturas
for h in $(ls); do
	cd $h

	## Crear carpeta de muestra en el directorio de salida
	mkdir -p $WORKout/$h

	echo +++++
	echo PROCESANDO MUESTRA $h

	echo +++++
	echo Clasificacion con Minikraken database
	##Clasificar como single reads con Minikraken las lecturas extendidas y no combinadas no pareadas (no humanas)
	$krakenDir/kraken --db $krakenDBdir/minikraken_20141208 --threads 4 --fastq-input --gzip-compressed --preload --unclassified-out $WORKout/$h/extendedFrags_unclass.fastq --classified-out $WORKout/$h/extendedFrags_minikraken.fastq extendedFrags_nothuman.fastq.gz > $WORKout/$h/extendedFrags_minikrakensequences.kraken
	$krakenDir/kraken --db $krakenDBdir/minikraken_20141208 --threads 4 --fastq-input --gzip-compressed --preload --unclassified-out $WORKout/$h/notCombined_1U_unclass.fastq --classified-out $WORKout/$h/notCombined_1_minikraken.fastq notCombined_1U_nothuman.fastq.gz > $WORKout/$h/notCombined_1U_minikrakensequences.kraken
	$krakenDir/kraken --db $krakenDBdir/minikraken_20141208 --threads 4 --fastq-input --gzip-compressed --preload --unclassified-out $WORKout/$h/notCombined_2U_unclass.fastq --classified-out $WORKout/$h/notCombined_2_minikraken.fastq notCombined_2U_nothuman.fastq.gz > $WORKout/$h/notCombined_2U_minikrakensequences.kraken
	##Clasificar como paired reads con Minikraken las lecturas no combinadas pareadas (no humanas)
	$krakenDir/kraken --db $krakenDBdir/minikraken_20141208 --threads 4 --fastq-input --gzip-compressed --preload --paired --unclassified-out $WORKout/$h/notCombined_P_unclass.fastq --classified-out $WORKout/$h/notCombined_P_minikraken.fastq notCombined_1P_nothuman.fastq.gz notCombined_2P_nothuman.fastq.gz > $WORKout/$h/notCombined_P_minikrakensequences.kraken

	echo +++++
	echo Generar reporte de resultados de Minikraken
        $krakenDir/kraken-mpa-report --db $krakenDBdir/minikraken_20141208 --show-zeros $WORKout/$h/extendedFrags_minikrakensequences.kraken > $WORKout/$h/extendedFrags_minikraken_results.txt
        $krakenDir/kraken-mpa-report --db $krakenDBdir/minikraken_20141208 --show-zeros $WORKout/$h/notCombined_1U_minikrakensequences.kraken > $WORKout/$h/notCombined_1U_minikraken_results.txt
        $krakenDir/kraken-mpa-report --db $krakenDBdir/minikraken_20141208 --show-zeros $WORKout/$h/notCombined_2U_minikrakensequences.kraken > $WORKout/$h/notCombined_2U_minikraken_results.txt
	$krakenDir/kraken-mpa-report --db $krakenDBdir/minikraken_20141208 --show-zeros $WORKout/$h/notCombined_P_minikrakensequences.kraken > $WORKout/$h/notCombined_P_minikraken_results.txt

	##Unir archivos de resultados de kraken (Considerando que las lecturas extendidas son el doble de las lecturas no combinadas)
	##Se especifica un patron en el nombre de archivo el cual indica los resultados a combinar
	##Las columnas estan especificadas por los primeros 13 caracteres de los nombres de archivos (excepto el primero que no tiene especificacion)
	##Si se utilizan como estan definidos los nombres de archivos la primera columna corresponde a las lecturas flasheadas y las demas a las no combinadas
	echo +++++
	echo Combinando reportes de resultados
	cd $WORKout/$h
	R --vanilla --slave --args minikraken_results.txt < /export/home/ocruz/RNA_test/Scripts/combine_kraken.R

	##Regresar a la carpeta de trabajo
	cd $WORKdir
done

cd $Start

##Fecha y hora de termino
echo Analysis finished on $(date)
