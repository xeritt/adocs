function getProps {
	cd $PROPS_PATH
	path1=$(ls -v *.conf)
	res=""
	i=0
	arr=()
	for entry in $path1
	do
		IFS='.' read -r -a array <<< "$entry"
    NUM=${array[0]}

		IN=$(cat ${entry} | grep "ФИОИП")
		IFS='=' read -r -a array <<< "$IN"

		text=${array[1]}
		arr[i]=$NUM
		if [ "$text" ];  then
		  arr[i+1]="${text}"
		else
		 arr[i+1]=[???]
		fi
		##arr[i+2]="OFF"
		((i+=2))
	done

	PROPS=$(whiptail --title  "Выбор реквизитов" --menu \
	"Выберите реквизиты:" 20 60 12 "${arr[@]}" 3>&1 1>&2 2>&3)
	exitstatus=$?
	cd ${CURDIR}
	echo $PROPS
}

function propsMenu {
	OPTIONPROPS=$(whiptail --title  "Управление реквизитами" --menu  "Доступные операции" 20 60 12 \
	"view" "Посмотреть" \
	"add" "Новый" \
	"edit" "Редактировать" \
	"delete" "Удалить" \
	3>&1 1>&2 2>&3)
}

function viewProps() {
  PROPS=$(getProps)
  head "Номер реквизита "$PROPS
  if [ "$PROPS" ]; then
    cat ${PROPS_PATH}${PROPS}.conf
  fi
  echo ""
}

function deleteProps() {
  PROPS=$(getProps)
  head "Номер реквизита "$PROPS
  if [ "$PROPS" ]; then
    presskey
    rm -f ${PROPS_PATH}${PROPS}.conf
  fi
  echo ""
}

declare -A newProps
newProps[1]='ФИОИП'
newProps[2]='ФИОДляПодписи'
newProps[3]='АдресДляДокументов'
newProps[4]='ЮридическийАдрес'
newProps[5]='ИНН'
newProps[6]='ОКПО'
newProps[7]='ОГРН'
newProps[8]='Телефон'
newProps[9]='ПочтаДляДокументов'
newProps[10]='АдресСайта'
newProps[11]='КонтактныеДанные'
newProps[12]='РасчетныйСчет'
newProps[13]='КоррСчет'
newProps[14]='БИК'
newProps[15]='НаименованиеБанка'
newProps[16]='НаименованиеБанкаИГородБанка'
newProps[17]='ВЛице'
newProps[18]='ОКАТО'
newProps[19]='ОКТМО'
newProps[20]='ОКОПФ'
newProps[21]='ОКОГУ'
newProps[22]='ОКФС'
newProps[23]='ОсновнойКодОКВЭД'
newProps[24]='ДатаРегистрации'
newProps[25]='МестоРегистрации'
newProps[26]='ИФНС'
newProps[27]='РегистрирующийОрган'
newProps[28]='НалоговыйОрган'
newProps[29]='ДатаПостановкиНаУчет'
newProps[30]='СистемаНалогообложения'

function addProps() {
  NUM=$(getLastDoc $PROPS_PATH)
  let "NUM=NUM+1"
  editProps $NUM
}

function editProps() {
  NUM=$1
  i=0
  file=${PROPS_PATH}${NUM}".conf"
	exitstatus=0
	while [ $exitstatus = 0 ]
	do
    arr=()
    for ((j=1; j <= 30; j++))
    do
      if [ -f $file ]; then
        IN=$(cat $file | grep ${newProps[$j]})
        IFS='=' read -r -a array <<< "$IN"
        text=${array[1]}
      fi
      arr[i]=${newProps[$j]}
      if [ "$text" ];  then
        arr[i+1]="${text}"
      else
       arr[i+1]=[???]
      fi
      ##arr[i+2]="OFF"
      ((i+=2))
    done
    PROPS=$(whiptail --title  "Настройка реквизитов" --menu \
    "Выберите настройку реквизита:" 23 60 17 "${arr[@]}" 3>&1 1>&2 2>&3)
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
         ## presskey
          sed -i "$str" $file
        else
          echo $PROPS"="$val >> $file
        fi
      fi
    fi
  done
}

function propsFunctions {
	exitstatus=$?
	if [ $exitstatus = 0 ];  then
		echo "Выбор меню: "$OPTIONPROPS

		if [ $OPTIONPROPS = "delete" ]; then
		  deleteProps
		  presskey
		fi

		if [ $OPTIONPROPS = "view" ]; then
		  viewProps
		  presskey
		fi

		if [ $OPTIONPROPS = "add" ]; then
		  addProps
		  ##echo "Опция "$AGENTPROP
		  presskey
		fi

  	if [ $OPTIONPROPS = "edit" ]; then
  	  PROPS=$(getProps)
  	  echo "PROPS="$PROPS
  	  if [ $exitstatus = 0 ]; then
  	    if [ "$PROPS" ]; then
		      editProps $PROPS
		    fi
		  fi
		  ##echo "Опция "$AGENTPROP
		  presskey
		fi
	fi
}
