#!/bin/sh

# get directory where the scripts are located
SCRIPT_DIR="$(dirname "$(readlink -f "$(which "${0}")")")"
mkdir tsv

# source shared functions
. "${SCRIPT_DIR}/functions.sh"

HEADER="https://"
BASE_URL="nopaystation.com"
MY_URL_PATH="tsv"
LIST="PSV_GAMES PSV_DLCS PSM_GAMES PSV_UPDATES PSV_THEMES PSX_GAMES PSP_GAMES"
LIST="${LIST} PSP_DLCS PSP_THEMES PS3_GAMES PS3_DLCS PS3_THEMES PS3_AVATARS"
LIST="${LIST} PS4_GAMES PS4_DLCS PS4_UPDATES PS4_THEMES"
MY_NAME="NoPayStation"

MY_BINARIES=""
downloader_choose

check_binaries "${MY_BINARIES}"

if [ -z "${1}" ]
then
    DEST="$(pwd)"
else
    DEST="${1}"
fi

for i in ${LIST}
do
    my_download_file "${HEADER}${BASE_URL}/${MY_URL_PATH}/${i}.tsv" \
                     "${DEST}/tsv/${i}.tsv"
done
