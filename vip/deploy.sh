#!/usr/bin/env /bin/bash
#
# Author: Dejan Djordjevic
# Creation date:2015-02-02
# Update date:2015-02-02
# 
# Note: wrapper script for tra AppManage utility
#
#

# configuration varables
MY_VERSION=0.1
MY_DATE=$(/bin/date -d "2015-02-02" +'%B,%d %Y')

TIB_DOMAIN="tradomain"
TIB_USER="admin"
TIB_PASSWD="admin"
TIB_TRA_BIN_DIR="/path/to/tra/x.y/bin"
CURR_DIR="$(pwd)"
CMD="echo ${TIB_TRA_BIN_DIR}/AppManage"

# function definitions
# show_help function for displaying help information

show_help() {
cat << EOF
Usage: ${0##*/} -a ACTION -n NAME [OPTIONS]
Usage: ${0##*/} -h
Usage: ${0##*/} -v

Where: 
 NAME is name of application, given either in relative or absolute path
  -n APP_PATH/APP | -n APP 
 
 ACTION is an action to be performed, and could be one of the following:
  -a deploy 	deploy named application
  -a undeploy   undeploy named application
  -a delete	delete named application
  -a export	export named application

 OPTIONS are optional parameters to change default behavior of script
 -d domain	specify Tibco domain, default is ${TIB_DOMAIN}
 -u user	specify username, default is ${TIB_USER}
 -p password	specify password other then default
 -e ear		specify ear file to be deployed/exported, default is ${CURR_DIR}/${APP:-'[APP]'}.ear
		available only within "deploy" action.
 -c config	specify configuration to be applied, default is ${CURR_DIR}/${APP:-'[APP]'}.xml 
		available only within "deploy" action.		
 -o		export configuration only, available only within export action.

-h          display this help and exit
-v          display version string and exit

EOF
}


# handling script options if any 
FLAGS=""
while getopts "a:n:d:u:p:e:c:ohv" opt; do
    case "$opt" in
	a)  ACTION=${OPTARG}
            ;;
	n)  NAME=${OPTARG}
            ;;
        d)  TIB_DOMAIN=${OPTARG}
	    ;;
	u)  TIB_USER=${OPTARG}
            ;;
	p)  TIB_PASSWD=${OPTARG}
            ;;
        e)  EAR_FILE=${OPTARG}
	    FLAGS="${FLAGS}e"
            if [[ ! -f "${EAR_FILE}" ]]; then
             printf "Specified ear file %s does not exists\n" "${EAR_FILE}"
             exit 1
            fi
            ;;
        c)  CONFIG_FILE=${OPTARG}
	    FLAGS="${FLAGS}c"
            if [[ ! -f "${CONFIG_FILE}" ]]; then
             printf "Specified configuration file %s does not exists\n" "${CONFIG_FILE}"
             exit 1
            fi
            ;;
	o)  CONFIG_ONLY="TRUE"
	    FLAGS="${FLAGS}o"
            ;;
        h)
            show_help >&2
            exit 0
            ;;
        v)  
            echo "${0##*/}"
            echo "Version ${MY_VERSION}, ${MY_DATE}" && echo
            exit 0
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

# test for exclusive options
echo ${FLAGS} | sed 's/o//g'
# Main logic
# Test for mandatory options

[[ -z ${ACTION} ]] && printf "\nACTION could not be empty\n" && show_help >&2 && exit 1
[[ -z ${NAME} ]] && printf "\nApplication name must be provided\n" && show_help >&2 && exit 1


if [[ ${ACTION} == "deploy" ]]; then
 if [[ ! -f ${EAR_FILE:-$NAME.ear} ]]; then 
  printf "Missing ${EAR_FILE:-$NAME.ear}. Please check ${CURR_DIR} dir.\n"
  exit 1
 fi
 if [[ ! -f ${CONFIG_FILE:-$NAME.xml} ]]; then 
  printf "Missing ${CONFIG_FILE:-$NAME.xml}. Please check ${CURR_DIR} dir.\n"
  exit 1
 fi
 ${CMD} -deploy -ear ${EAR_FILE:-$NAME.ear} -deployConfig ${CONFIG_FILE:-$NAME.xml} -app ${NAME} -domain ${TIB_DOMAIN} -user ${TIB_USER} -pw ${TIB_PASSWD}
elif [[ ${ACTION} == "undeploy" ]]; then
 ${CMD} -undeploy -app ${NAME} -domain ${TIB_DOMAIN} -user ${TIB_USER} -pw ${TIB_PASSWD}
elif [[ ${ACTION} == "delete" ]]; then
 ${CMD} -delete -app ${NAME} -domain ${TIB_DOMAIN} -user ${TIB_USER} -pw ${TIB_PASSWD}
elif [[ ${ACTION} == "export" ]]; then
 cd ${CURR_DIR}
 if [[ ! -z ${CONFIG_ONLY} ]]; then
    ${CMD} -export -out "${OUT_DIR:-$CURR_DIR}/${NAME}.xml" -app ${NAME} -domain ${TIB_DOMAIN} -user ${TIB_USER} -pw ${TIB_PASSWD}
 else 
    ${CMD} -export -out "${OUT_DIRi:-$CURR_DIR}/${NAME}.xml" -ear "${OUT_DIRi:-$CURR_DIR}/${NAME}.ear" -app ${NAME} -domain ${TIB_DOMAIN} -user ${TIB_USER} -pw ${TIB_PASSWD}
 fi
else 
 printf "Unrecognized action %s\n" "${ACTION}"
 show_help
 exit 1
fi

exit 0
# EOF
