declare -A newChet
newChet[ДатаДокумента]='ДатаДокумента'
##newChet[Реквизиты]="Номер реквизитов компании"
##newChet[КонтрАгент]="Номер реквизиты заказчика"
newChet[Комментарий]='Комментарий'

function addChet {
		##head "Добавить счет"
		content="english only"
		##newChet[НомерДокумента]='Номер Документа'
		NUM=$(getLastDoc $CHET_PATH)
		let "NUM=NUM + 1"
		str=$(whiptail --title  "Новый счет" --inputbox  "НомерДокумента" 10 60 "$NUM" 3>&1 1>&2 2>&3)
	  #if [ $CUST = "НомерДокумента" ]; then
	  NUMDOC=$str
	  chet_path=${CHET_PATH}${NUMDOC}".conf"
	  echo "Файл счета: "$chet_path
	  echo "НомерДокумента="$str > $chet_path
	  ##fi
	  str=$(getProps)
		echo "Номер реквизитов: "$str
		echo "Реквизиты="$str>>$chet_path

		str=$(getAgent)
		echo "Номер агента: "$str
		echo "КонтрАгент="$str>>$chet_path


		for CUST in "${!newChet[@]}";
		do
		  text=${newChet[$CUST]}
			str=$(whiptail --title  "Новый счет №$NUMDOC" --inputbox  "$text" 10 60 "" 3>&1 1>&2 2>&3)
		  echo $CUST"="$str>>$chet_path
		done
	  presskey
}

declare -A newWork
newWork[1]='№'
newWork[2]='Товары (работы, услуги)'
newWork[3]='Кол-во'
newWork[4]='Ед.'
newWork[5]='Цена'

function addWork {
    NUM=$1
    res=""
		for ((i=1; i <= 5; i++))
		do
		  text=${newWork[$i]}
			str=$(whiptail --title  "Товары (работы, услуги) счета №$NUM" --inputbox  "$text" 10 60 "" 3>&1 1>&2 2>&3)
			if [ $i = "1" ]; then
			  res=$str
      else
        res=$res";"$str
			fi

		  if [ $i = "3" ]; then
		    col=$str;
		  fi
		  if [ $i = "5" ]; then
		    cost=$str;
		  fi
		done

    sum=$(echo "$col*$cost" | bc -l)
    res=$res";"$sum
    chet_path=${CHET_PATH}${NUM}".csv"
		echo $res>>$chet_path
}

function viewChet() {
    CHET=$(getChet)
    echo ""
    head "Счет №"$CHET
    cat ${CHET_PATH}${CHET}".conf"
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

function deleteChet() {
    CHET=$(getChet)
    echo "Удаляется документ "$CHET
    presskey
    rm -f ${CHET_PATH}${CHET}".conf"
    rm -f ${CHET_PATH}${CHET}".csv"
}

function chetMenu {
	OPTIONCHET=$(whiptail --title  "Управление счетами" --menu  "Доступные операции" 20 60 12 \
	"view" "Посмотреть" \
	"add" "Новый счет" \
	"edit" "Редактировать" \
	"work" "Добавить работу (товар)" \
	"docx" "Сохранить в docx" \
	"delete" "Удалить" \
	3>&1 1>&2 2>&3)
}

function getChet {
	cd $CHET_PATH
	path1=$(getConfFiles)
	res=""
	i=0
	arr=()
	for entry in $path1
	do
	  NUM=$(getNum $entry)
	  AGENT=$(getDocProp ${CHET_PATH}${entry} 'КонтрАгент')
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

	CHET=$(whiptail --title  "Выбор счета" --menu \
	"Выберите счет?" 20 60 12 "${arr[@]}" 3>&1 1>&2 2>&3)
	exitstatus=$?
	cd ${CURDIR}
	##echo "Статус выбора проекта "$exitstatus
	echo $CHET
}

function docxChet() {
			CHET=$(getChet)".conf"
			echo "Выбран "${CHET_PATH}${CHET}
			presskey

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
      echo "КонтрАгент="
      head "Файлы для обработки:"
      echo ${TEMPLATES_PATH}${CHET_TEMPLATE}
      echo ${DOCX_PATH}"chet_"$NUM".docx"
      echo ${PROPS_PATH}$PROPS".conf"
      echo ${AGENTS_PATH}$AGENT".conf"
      echo ${CHET_PATH}$NUM".conf"
      echo ${CHET_PATH}$NUM".csv"
      echo "APP_PATH="${APP_PATH}
      presskey
      java -jar ${APP_PATH} ${TEMPLATES_PATH}${CHET_TEMPLATE} ${DOCX_PATH}"chet_"$NUM".docx" ${PROPS_PATH}$PROPS".conf" ${AGENTS_PATH}$AGENT".conf" ${CHET_PATH}$NUM".conf" ${CHET_PATH}$NUM".csv"
}


declare -A editChetArr
editChetArr[1]='ДатаДокумента'
editChetArr[2]='Комментарий'

function editChet() {
##  NUM=$1
  i=0

  NUM=$(getChet)
  file=${CHET_PATH}${NUM}".conf"
	exitstatus=0
	while [ $exitstatus = 0 ]
	do
    arr=()
    for ((j=1; j <= 2; j++))
    do
      if [ -f $file ]; then
        IN=$(cat $file | grep ${editChetArr[$j]})
        IFS='=' read -r -a array <<< "$IN"
        text=${array[1]}
      fi
      arr[i]=${editChetArr[$j]}
      if [ "$text" ];  then
        arr[i+1]="${text}"
      else
       arr[i+1]=[???]
      fi
      ##arr[i+2]="OFF"
      ((i+=2))
    done
    PROPS=$(whiptail --title  "Настройка счета" --menu \
    "Выберите настройку:" 23 60 17 "${arr[@]}" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
      text=""
      if [ -f $file ]; then
        IN=$(cat $file | grep $PROPS)
        IFS='=' read -r -a array <<< "$IN"
        text=${array[1]}
      fi
      val=$(whiptail --title  "$PROPS" --inputbox  "$text" 10 60 "$text" 3>&1 1>&2 2>&3)
      local inputstatus=$?
      if [ $inputstatus = 0 ];  then
        val=$(echo $val | tr -d "\n\r\t")
        if [ "$text" ]; then
          oldstr=$PROPS"="$text
          newstr=$PROPS"="$val
          str='s~'$oldstr'~'$newstr'~'
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
function chetFunctions {
	exitstatus=$?
	if [ $exitstatus = 0 ];  then
		echo "Выбор меню: "$OPTIONCHET

		if [ $OPTIONCHET = "work" ]; then
      CHET=$(getChet)".conf"
  		IN=$(cat ${CHET_PATH}${CHET} | grep "НомерДокумента")
	  	IFS='=' read -r -a array <<< "$IN"
      NUM=${array[1]}

		  addWork $NUM
		  presskey
		fi

		if [ $OPTIONCHET = "delete" ]; then
		  deleteChet
		  presskey
		fi

		if [ $OPTIONCHET = "edit" ]; then
		  editChet
		  ##NUM=$(getChet)
      ##file=${CHET_PATH}${NUM}".conf"
      ##editDoc $file "Настройка счета"
		  presskey
		fi

		if [ $OPTIONCHET = "view" ]; then
		  viewChet
		  presskey
		fi

		if [ $OPTIONCHET = "add" ]; then
		  addChet
		  presskey
		fi

		if [ $OPTIONCHET = "docx" ]; then
		  docxChet
      presskey
		fi

	fi
}
