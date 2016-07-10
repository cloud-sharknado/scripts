#!/bin/bash

dec2binary() {
  # For provided IP address in Dot-decimal Notation returns
  # same IP in Binary format.
  declare -a PIECES
  declare -i DECNUM ITER
  declare BIT BINARY
  IFS=. read -r -a PIECES <<< "${1}"
  for ITER in "${!PIECES[@]}"; do
    DECNUM="${PIECES[${ITER}]}"; BINARY=""
    while [[ "${DECNUM}" -ne 0 ]]; do
      (( BIT = DECNUM % 2))
      BINARY="${BIT}${BINARY}"
      (( DECNUM = DECNUM / 2))
    done
    while [[ "${#BINARY}" -lt 8 ]]; do
      BINARY="0${BINARY}"
    done
    PIECES[${ITER}]="${BINARY}"
  done
  IFS="."; printf '%s' "${PIECES[*]}"; IFS="${IFS:1}"
}

binary2dec() {
  # For provided IP address in Binary form returns same
  # IP in Dot-decimal Notation
  declare -a PIECES
  declare -i ITER
  IFS=. read -r -a PIECES <<< "${1}"
  for ITER in "${!PIECES[@]}"; do
    PIECES[${ITER}]=$((2#${PIECES[${ITER}]}))
  done
  IFS="."; printf '%s' "${PIECES[*]}"; IFS="${IFS:1}"
}

is_valid_ip()
{
  declare IP="${1}"
  declare -i  STAT=1

  if [[ "${IP}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    IFS=. read -r -a IP <<< "${IP}"
    [[ "${IP[0]}" -le 255 && "${IP[1]}" -le 255 \
        && "${IP[2]}" -le 255 && "${IP[3]}" -le 255 ]]
    STAT="${?}"
  fi
  return "${STAT}"
}

calculate_netmask() {
  # Calculate netmask pieces, stored in MASK array
  #
  ## MASK[0] - Netmask in Dot-decimal Notation,
  ## MASK[1] - Netmask in Binary form,
  ## MASK[2] - Network Part Binary form,
  ## MASK[3] - Host Part Binary form,
  ## MASK[4] - CIDR Subnet
  ## MASK[5] - All 1s in host part replaced with 0s
  declare NETWORK="${1}"
  declare -i ITER COUNTER
    
  COUNTER=0 
  for ((ITER = 32 ; ITER > 0 ; ITER--)); do
    if ((NETWORK > 0)); then
      MASK[1]="${MASK[1]}1"
      ((NETWORK--))
    else
      MASK[1]="${MASK[1]}0"
    fi
    ((COUNTER++))
    if ((COUNTER == 8)); then
      [[ ${ITER} -ge 8 ]] && MASK[1]="${MASK[1]}."
      COUNTER=0
    fi
  done
  
  MASK[0]="$(binary2dec ${MASK[1]})"
  MASK[2]="${MASK[1]%%0*}"
  MASK[3]="${MASK[1]##*1}"; MASK[3]="${MASK[3]#.}"
  MASK[5]="${MASK[3]//1/0}" # Network calculation
  MASK[6]="${MASK[3]//0/1}" # Broadcast calculation
  MASK[7]="${MASK[5]%?}1"   # HostMin calculation
  MASK[8]="${MASK[6]%?}0"	  # HostMax calculation
}

calculate_ip() {
  # Calculate ip address pieces, stored in IP array
  #
  ## IP[0] - ip in Dot-decimal Notation,
  ## IP[1] - ip in Binary form,
  ## IP[2] - network Part Binary form,
  ## IP[3] - Host Part Binary form
  declare IPADDR="${1}" BINARY
  declare -i HOSTLEN="${2}" NETLEN="${3}"
  BINARY=$(dec2binary "${IPADDR}")
  IP[2]="${BINARY:0:NETLEN}"
  IP[3]=${BINARY:NETLEN}
}

main() {
  declare -a MASK IP
  IFS=/ read -r IP[0] MASK[4] <<< "${@}"

  print_result() {

    declare -r RED=$'\e[1;31m'
    declare -r GRN=$'\e[1;32m'
    declare -r YEL=$'\e[1;33m'
    declare -r BLU=$'\e[1;34m'
    declare -r MAG=$'\e[1;35m'
    declare -r CYN=$'\e[1;36m'
    declare -r END=$'\e[0m'
  
    printf "%-11s%-32s%s %s\n" "Address:" "${BLU}${IP[0]}${END}" "${YEL}${IP[2]}" "${IP[3]}${END}"
    printf "%-11s%-32s%s %s\n" "Netmask:" "${BLU}${MASK[0]} = ${MASK[4]}${END}" "${RED}${MASK[2]}${END}" "${RED}${MASK[3]}${END}"
    printf "%s\n" "=>"
    printf "%-11s%-32s%s %s\n" "Network:" "${BLU}$(binary2dec "${IP[2]}${MASK[5]}")/${MASK[4]}${END}" "${YEL}${IP[2]}" "${MASK[5]}${END}"
    printf "%-11s%-32s%s %s\n" "HostMin:" "${BLU}$(binary2dec "${IP[2]}${MASK[7]}")${END}" "${YEL}${IP[2]}" "${MASK[7]}${END}"
    printf "%-11s%-32s%s %s\n" "HostMax:" "${BLU}$(binary2dec "${IP[2]}${MASK[8]}")${END}" "${YEL}${IP[2]}" "${MASK[8]}${END}"
    printf "%-11s%-32s%s %s\n" "Broadcast:" "${BLU}$(binary2dec "${IP[2]}${MASK[6]}")${END}" "${YEL}${IP[2]}" "${MASK[6]}${END}"
    printf "%-11s%-32s\n" "Hosts/Net:" "${BLU}$((2**(32 - ${MASK[4]}) -2))${END}"
  }

  if [[ -z "${MASK[4]}" ]]; then
      printf "Error: %s is not a valid MASK[4]\n" "${ARG##*/}"
      exit 192
  fi

  if ! is_valid_ip "${IP[0]}"; then
      printf "Error: %s is not a valid ip address!\n" "${IP[0]}"
      exit 192
  fi
    
  case "${MASK[4]}" in
    '')
      printf "Error: %s is not a valid MASK[4]\n" "${ARG##*/}"  >&2
      exit 192
      ;;
    *[!0-9]*)
      printf "Error: %s has a non-digit somewhere in it\n" "${MASK[4]}"  >&2
      exit 192
      ;;
    *)
      if ((MASK[4] > 32)); then
        printf "Error: %s is not a valid MASK[4]\n" "${MASK[4]}"  >&2
        exit 192
      elif ((MASK[4] < 0)); then
        printf "Error: %s is not a valid MASK[4]\n" "${MASK[4]}"  >&2
        exit 192
      fi
      ;;
  esac

  calculate_netmask "${MASK[4]}"
  calculate_ip "${IP[0]}" "${#MASK[3]}" "${#MASK[2]}"

  print_result

}

main "${@}"