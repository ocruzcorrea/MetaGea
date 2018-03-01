### Inicio del archivo plot_mergedKraken
### Este script obtiene y grafica las abundancias relativas obtenidas de kraken
### Tambien obtiene una tabla de as abundancias relativas
### Utiliza resultados provenientes de 1 reporte formato MPA combinados (Flash extended, notComb1, notComb2, notCombP)
### Uso: R --vanilla --slave --args archivo < combine.kraken.R
### donde: <archivo> : El archivo con resultados combinados que se desea analizar y graficar

### Usar argumentos de la linea de comandos
# Primer argumento el archivo de resultados de kraken merged que se va a graficar
fl <- commandArgs(trailingOnly=TRUE)[1]
# Segundo argumento patron que se anadira al nombre del archivo con las graficas
nom <- commandArgs(trailingOnly=TRUE)[2]

### Leer archivo con kraken merged results
tabla <- read.table(fl,header=TRUE,fill=TRUE,colClasses=c("character",rep("numeric",times=8)))

### Cambiar NAs por 0 en las columnas que no sean Organismo
tabla[,-1][is.na(tabla[,-1])] <- 0

### Remover de la tabla los organismos que no tienen ninguna lectura
tabla = tabla[rowSums(tabla[,-1])!=0,]

### Ordenar tabla por Taxonomy
tabla <- tabla[order(tabla$Organismo),]

###Expand Taxonomy information in a new matrix, remove NAs y caracteres raros
#(D)omain, (K)ingdom, (P)hylum, (C)lass, (O)rder, (F)amily, (G)enus, or (S)pecies

taxo <- matrix(nrow=dim(tabla)[1],ncol=8,dimnames=list(NULL,c("Domain","Kingdom","Phylum","Class","Order","Family","Genus","Species")))
pattern <- "d__[[:alpha:]]+"; m <- regexpr(pattern, tabla$Organismo); l <- grep(pattern,tabla$Organism); taxo[l,"Domain"] <- regmatches(tabla$Organismo,m)
pattern <- "k__[[:alpha:]]+"; m <- regexpr(pattern, tabla$Organismo); l <- grep(pattern,tabla$Organism); taxo[l,"Kingdom"] <- regmatches(tabla$Organismo,m)
pattern <- "p__[[:alpha:]]+"; m <- regexpr(pattern, tabla$Organismo); l <- grep(pattern,tabla$Organism); taxo[l,"Phylum"] <- regmatches(tabla$Organismo,m)
pattern <- "c__[[:alpha:]]+"; m <- regexpr(pattern, tabla$Organismo); l <- grep(pattern,tabla$Organism); taxo[l,"Class"] <- regmatches(tabla$Organismo,m)
pattern <- "o__[[:alpha:]]+"; m <- regexpr(pattern, tabla$Organismo); l <- grep(pattern,tabla$Organism); taxo[l,"Order"] <- regmatches(tabla$Organismo,m)
pattern <- "f__[[:alpha:]]+"; m <- regexpr(pattern, tabla$Organismo); l <- grep(pattern,tabla$Organism); taxo[l,"Family"] <- regmatches(tabla$Organismo,m)
pattern <- "g__[[:alpha:]]+"; m <- regexpr(pattern, tabla$Organismo); l <- grep(pattern,tabla$Organism); taxo[l,"Genus"] <- regmatches(tabla$Organismo,m)
pattern <- "s__[[:graph:]]+"; m <- regexpr(pattern, tabla$Organismo); l <- grep(pattern,tabla$Organism); taxo[l,"Species"] <- regmatches(tabla$Organismo,m)
taxo[is.na(taxo)] <- ""
taxo <- gsub("[dkpcofgs]__","",taxo)

### Unir la matrix de Taxonomia con la tabla original
kraken <- cbind(taxo,tabla)

### Obtener el total de lecturas, considerando dobles las extendidas con flash y las pareadas
pesos <- c(2,1,1,2)
kraken$Abundancia <- kraken$extendedFrags_fungal*pesos[1] + kraken$extendedFrags_minikraken*pesos[1] + kraken$notCombined_1U_fungal*pesos[2] + kraken$notCombined_1U_minikraken*pesos[2] + kraken$notCombined_2U_fungal*pesos[3] + kraken$notCombined_2U_minikraken*pesos[3] + kraken$notCombined_P_fungal*pesos[4] + kraken$notCombined_P_minikraken*pesos[4]

### Ordenar por abundancia
kraken <- kraken[order(kraken$Abundancia,decreasing=TRUE),]

### Remover las taxonomias soportadas solo por una lectura no pareada o extendida
kraken <- kraken[kraken$Abundancia>1,]

### Cambiar dominio "Viruses" por "Virus"
kraken$Domain <- as.factor(gsub("Viruses","Virus",kraken$Domain))

### Obtener datos para el plot abundances according to rank code
### Recordar que las lecturas contribuyen a varios niveles de clasificacion
### Recordar que aqui no aparecen las lecturas sin clasificar
# Filtros, (D)omain, (K)ingdom, (P)hylum, (C)lass, (O)rder, (F)amily, (G)enus, (S)pecies
d <- kraken$Domain!="" 
k <- kraken$Kingdom!=""
p <- kraken$Phylum!=""
c <- kraken$Class!=""
o <- kraken$Order!=""
f <- kraken$Family!=""
g <- kraken$Genus!=""
s <- kraken$Species!=""

# Maximo numero de resultados
Nmax <- 40
# Minimo de abundancia para graficar
Amin <- 1e-3

# Graficas (las graficas indispensables se consideran Species y Phylum)

#Grafica de Species
png(filename=paste(nom,"_SpeciesPlot.png",sep=""),width=560,height=560,units="px",pointsize=16)
pl <- kraken[s,]
pl$Abundancia <- pl$Abundancia/sum(pl$Abundancia); par(mar=c(13,4,2,0.5)); pl <- pl[pl$Abundancia>Amin,]
barplot(pl[1:min(dim(pl)[1],Nmax),"Abundancia"],ylab="Abundancia relativa",col=rainbow(length(levels(pl$Domain)))[pl[1:min(dim(pl)[1],Nmax),"Domain"]],
names.arg=gsub("_"," ",pl[1:min(dim(pl)[1],Nmax),"Species"]),cex.names=0.7,cex.axis=0.9,las=2,font.axis=3,
border=NA,ylim=c(0,max(pretty(pl$Abundancia))),main="Clasificación a nivel de especie")
legend("right",col=rainbow(length(levels(pl$Domain))),legend=levels(pl$Domain),pch=15)
dev.off()

#Tabla de Species
write.table(pl,file=paste(nom,"_SpeciesTable.txt",sep=""),sep="\t",col.names=TRUE,row.names=FALSE)

# Grafica de Phylum
png(filename=paste(nom,"_PhylumPlot.png",sep=""),width=560,height=560,units="px",pointsize=16)
pl <- kraken[p&!c&!o&!f&!g&!s,]
pl$Abundancia <- pl$Abundancia/sum(pl$Abundancia); par(mar=c(7,4,2,0.5)); pl <- pl[pl$Abundancia>Amin,]
barplot(pl[1:min(dim(pl)[1],Nmax),"Abundancia"],ylab="Abundancia relativa",col=rainbow(length(levels(pl$Domain)))[pl[1:min(dim(pl)[1],Nmax),"Domain"]],
names.arg=gsub("_"," ",pl[1:min(dim(pl)[1],Nmax),"Phylum"]),cex.names=0.7,cex.axis=0.9,las=2,font.axis=3,
border=NA,ylim=c(0,max(pretty(pl$Abundancia))),main="Calsificación a nivel de phylum")
legend("right",col=rainbow(length(levels(pl$Domain))),legend=levels(pl$Domain),pch=15)
dev.off()

#Tabla de Phylum
write.table(pl,file=paste(nom,"_PhylumTable.txt",sep=""),sep="\t",col.names=TRUE,row.names=FALSE)
