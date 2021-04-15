function getLastDoc() {
  cd $1
	path1=$(ls -v *.conf)
	res=""
	for entry in $path1
	do
    IFS='.' read -r -a array <<< "$entry"
    NUM=${array[0]}
	done
  cd ${CURDIR}
  echo $NUM
}

function getNum() {
  IFS='.' read -r -a array <<< "$1"
  NUM=${array[0]}
  echo $NUM
}

function getDocProp() {
  IN=$(cat $1 | grep $2)
	IFS='=' read -r -a array <<< "$IN"
  PROPSVAL=${array[1]}
  echo $PROPSVAL
}


function getNumDoc() {
  IN=$(cat $1 | grep "НомерДокумента")
	IFS='=' read -r -a array <<< "$IN"
  NUMDOC=${array[1]}
  echo $NUMDOC
}

function getDateDoc() {
  IN=$(cat $1 | grep "ДатаДокумента")
	IFS='=' read -r -a array <<< "$IN"
  DATEDOC=${array[1]}
  echo $DATEDOC
}

function docsMenu {
	OPTIONDOCS=$(whiptail --title  "Управление документами" --menu  "Доступные операции" 20 60 12 \
	"chet" "Счета" \
	"akt" "Акты" \
	3>&1 1>&2 2>&3)
}

function docsFunctions {
	exitstatus=$?
	while [ $exitstatus = 0 ]
	do
	##if [ $exitstatus = 0 ];  then
		echo "Выбор меню: "$OPTIONDOCS

		if [ $OPTIONDOCS = "chet" ]; then
			chetMenu
			exitstatus=$?
			if [ $exitstatus = 0 ];  then
				chetFunctions
				##presskey
			fi
			##continue
		fi

		if [ $OPTIONDOCS = "akt" ]; then
			aktMenu
			exitstatus=$?
			if [ $exitstatus = 0 ];  then
				aktFunctions
				##presskey
			fi
			##continue
		fi
	##fi
	done
}

function editDoc() {
  local i=0
  local file=$1
  local array;
	exitstatus=0
	while [ $exitstatus = 0 ]
	do
    if [ -f $file ]; then
    i=0
    arr=()
    while IFS= read -r line; do
      #echo "Text read from file: $line"
      IFS='=' read -r -a array <<< "$line"
      text=${array[1]}
      arr[i]=${array[0]}
      if [ "$text" ];  then
        arr[i+1]="${text}"
      else
       arr[i+1]=[???]
      fi
      let "i=i + 2"
    done < $file
    fi

    PROPS=$(whiptail --title  "$2" --menu \
    "Выберите настройку:" 23 60 17 "${arr[@]}" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
      local text=""
      if [ -f $file ]; then
        IN=$(cat $file | grep $PROPS)
        IFS='=' read -r -a array <<< "$IN"
        text=${array[1]}
      fi
      val=$(whiptail --title  "$PROPS" --inputbox  "$text" 10 60 "$text" 3>&1 1>&2 2>&3)
      local inputstatus=$?
      if [ $inputstatus = 0 ];  then
        val=$(echo $val | tr -d "\n\r\t")
        oldstr=$PROPS"="$text
        newstr=$PROPS"="$val
        str='s~'$oldstr'~'$newstr'~'
        echo $str
        ##presskey
        sed -i "$str" $file
      fi
    fi
  done
}
