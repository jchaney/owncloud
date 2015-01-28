#!/usr/bin/env bash

EXTCONF="${1}"
EXTAPPDIR="${2}"

if [ ! -d "${EXTAPPDIR}" ]; then
	echo "app dir not located ad ${EXTAPPDIR}. Exit processing of extensions.sh"
	exit 1
fi

pushd "${EXTAPPDIR}"

if [ ! -e "${EXTCONF}" ]; then
	echo "extconf doesn exists at ${EXTCONF}. Exit processing of extensions.sh"
	exit 1
fi

while read line
do
	# filter empty and commented lines
	[ "${line}" == "" ] && continue
	[ "${line:0:1}" == "#" ] && continue

	# parsing
	IFS="!" read -ra entry <<< "${line}"

	NAME="${entry[0]}"
	CMDL="${entry[1]}"

	echo ""
	echo "-=> work on ... ${NAME} "

	# yea - its secure nightmare here, but we call this only in a docker
	# container at buildtime
	if [ ! -z "${CMDL}" ]; then
		while IFS=";" read -ra cmdarr; do
			for cmd in "${cmdarr[@]}"; do
				[ -z "${cmd}" ] && continue
				echo "::: execute \"${cmd}\""
				${cmd}
			done
		done <<< $(echo "${CMDL}")
	fi

	echo "<=- ${NAME} done"
done < "${EXTCONF}"

popd

