#!/bin/bash
CURDIR=$(pwd)
source config.sh
source utils.sh
source docs.sh
source chet.sh
source akt.sh
source agents.sh
source props.sh

function mainMenu {
	OPTION=$(whiptail --title  "Система управения документами" --menu  "Доступные операции" 20 60 12 \
	"agents" "Контрагенты (Заказчики)" \
	"docs" "Документы" \
	"props" "Реквизиты" \
	"custom" "Настройки" \
	3>&1 1>&2 2>&3)
}

function mainFunctions {
	exitstatus=$?
	if [ $exitstatus = 0 ];  then
		echo "Выбор меню: "$OPTION
	fi
}

function main {
	estatus=0
	##echo $CURDIR
	while [ $estatus = 0 ]
	do
		mainMenu
		estatus=$?
		##echo "Статус операции "$estatus
		if [ $estatus = 1 ];  then
			exit
		fi

    exitagents=0
		if [ $OPTION = "agents" ];  then
			while [ $exitagents = 0 ]
			do
				agentsMenu
				exitagents=$?
				if [ $exitagents = 0 ];  then
					agentsFunctions
				fi
			done
			continue
		fi

    exitprops=0
		if [ $OPTION = "props" ];  then
			while [ $exitprops = 0 ]
			do
				propsMenu
				exitprops=$?
				if [ $exitprops = 0 ];  then
					propsFunctions
				fi
			done
			continue
		fi

		if [ $OPTION = "custom" ];  then
		  editDoc config.sh "Настройки"
			continue
		fi

    exitdocs=0
		if [ $OPTION = "docs" ];  then
			while [ $exitdocs = 0 ]
			do
				docsMenu
				exitdocs=$?
				if [ $exitdocs = 0 ];  then
					docsFunctions
					##presskey
					##exit
				fi
			done
			continue
		fi
		mainFunctions
	done
}
main
