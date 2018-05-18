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

fileformats=''
crf=20

batchVideoConverter() {
	extensions=$1
	notify-send "Конвертация начата в $(date)"
	IFS=$','
	for extension in $extensions; do
		IFS=$'\n'
		$ECHO  -en "\033[1;31mРаботаем с файлами типа $extension"
		tput sgr0;
		$ECHO
		
		for i in $(find -name "*.$extension"); do
			DATE=`stat -c %y "$i"`
			ffmpeg -i "$i" -n -metadata data="$DATE" -c:v libx264 -preset slower -c:a aac -crf $crf "${i%.$extension}.mkv"
		done
	done
	notify-send "Конвертация завершена в $(date)"
	return 0
}


while getopts "q:t:" opt
	do
	case "${opt}" in
		t)
			if [ $OPTARG = "all" ]; then
				fileformats='MTS,mts,MP4,mp4,3GP,3gp,AVI,avi,WMV,wmv,MOV,mov,VOB,vob,MPG,mpg,m4v,M4V,ogv,OGV,webm,WEBM'
			else
				fileformats=$OPTARG
			fi
			;;
		q)	crf=$OPTARG;;
		*)
			usage
			;;
	esac
done
shift $(($OPTIND - 1))

batchVideoConverter $fileformats

exit 0
