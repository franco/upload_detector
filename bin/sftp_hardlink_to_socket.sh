#!/bin/bash
#
# This script goes through all sftp accounts and re-links dev/log
# to the log socket under /srv/sftp/dev/log.
#
# usage: bin/sftp_hardlink_to_socket.sh [sftp_root_path]
#

SFTP_ROOT=${1:-"/srv/sftp"} # ${1:-something} is called the default value syntax
SOCKET="${SFTP_ROOT}/dev/log"
LOGS_FIND_PATTERN="${SFTP_ROOT}/**/dev/log"

echo "Re-create hardlinks to socket for sftp logging"
LOG_HARDLINKS=( $(ls $LOGS_FIND_PATTERN) )
if [ ${#LOG_HARDLINKS[@]} -eq 0 ]; then
  echo "No hardlinks found. Something's fishy?"
else
  for link in "${LOG_HARDLINKS[@]}"
  do
    echo "$link -> $SOCKET"
    rm $link && ln $SOCKET $link
  done
fi

