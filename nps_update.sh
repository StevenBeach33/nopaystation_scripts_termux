#!/bin/sh

# AUTHOR sigmaboy <j.sigmaboy@gmail.com>

# return codes:
# 1 user errors
# 2 no updates available
# 5 game archives already exist

# get directory where the scripts are located
SCRIPT_DIR="$(dirname "$(readlink -f "$(which "${0}")")")"

# source shared functions
. "${SCRIPT_DIR}/functions.sh"

# check for "-a" parameter
if [ "${1}" == "-a" ]
then
    ALL=1
    shift
else
    ALL=0
fi

my_usage(){
    echo ""
    echo "Usage:"
    echo "${0} \"GAME_ID\""
}

MY_BINARIES="pkg2zip sed grep file python3"
sha256_choose; downloader_choose

check_binaries "${MY_BINARIES}"

# Get variables from script parameters
TITLE_ID="${1}"

if [ -z "${TITLE_ID}" ]
then
    echo "No game ID found."
    my_usage
    exit 1
fi

check_valid_psv_id "${TITLE_ID}"

# get current working directory
MY_PATH="$(pwd)"


# test if any update is available
python pyNPU.py --link --title-id ${TITLE_ID} > /dev/null
if [ "${?}" -eq 2 ]
then
    >&2 echo "No updates available for title ID \"${TITLE_ID}\"."
    exit 2
fi

GAME_NAME="$(python pyNPU.py --name --title-id "${TITLE_ID}")"

# make DESTDIR overridable
if [ -z "${DESTDIR}" ]
then
    RENAME=1
    DESTDIR="${TITLE_ID}"
else
    RENAME=0
fi

# get the download links from the python script
# check if the script should just output the latest update or all
if [ "${ALL}" -eq 0 ]
then
    LIST="$(python pyNPU.py --link --title-id "${TITLE_ID}")"
else
    LIST="$(python pyNPU.py --link --all --title-id "${TITLE_ID}")"
fi

python pyNPU.py --changelog --title-id "${TITLE_ID}" > "${MY_PATH}/changelog.txt"

for i in ${LIST}
do
    cd "${MY_PATH}"
    if find . -maxdepth 1 -type f -name "*[${TITLE_ID}]*.${ext}" | grep -q -E "\[${TITLE_ID}\].*\.${ext}"
    then
        COUNT=0
        for FOUND_FILE in "$(find . -maxdepth 1 -type f -name "*[${TITLE_ID}]*[PATCH]*.${ext}" | grep -E "\[${TITLE_ID}\].*\[PATCH\].*\.${ext}" | sed 's@\./@@g')"
        do
            if [ "$(file -b --mime-type "${FOUND_FILE}")" = "${mime_type}" ]
            then
                COUNT=$((${COUNT} + 1))
                # print this to stderr
                >&2 echo "File \"${FOUND_FILE}\" already exists."
            else
                COUNT=$((${COUNT} + 1))
                # print this to stderr
                >&2 echo "File \"${FOUND_FILE}\" already exists."
                >&2 echo "But it doesn't seem to be a valid ${ext} file"
            fi
        done
        >&2 echo ""
        >&2 echo "${COUNT} updates already present"
        cd "${MY_PATH}"
        exit 5
    else
        my_download_file "${i}" "${TITLE_ID}_update.pkg"

        # extract files and compress them with t7z
        test -d "patch/" && rm -rf "patch/"
        pkg2zip -x "${TITLE_ID}_update.pkg"
        zip -r "${TITLE_ID}_update.zip" "patch"
        mv "${TITLE_ID}_update.zip" "/sdcard/NPS/PSV/UPDATE"
        rm -rf "${TITLE_ID}_update.pkg" "changelog.txt" "patch"
    fi
done