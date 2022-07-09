#!/bin/bash

EMAILHOST="user@server"
DIR="/directory/path/to/the/files/"
DEST="${EMAILHOST}:/destination/path/in/email/server/"
RETRY=false

#scan DIR and create a temporal file(FILE_LIST) containing names of files in it
#temporal file is deleted once script is done
FILE_LIST=$(mktemp)
find "$DIR" -maxdepth 1 -type f -printf "%f\n" > "$FILE_LIST"
trap 'rm -f "$FILE_LIST"' EXIT

while true; do
        SUCCESS=true
        rsync --rsync-path="sudo rsync" \
                --archive \
                --compress \
                --files-from="$FILE_LIST" \
                ${DIR} ${DEST} || SUCCESS=false
        $SUCCESS && break;
        if ! $RETRY; then
                echo "Rsync not possible" >&2
                exit 1
        fi
done
echo "transfer successfull"
