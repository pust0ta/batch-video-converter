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

fileformats='MTS,mts,MP4,mp4,3GP,3gp,3gpp,AVI,avi,WMV,wmv,MOV,mov,VOB,vob,MPG,mpg,m4v,M4V,ogv,OGV,webm,WEBM'
vcodec='libx264'
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
			ffmpeg -i "$i" -n -metadata data="$DATE" -c:v $vcodec -preset slower -c:a aac -crf $crf "${i%.$extension}.mkv"
			touch -m --date="$DATE" "${i%.$extension}.mkv"
		done
	done
	notify-send "Конвертация завершена в $(date)"
	return 0
}


while getopts "q:t:c:" opt
	do
	case "${opt}" in
		t)	fileformats=$OPTARG;;
		c)  vcodec=$OPTARG;;
		q)	crf=$OPTARG;;
		*)
			usage
			;;
	esac
done
shift $(($OPTIND - 1))

if [ $vcodec == "265" -o $vcodec == "hevc" -o $vcodec == "libx265" ]; then
	vcodec="libx265"
 	if [ ${crf} -eq "20" ]; then
 		crf=25
 	fi
fi

batchVideoConverter $fileformats

exit 0
