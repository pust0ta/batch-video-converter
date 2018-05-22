#!/usr/bin/env bash

#test -n "$1" || exit 1

#if [ -z $* ]; then
#	echo -e "Параметры не обнаружены, укажите расширения видеофайлов через запятую после \"-t\""
#	exit 1
#fi

#if [ $# -lt 1 ]; then
#	echo -e "Параметры не обнаружены, запуск со параметрами по умолчанию. \n укажите расширения видеофайлов через запятую после \"-t\", \"-c\" для выбора кодека, \"-q\" для указания crf (18-30), \"-p\" для выбора пресета ffmpeg"
#	exit 1
#fi


usage() { echo "Укажите расширения видеофайлов через запятую после \"-t\"" 1>&2; exit 1; }

#if [ -z "${t}" ]; then
#    usage
#fi

ECHO=/bin/echo
FFMPEG=/usr/bin/ffmpeg

maxdepth=10
#findcommand=`find -name "*.$extension"`
fileformats='MTS,mts,MP4,mp4,3GP,3gp,3gpp,AVI,avi,WMV,wmv,MOV,mov,VOB,vob,MPG,mpg,m4v,M4V,ogv,OGV,webm,WEBM'
#vcodec='libx264'
vcodec='libx265'
crf=20
crfisset="FALSE"
preset="slow"
presetisset="FALSE"

batchVideoConverter() {
	extensions=$1
	notify-send "Конвертация начата в $(date)"
	IFS=$','
	for extension in $extensions; do
		IFS=$'\n'
		$ECHO  -en "\033[1;31mРаботаем с файлами типа $extension"
		tput sgr0;
		$ECHO
		
		for i in $(find -maxdepth $maxdepth -name "*.$extension"); do
			DATE=`stat -c %y "$i"`
			ffmpeg -i "$i" -n -metadata data="$DATE" -c:v $vcodec -preset $preset -c:a aac -crf $crf "${i%.$extension}.mkv"
			touch -m --date="$DATE" "${i%.$extension}.mkv"
		done
	done
	notify-send "Конвертация завершена в $(date)"
	return 0
}


while getopts "q:t:c:p:d:" opt
	do
	case "${opt}" in
		c)	vcodec=$OPTARG;;
		d)	maxdepth=$OPTARG;;
		p)	userpreset=$OPTARG
			presetisset="TRUE"
			;;
		t)	fileformats=$OPTARG;;
		q)	usercrf=$OPTARG
			crfisset="TRUE"
			;;
		*)
			usage
			;;
	esac
done
shift $(($OPTIND - 1))

if [ $vcodec == "265" -o $vcodec == "hevc" -o $vcodec == "libx265" ]; then
	vcodec="libx265"
	preset="slow"
	if [ ${presetisset} == "TRUE" ]; then
		preset=$userpreset
	fi
	crf=25
	if [ ${crfisset} == "TRUE" ]; then
		crf=$usercrf
	fi
fi

if [ $vcodec == "264" -o $vcodec == "libx264" ]; then
	vcodec="libx264"
	preset="slower"
	if [ ${presetisset} == "TRUE" ]; then
		preset=$userpreset
	fi
	crf=25
	if [ ${crfisset} == "TRUE" ]; then
		crf=$usercrf
	fi
fi

batchVideoConverter $fileformats

exit 0
