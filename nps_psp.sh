#!/bin/sh

# AUTHOR sigmaboy <j.sigmaboy@gmail.com>
# MODIFIED steven33 <stevenbeach33@gmail.com>

# return codes:
# 1 user errors
# 3 game is only available physically
# 4 link or key missing.

# get directory where the scripts are located
SCRIPT_DIR="$(dirname "$(readlink -f "$(which "${0}")")")"

# source shared functions
. "${SCRIPT_DIR}/functions.sh"

my_usage() {
    echo ""
    echo "Usage:"
    echo "${0} \"/path/to/PSP_GAME.tsv\" \"GAME_ID\""
}

MY_BINARIES="pkg2zip sed"
sha256_choose; downloader_choose

check_binaries "${MY_BINARIES}"

# Get variables from script parameters
TSV_FILE="${1}"
GAME_ID="${2}"


if [ ! -f "${TSV_FILE}" ]
then
    echo "No TSV file found."
    my_usage
    exit 1
fi
if [ -z "${GAME_ID}" ]
then
    echo "No game ID found."
    my_usage
    exit 1
fi

check_valid_psp_id "${GAME_ID}"

# check if MEDIA ID is found in download list
if ! grep "^${GAME_ID}" "${TSV_FILE}" > /dev/null
then
    echo "ERROR:"
    echo "Media ID is not found in your *.tsv file"
    echo "Check your input for a valid media ID."
    echo "Search on: \"https://renascene.com/psp/\" for"
    echo "Media IDs or simple open the *.tsv with your Office Suite."
    exit 1
fi

# get link, encryption key and sha256sum
LIST=$(grep "^${GAME_ID}" "${TSV_FILE}" | cut -f"5,8,11" | tr -d '\r')

# save those in separete variables
LINK=$(echo "${LIST}" | cut -f1)
LIST_SHA256=$(echo "${LIST}" | cut -f3)
RAP=$(echo "${LIST}" | cut -f2)

if [ "${LINK}" = "MISSING" ]
then
    echo "Link of \"${GAME_ID}\" missing. Cannot proceed."
    exit 4
elif [ "${LINK}" = "CART ONLY" ]
then
    echo "\"${GANE_ID}\" is only available via cartridge"
    exit 3
else
    my_download_file "${LINK}" "${GAME_ID}.pkg"
    FILE_SHA256="$(my_sha256 "${GAME_ID}.pkg")"
    compare_checksum "${LIST_SHA256}" "${FILE_SHA256}"

    pkg2zip -l "${GAME_ID}.pkg" > "${GAME_ID}.txt"
    pkg2zip "${GAME_ID}.pkg"
    mv *.iso "/sdcard/NPS/PSP/"
    rm "${GAME_ID}.pkg"
fi
