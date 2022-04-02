#!/bin/bash
#not implemented: OPTION command
#./guipin.sh -D -T 10 -p "password" -d "test" -t "title" -q -l "test qual" -i "qualle" -o "Yep" -c "Njet" -a CONFIRM -3 "WHAT" -e "PROBLEM !!!"

_help(){
	echo "-h this help"
	echo "-D (script flag) debug"
	echo "-T <0> timeout"
	echo "-p <\"PIN\"> prompt text"
	echo "-d <\"Description\"> descripton text"
	echo "-t <\"Title\"> window title text"
	echo "-o <\"OK\"> ok text"
	echo "-c <\"Cancel\"> cancel text"
	echo "-3 <\"Other\"> 3th option text"
	echo "-e <\"Error\"> error text"
	echo "-q (flag,no arg)show quality indicator"
	echo "-l <\"pw quality\"> quality label text"
	echo "-i <\"This indicates entered PW quality\"> quality tool tip text"
	echo "-a <\"GETPIN\"> action (MESSAGE|GETPIN|CONFIRM)"
}

message=""

while getopts ":hDT:p:d:t:o:c:3:e:ql:i:a:" option; do
   case $option in
	h) # display Help
		_help
		exit;;
	D)
		debug="y";;
	T) 
		pin_timeout=10;; #$OPTARG;;
	p)
		pin_prompt="$OPTARG";;
	d)
		pin_description=$OPTARG;;
	t)
		pin_wintitle=$OPTARG;;
	o)
		pin_oktxt=$OPTARG;;
	c)
		pin_cncltxt=$OPTARG;;
	3)
		pin_3thway=$OPTARG;;
	e)
		pin_errortxt=$OPTARG;;
	q)
		pin_showquality=true;;
	l)
		pin_qualitylbl=$OPTARG;;
	i)
		pin_qualitytooltip=$OPTARG;;
	a)
		pin_action=$OPTARG;;
	\?) # Invalid option
		echo "Error: Invalid option"
		exit;;
   esac
done


#set 'pin_allowempty' else error returned on not found / empty

[ -n "$pin_timeout" ] && message+="SETTIMEOUT $pin_timeout\n"
[ -n "$pin_description" ] && message+="SETDESC $pin_description\n"
#[ -n "$pin_prompt" ] && 
message+="SETPROMPT $pin_prompt\n"
[ -n "$pin_wintitle" ] && message+="SETTITLE $pin_wintitle\n"
[ -n "$pin_oktxt" ] && message+="SETOK $pin_oktxt\n"
[ -n "$pin_cncltxt" ] && message+="SETCANCEL $pin_cncltxt\n"
[ -n "$pin_3thway" ] && message+="SETNOTOK $pin_3thway\n"
[ -n "$pin_errortxt" ] && message+="SETERROR $pin_errortxt\n"
if [ -n "$pin_qualitylbl" ]; then
	[ -n "$pin_showquality" ] && message+="SETQUALITYBAR $pin_qualitylbl\n"
else
	[ -n "$pin_showquality" ] && message+="SETQUALITYBAR\n"
fi
[ -n "$pin_qualitytooltip" ] && message+="SETQUALITYBAR_TT $pin_qualitytooltip\n"

case "$pin_action" in
	"GETPIN")
		message+="GETPIN"
	;;
	"CONFIRM")
		message+="CONFIRM"
	;;
	"MESSAGE")
		message+="MESSAGE"
	;;
	*)
		message="${message}GETPIN"
		pin_action="GETPIN"
	;;
esac

[ -n "$debug" ] && >&2 echo "DEBUG: message to pinentry: " && >&2 echo -e "$message"

result=$(echo -e "$message" | pinentry | grep -v "^OK")
errors=$(echo "$result" | grep "^ERR")

[ -n "$debug" ] && >&2 echo "DEBUG: result from pinentry: " && >&2 echo -e "$result"
[ -n "$debug" ] && >&2 echo "DEBUG: errors from result: " && >&2 echo -e "$errors"

if [ "$pin_action" = "GETPIN" ]; then
	pin=$(echo "${result}" | grep "^D " | sed 's/D //')
	[ -n "$pin" ] || [ -n "$pin_allowempty" ] || errors+="\n! No pin found"
	[ -n "$errors" ] && >&2 echo -e "\e[91m${errors}\e[0m" && exit 1 #/proc/self/fd/2
	echo "${pin}"
else
	[ -n "$errors" ] && >&2 echo -e "\e[91m${errors}\e[0m" && exit 1 #/proc/self/fd/2
fi

exit 0
