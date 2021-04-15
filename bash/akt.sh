declare -A newAkt
newAkt[ДатаДокумента]='ДатаДокумента'
##newChet[Реквизиты]="Номер реквизитов компании"
##newChet[КонтрАгент]="Номер реквизиты заказчика"
newAkt[Комментарий]='Комментарий'

function addAkt {
		##head "Добавить счет"
		##newChet[НомерДокумента]='Номер Документа'
		local NUM=$(getLastDoc $AKT_PATH)
		let "NUM=NUM + 1"
		local str=$(whiptail --title  "Новый акт" --inputbox  "НомерДокумента" 10 60 "$NUM" 3>&1 1>&2 2>&3)
	  #if [ $CUST = "НомерДокумента" ]; then
	  local NUMDOC=$str
	  local akt_path=${AKT_PATH}${NUMDOC}".conf"
	  echo "Файл акта: "$akt_path
	  echo "НомерДокумента="$str > $akt_path

	  local CHET=$(getChet)
    echo "НомерСчета="$CHET >> $akt_path

		for CUST in "${!newChet[@]}";
		do
		  text=${newAkt[$CUST]}
			str=$(whiptail --title  "Новый акт №$NUMDOC" --inputbox  "$text" 10 60 "" 3>&1 1>&2 2>&3)
		  echo $CUST"="$str>>$akt_path
		done
	  presskey
}

function getAkt {
	cd $AKT_PATH
	local path1=$(getConfFiles)
	local res=""
	local i=0
	local arr=()
	local fileagent;

	for entry in $path1
	do
	  CHET=$(getDocProp ${entry} 'НомерСчета')
	  ##CHET=$CHET".conf"
	  ##echo "НомерСчета"$CHET
	  NUM=$(getNum $entry)
	  AGENT=$(getDocProp ${CHET_PATH}${CHET}".conf" 'КонтрАгент')
	  fileagent=${AGENTS_PATH}${AGENT}".conf"

	  AGENTNAME=$(getDocProp ${fileagent} 'НазваниеКонтр')
		text=$(getDateDoc ${entry})
		arr[i]=$NUM
		if [ "$text" ];  then
		  arr[i+1]="${text} ${AGENTNAME}"
		else
		 arr[i+1]=[???]
		fi
##		arr[i+2]="OFF"
		((i+=2))
	done

	AKT=$(whiptail --title  "Выбор акта" --menu \
	"Выберите акт?" 20 60 12 "${arr[@]}" 3>&1 1>&2 2>&3)
	exitstatus=$?
	cd ${CURDIR}
	##echo "Статус выбора проекта "$exitstatus
	echo $AKT
}

function viewAkt() {
    AKT=$(getAkt)
    echo ""
    head "Акт №"$AKT
    AKT=${AKT_PATH}${AKT}".conf"
    CHET=$(getDocProp ${AKT} 'НомерСчета')

    cat ${AKT}
    echo ""
    head "Фактурная часть:"
    text=""
    for ((i=1; i <= 5; i++))
    do
      text=${text}" |"${newWork[$i]}
    done
    text=${text}" |Сумма"
    echo $text
    blueLine
    cat ${CHET_PATH}${CHET}".csv"
    echo ""
}

function deleteAkt() {
    local AKT=$(getAkt)
    echo "Удаляется документ "$AKT
    presskey
    rm -f ${AKT_PATH}${AKT}".conf"
}

declare -A editAktArr
editAktArr[1]='ДатаДокумента'
editAktArr[2]='Комментарий'

function editAkt() {
##  NUM=$1
  local i=0
  local NUM=$(getAkt)
  local file=${AKT_PATH}${NUM}".conf"
	exitstatus=0
	while [ $exitstatus = 0 ]
	do
    local arr=()
    local array;
    for ((j=1; j <= 2; j++))
    do
      if [ -f $file ]; then
        IN=$(cat $file | grep ${editAktArr[$j]})
        IFS='=' read -r -a array <<< "$IN"
        text=${array[1]}
      fi
      arr[i]=${editAktArr[$j]}
      if [ "$text" ];  then
        arr[i+1]="${text}"
      else
       arr[i+1]=[???]
      fi
      ##arr[i+2]="OFF"
      ((i+=2))
    done
    PROPS=$(whiptail --title  "Настройка акта" --menu \
    "Выберите настройку:" 23 60 17 "${arr[@]}" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
      local text=""
      if [ -f $file ]; then
        IN=$(cat $file | grep $PROPS)
        IFS='=' read -r -a array <<< "$IN"
        text=${array[1]}
      fi
      local val=$(whiptail --title  "$PROPS" --inputbox  "$text" 10 60 "$text" 3>&1 1>&2 2>&3)
      inputstatus=$?
      if [ $inputstatus = 0 ];  then
        val=$(echo $val | tr -d "\n\r\t")
        if [ "$text" ]; then
          local oldstr=$PROPS"="$text
          local newstr=$PROPS"="$val
          local str='s~'$oldstr'~'$newstr'~'
          ##echo $str
          ##presskey
          sed -i "$str" $file
        else
          echo $PROPS"="$val >> $file
        fi
      fi
    fi
  done
}

function docxAkt() {
			local AKT=$(getAkt)
			echo "Выбран "${AKT_PATH}${AKT}
			presskey

      local CHET=$(getDocProp ${AKT_PATH}${AKT}".conf" 'НомерСчета')".conf"

			IN=$(cat ${CHET_PATH}${CHET} | grep "НомерДокумента")
			IFS='=' read -r -a array <<< "$IN"
      NUM=${array[1]}
      echo "НомерДокумента="$NUM

			IN=$(cat ${CHET_PATH}${CHET} | grep "Реквизиты")
			IFS='=' read -r -a array <<< "$IN"
			PROPS=${array[1]}
			echo "Реквизиты="$PROPS

      IN=$(cat ${CHET_PATH}${CHET} | grep "КонтрАгент")
			IFS='=' read -r -a array <<< "$IN"
			AGENT=${array[1]}
      echo "КонтрАгент="$AGENT
      head "Файлы для обработки:"
      echo ${TEMPLATES_PATH}${AKT_TEMPLATE}
      echo ${DOCX_PATH}"akt_"$AKT".docx"
      echo ${PROPS_PATH}$PROPS".conf"
      echo ${AGENTS_PATH}$AGENT".conf"
      echo ${AKT_PATH}$NUM".conf"
      echo ${CHET_PATH}$NUM".csv"
      presskey
      java -jar ${APP_PATH} ${TEMPLATES_PATH}${AKT_TEMPLATE} ${DOCX_PATH}"akt_"$AKT".docx" ${PROPS_PATH}$PROPS".conf" ${AGENTS_PATH}$AGENT".conf" ${AKT_PATH}$AKT".conf" ${CHET_PATH}$NUM".csv"
}

function aktMenu {
	OPTIONAKT=$(whiptail --title  "Управление актами" --menu  "Доступные операции" 20 60 12 \
	"view" "Посмотреть" \
	"add" "Новый" \
	"edit" "Редактировать" \
	"docx" "Сохранить в docx" \
	"delete" "Удалить" \
	3>&1 1>&2 2>&3)
}

function aktFunctions {
	exitstatus=$?
	if [ $exitstatus = 0 ];  then
		echo "Выбор меню: "$OPTIONAKT

		if [ $OPTIONAKT = "delete" ]; then
		  deleteAkt
		  presskey
		fi

		if [ $OPTIONAKT = "edit" ]; then
		  editAkt
		  ##NUM=$(getChet)
      ##file=${CHET_PATH}${NUM}".conf"
      ##editDoc $file "Настройка счета"
		  presskey
		fi

		if [ $OPTIONAKT = "view" ]; then
		  viewAkt
		  presskey
		fi

		if [ $OPTIONAKT = "add" ]; then
		  addAkt
		  presskey
		fi

		if [ $OPTIONAKT = "docx" ]; then
		  docxAkt
      presskey
		fi

	fi
}
