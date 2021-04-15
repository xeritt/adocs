function getAgent {
	cd $AGENTS_PATH
	path1=$(ls -v *.conf)
	res=""
	i=0
	arr=()
	for entry in $path1
	do
 		IFS='.' read -r -a array <<< "$entry"
    NUM=${array[0]}

		IN=$(cat ${entry} | grep "НазваниеКонтр")
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

	AGENT=$(whiptail --title  "Выбор контрагента" --menu \
	"Выберите контрагента (Заказчика):" 20 60 12 "${arr[@]}" 3>&1 1>&2 2>&3)
	exitstatus=$?
	cd ${CURDIR}
	echo $AGENT
}

function agentsMenu {
	OPTIONAGENT=$(whiptail --title  "Управление агентами" --menu  "Доступные операции" 20 60 12 \
	"view" "Посмотреть" \
	"add" "Новый агент" \
	"edit" "Редактировать" \
	"delete" "Удалить" \
	3>&1 1>&2 2>&3)
}

function viewAgent() {
  AGENT=$(getAgent)
  head "Номер агента "$AGENT
  if [ "$AGENT" ]; then
    cat ${AGENTS_PATH}${AGENT}.conf
  fi
  echo ""
}

function deleteAgent() {
  AGENT=$(getAgent)
  head "Номер агента "$AGENT
  if [ "$AGENT" ]; then
    presskey
    rm -f ${AGENTS_PATH}${AGENT}.conf
  fi
  echo ""
}


declare -A newAgent
newAgent[1]='НазваниеКонтр'
newAgent[2]='ФИОКонтрДляПодписи'
newAgent[3]='ИННКонтр'
newAgent[4]='КППКонтр'
newAgent[5]='ОГРНКонтр'
newAgent[6]='АдресКонтр'
newAgent[7]='ЮрАдресКонтр'
newAgent[8]='ТелефонКонтр'
newAgent[9]='РасчетныйСчетКонтр'
newAgent[10]='КоррСчетКонтр'
newAgent[11]='НаименованиеБанкаКонтр'
newAgent[12]='БИКБанкаКонтр'
newAgent[13]='КонтрВЛице'
newAgent[14]='ЕмэйлКонтр'
newAgent[15]='ПаспортКонтр'
newAgent[16]='ДолжностьКонтр'
newAgent[17]='ОКПОКонтр'
function addAgent() {
  NUM=$(getLastDoc $AGENTS_PATH)
  let "NUM=NUM+1"
  editAgent $NUM

}

function editAgent() {
  NUM=$1
  i=0
  file=${AGENTS_PATH}${NUM}".conf"
	exitstatus=0
	while [ $exitstatus = 0 ]
	do
    local arr=()
    for ((j=1; j <= 17; j++))
    do
      if [ -f $file ]; then
        IN=$(cat $file | grep ${newAgent[$j]})
        IFS='=' read -r -a array <<< "$IN"
        text=${array[1]}
      fi
      arr[i]=${newAgent[$j]}
      if [ "$text" ];  then
        arr[i+1]="${text}"
      else
       arr[i+1]=[???]
      fi
      ##arr[i+2]="OFF"
      ((i+=2))
    done
    AGENTPROP=$(whiptail --title  "Настройка контрагента" --menu \
    "Выберите настройку контрагента (Заказчика):" 23 60 17 "${arr[@]}" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
      text=""
      if [ -f $file ]; then
        IN=$(cat $file | grep $AGENTPROP)
        IFS='=' read -r -a array <<< "$IN"
        text=${array[1]}
      fi
      val=$(whiptail --title  "$AGENTPROP" --inputbox  "$text" 10 60 "$text" 3>&1 1>&2 2>&3)
      local inputstatus=$?
      if [ $inputstatus = 0 ];  then
        val=$(echo $val | tr -d "\n\r\t")
        if [ "$text" ]; then
          oldstr=$AGENTPROP"="$text
          newstr=$AGENTPROP"="$val
          str='s~'$oldstr'~'$newstr'~'
          ##echo $str
          ##presskey
          sed -i "$str" $file
        else
          echo $AGENTPROP"="$val >> $file
        fi
      fi
    fi
  done
}

function agentsFunctions {
	exitstatus=$?
	if [ $exitstatus = 0 ];  then
		echo "Выбор меню: "$OPTIONAGENT

		if [ $OPTIONAGENT = "delete" ]; then
		  deleteAgent
		  presskey
		fi

		if [ $OPTIONAGENT = "view" ]; then
		  viewAgent
		  presskey
		fi

		if [ $OPTIONAGENT = "add" ]; then
		  addAgent
		  ##echo "Опция "$AGENTPROP
		  presskey
		fi

  	if [ $OPTIONAGENT = "edit" ]; then
  	  AGENT=$(getAgent)
  	  echo "AGENT="$AGENT
  	  if [ $exitstatus = 0 ]; then
  	    if [ "$AGENT" ]; then
		      editAgent $AGENT
		    fi
		  fi
		  ##echo "Опция "$AGENTPROP
		  presskey
		fi
	fi
}
