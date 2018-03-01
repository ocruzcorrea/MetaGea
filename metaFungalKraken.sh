#!/bin/bash

if [ $# -eq 0 ];
then
        echo "uso:
    metaFungalKraken.sh <IN> <OUT>
donde:
           <IN>: direccion del directorio donde se encuentran
                 las carpetas de lecturas pre-procesadas
		 (con flash trimmomatic y bowtie para remover humano)
          <OUT>: direccion del directorio donde se depositaran
                 los archivos con resultados

ejemplo:
    ./metaFungalKraken.sh ~/Xserver/proyecto/datosCrudos ~/Xserver/proyecto/Resultados"
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
	echo Clasificacion con fungal database
	echo +++++
	##Clasificar con MiniFungal como single reads con Minikraken las lecturas extendidas y no combinadas no pareadas (no humanas)
	$krakenDir/kraken --db $krakenDBdir/minifungal --threads 4 --fastq-input --gzip-compressed --preload --unclassified-out $WORKout/$h/extendedFrags_nofungal.fastq --classified-out $WORKout/$h/extendedFrags_fungal.fastq extendedFrags_nothuman.fastq.gz > $WORKout/$h/extendedFrags_fungalsequences.kraken
	$krakenDir/kraken --db $krakenDBdir/minifungal --threads 4 --fastq-input --gzip-compressed --preload --unclassified-out $WORKout/$h/notCombined_1U_nofungal.fastq --classified-out $WORKout/$h/notCombined_1_fungal.fastq notCombined_1U_nothuman.fastq.gz > $WORKout/$h/notCombined_1U_fungalsequences.kraken
	$krakenDir/kraken --db $krakenDBdir/minifungal --threads 4 --fastq-input --gzip-compressed --preload --unclassified-out $WORKout/$h/notCombined_2U_nofungal.fastq --classified-out $WORKout/$h/notCombined_2_fungal.fastq notCombined_2U_nothuman.fastq.gz > $WORKout/$h/notCombined_2U_fungalsequences.kraken
	##Clasificar como paired reads con Minikraken las lecturas no combinadas pareadas (no humanas)
	$krakenDir/kraken --db $krakenDBdir/minifungal --threads 4 --fastq-input --gzip-compressed --preload --paired --unclassified-out $WORKout/$h/notCombined_P_nofungal.fastq --classified-out $WORKout/$h/notCombined_P_fungal.fastq notCombined_1P_nothuman.fastq.gz notCombined_2P_nothuman.fastq.gz > $WORKout/$h/notCombined_P_fungalsequences.kraken

	echo +++++
	echo Generar reporte de resultados de Fungal
	#Para unir los archivos facilmente se utiliza una clasificacion completa con la opcion --show-zeros
	$krakenDir/kraken-mpa-report --db $krakenDBdir/minifungal --show-zeros $WORKout/$h/extendedFrags_fungalsequences.kraken > $WORKout/$h/extendedFrags_fungal_results.txt
	$krakenDir/kraken-mpa-report --db $krakenDBdir/minifungal --show-zeros $WORKout/$h/notCombined_1U_fungalsequences.kraken > $WORKout/$h/notCombined_1U_fungal_results.txt
	$krakenDir/kraken-mpa-report --db $krakenDBdir/minifungal --show-zeros $WORKout/$h/notCombined_2U_fungalsequences.kraken > $WORKout/$h/notCombined_2U_fungal_results.txt
	$krakenDir/kraken-mpa-report --db $krakenDBdir/minifungal --show-zeros $WORKout/$h/notCombined_P_fungalsequences.kraken > $WORKout/$h/notCombined_P_fungal_results.txt

	echo +++++
	echo Clasificacion con Minikraken database
	echo +++++
	##Clasificar con Minikraken las lecturas extendidas y combinadas no clasificadas
	$krakenDir/kraken --db $krakenDBdir/minikraken_20141208 --threads 4 --fastq-input --preload --unclassified-out $WORKout/$h/extendedFrags_unclass.fastq --classified-out $WORKout/$h/extendedFrags_minikraken.fastq $WORKout/$h/extendedFrags_nofungal.fastq > $WORKout/$h/extendedFrags_minikrakensequences.kraken
	$krakenDir/kraken --db $krakenDBdir/minikraken_20141208 --threads 4 --fastq-input --preload --unclassified-out $WORKout/$h/notCombined_1U_unclass.fastq --classified-out $WORKout/$h/notCombined_1_minikraken.fastq $WORKout/$h/notCombined_1U_nofungal.fastq > $WORKout/$h/notCombined_1U_minikrakensequences.kraken
	$krakenDir/kraken --db $krakenDBdir/minikraken_20141208 --threads 4 --fastq-input --preload --unclassified-out $WORKout/$h/notCombined_2U_unclass.fastq --classified-out $WORKout/$h/notCombined_2_minikraken.fastq $WORKout/$h/notCombined_2U_nofungal.fastq > $WORKout/$h/notCombined_2U_minikrakensequences.kraken
	$krakenDir/kraken --db $krakenDBdir/minikraken_20141208 --threads 4 --fastq-input --preload --unclassified-out $WORKout/$h/notCombined_P_unclass.fastq --classified-out $WORKout/$h/notCombined_P_minikraken.fastq $WORKout/$h/notCombined_P_nofungal.fastq > $WORKout/$h/notCombined_P_minikrakensequences.kraken

	echo +++++
	echo Generar reporte de resultados de Minikraken
        $krakenDir/kraken-mpa-report --db $krakenDBdir/minikraken_20141208 --show-zeros $WORKout/$h/extendedFrags_minikrakensequences.kraken > $WORKout/$h/extendedFrags_minikraken_results.txt
        $krakenDir/kraken-mpa-report --db $krakenDBdir/minikraken_20141208 --show-zeros $WORKout/$h/notCombined_1U_minikrakensequences.kraken > $WORKout/$h/notCombined_1U_minikraken_results.txt
        $krakenDir/kraken-mpa-report --db $krakenDBdir/minikraken_20141208 --show-zeros $WORKout/$h/notCombined_2U_minikrakensequences.kraken > $WORKout/$h/notCombined_2U_minikraken_results.txt
	$krakenDir/kraken-mpa-report --db $krakenDBdir/minikraken_20141208 --show-zeros $WORKout/$h/notCombined_P_minikrakensequences.kraken > $WORKout/$h/notCombined_P_minikraken_results.txt

	##Regresar a la carpeta de trabajo
	cd $WORKdir
done

#Regresar a la carpeta de scripts
cd $Start

##Fecha y hora de termino
echo Analysis finished on $(date)
