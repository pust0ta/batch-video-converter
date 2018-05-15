#!/usr/bin/env bash

#test -n "$1" || exit 1

#if [ -z $* ]; then
#	echo -e "Параметры не обнаружены, укажите расширения видеофайлов через запятую после \"-t\""
#	exit 1
#fi

if [ $# -lt 1 ]; then
	echo -e "Параметры не обнаружены, укажите расширения видеофайлов через запятую после \"-t\" или \"-t all\" для стандартного набора расширений"
	exit 1
fi


usage() { echo "Укажите расширения видеофайлов через запятую после \"-t\"" 1>&2; exit 1; }

#if [ -z "${t}" ]; then
#    usage
#fi

ECHO=/bin/echo
FFMPEG=/usr/bin/ffmpeg


batchVideoConverter() {
	extensions=$1
	notify-send "Конвертация начата в $(date)"
	IFS=$','
	for extension in $extensions; do
		IFS=$'\n'
		$ECHO "Работаем с файлами типа $extension"
		
		for i in $(find -iname "*.$extension"); do
			DATE=`stat -c %y "$i"`
			ffmpeg -i "$i" -metadata data="$DATE" -c:v libx264 -preset slower -c:a aac -crf 20 "${i%.$extension}.mkv"
		done
	done
	notify-send "Конвертация завершена в $(date)"
	return 0
}


while getopts "t:" opt
	do
	case "${opt}" in
		t)
			if [ $OPTARG = "all" ]; then
				batchVideoConverter MTS,mts,MP4,mp4,3GP,3gp,AVI,avi,WMV,wmv,MOV,mov,VOB,vob,MPG,mpg
			else
				batchVideoConverter $OPTARG
			fi
			;;
		*)
			usage
			;;
	esac
done
