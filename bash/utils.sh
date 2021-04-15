function blueLine {
	echo -en "\e[38;5;17m==========\e[0m"
	for i in {17..21} {21..17} ; do echo -en "\e[38;5;${i}m=\e[0m"; done ;
	echo -en "\e[38;5;17m==========\e[0m"
	echo
}
function head {
  blueLine
  echo $1
  blueLine
}

function presskey {
  blueLine
	read -sn 1 -p 'Press any key to continue...or Ctrl+z for cancel';echo
}

function getConfFiles() {
  ls -v *.conf
}
