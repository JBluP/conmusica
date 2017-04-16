#!/usr/bin/bash

#limpio la terminal
clear

#muestro el selector de archivos
archivo=`zenity --title="Seleccionar archivos" --file-selection --multiple`
if [ "$?" = 1 ]; then
       exit
fi

#obtengo la ruta de la carpeta
url=$(echo $archivo | cut -d "|" -f 1)

cont=0

#muestro las opciones de conversión
while [ $cont -ne 1 ]; do
form=$(zenity --forms --title="Opciones de conversión" --add-combo="Sample Rate" --combo-values="8000|22050|32000|44100|47250|48000|50000|96000|192400" --add-combo="Bitrate" --combo-values="4k|8k|32k|48k|64k|80k|96k|112k|128k|160k|192k|224k|256k|320k" --add-combo="Pasarlo a: " --combo-values=".mp3|.mp4|.ogg|.aac" --text="Seleccionar Sample Rate, Bitrate y Formato del archivo")
case $? in
	0)
		samplerate=$(echo $form | cut -d "|" -f 1)
		bitrate=$(echo $form | cut -d "|" -f 2)
		tipoarchivo=$(echo $form | cut -d "|" -f 3)
		
		#verifico que las opciones no esten vacias
		if [ -z $samplerate ] || \
		   [ -z $bitrate ] || \
		   [ -z $tipoarchivo ]; then

		       #muestro un mensaje de error en pantalla
		       zenity --error --text="Hay opciones sin seleccion"
	       	       cont=0
		     
		else
			#si todas las opciones estan cargadas pongo a cont en 1 y el while sale
		       cont=1	
       		fi;;
	1)
		#si presiono el boton de cancelar salgo del programa
 		exit ;;
esac		
	 
done

#muestro el selector de archivos para elegir la carpeta de destino
#con la opcion --directory solo puedo elegir carpetas
salida=`zenity --title="Seleccionar carpeta de destino" --file-selection --filename="$url" --directory`
if [ "$?" = 1 ]; then
	exit
fi

#le digo al for que el separador es la |
IFS="|"

for int in $archivo; do

	#me quedo solo con el nombre de la pista original
	nompista=$(echo $(basename "$int"))

	#con las siguientes lineas le saco la extencion al archivo
	
	#saco el largo de la cadena de la pista
	largonompista=${#nompista}
	
	#le resto 4 al largo total de la pista para poder borrar la extencion
	let total=$largonompista-4
	
	#obtengo el nombre de la pista sin su extencion
	newpista=$(echo $nompista | cut -c 1-$total)
	
	#le paso a ffmpeg los archivos a cambiar
	ffmpeg -i $int -ar $samplerate -b:a $bitrate "$salida/$newpista$tipoarchivo" 
done
