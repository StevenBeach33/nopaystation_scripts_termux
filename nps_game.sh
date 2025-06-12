#!/bin/sh

# AUTHOR sigmaboy <j.sigmaboy@gmail.com>
# MODIFIED steven33 <stevenbeach33@gmail.com>

# return codes:
# 1 user errors
# 3 game is only available physically
# 4 link or key missing.
# 5 game archive already exists

# get directory where the scripts are located
SCRIPT_DIR="$(dirname "$(readlink -f "$(which "${0}")")")"

# source shared functions
. "${SCRIPT_DIR}/functions.sh"

my_usage() {
    echo ""
    echo "Usage:"
    echo "${0} \"/path/to/GAME.tsv\" \"GAME_ID\""
}

MY_BINARIES="pkg2zip sed grep file"
sha256_choose; downloader_choose

check_binaries "${MY_BINARIES}"

# Get variables from script parameters
TSV_FILE="${1}"
TITLE_ID="${2}"


if [ ! -f "${TSV_FILE}" ]
then
    echo "No TSV file found."
    my_usage
    exit 1
fi
if [ -z "${TITLE_ID}" ]
then
    echo "No game ID found."
    my_usage
    exit 1
fi

check_valid_psv_id "${TITLE_ID}"

# check if MEDIA ID is found in download list
if ! grep "^${TITLE_ID}" "${TSV_FILE}" > /dev/null
then
    echo "ERROR:"
    echo "Media ID is not found in your *.tsv file"
    echo "Check your input for a valid media ID"
    echo "Search on: \"https://renascene.com/psv/\" for"
    echo "Media IDs or simple open the *.tsv with your Office Suite."
    exit 1
fi

# get link, encryption key and sha256sum
LIST=$(grep "^${TITLE_ID}" "${TSV_FILE}" | cut -f"4,5,10")

# save those in separete variables
LINK=$(echo "${LIST}" | cut -f1)
KEY=$(echo "${LIST}" | cut -f2)
LIST_SHA256=$(echo "${LIST}" | cut -f3)

if [ "${LINK}" = "MISSING" ] && [ "${KEY}" = "MISSING" ]
then
    echo "Download link and zRIF key of \"${TITLE_ID}\" are missing."
    echo "Cannot proceed."
    exit 4
elif [ "${LINK}" = "MISSING" ]
then
    echo "Download link of \"${TITLE_ID}\" is missing."
    echo "Cannot proceed."
    exit 4
elif [ "${KEY}" = "MISSING" ]
then
    echo "zrif key of \"${TITLE_ID}\" is missing."
    echo "Cannot proceed."
    exit 4
elif [ "${LINK}" = "CART ONLY" ]
then
    echo "\"${GANE_ID}\" is only available via cartridge"
    exit 3
else
    if find . -maxdepth 1 -type f -name "*[${TITLE_ID}]*.${ext}" | grep -q -E "\[${TITLE_ID}\].*\.${ext}"
    then
        FOUND_FILE=$(find . -maxdepth 1 -type f -name "*[${TITLE_ID}]*.${ext}" | grep -E "\[${TITLE_ID}\].*\.${ext}" | sed 's@\./@@g')
        # write package name into txt file for depending steps like downloading dlc and update
        echo "${FOUND_FILE}" | sed "s/\.${ext}//g" > "${TITLE_ID}.txt"

        # test if archive is a ${ext} file
        if [ "$(file -b --mime-type "${FOUND_FILE}")" = "${mime_type}" ]
        then
            # print this to stderr
            >&2 echo "File \"${FOUND_FILE}\" already exists."
            exit 5
        else
            # print this to stderr
            >&2 echo "File \"${FOUND_FILE}\" already exists."
            >&2 echo "But it doesn't seem to be a valid ${ext} file"
            exit 5
        fi
    else
        my_download_file "${LINK}" "${TITLE_ID}.pkg"
        FILE_SHA256="$(my_sha256 "${TITLE_ID}.pkg")"
        compare_checksum "${LIST_SHA256}" "${FILE_SHA256}"

        #  extract pkg, zip it and move to sdcard
        pkg2zip -x "${TITLE_ID}.pkg" "${KEY}"
        mv "${TITLE_ID}.zip" "/sdcard/NPS/PSV/GAME"
        rm "${TITLE_ID}.pkg" "${TITLE_ID}.txt"
    fi
fi
exit 0
