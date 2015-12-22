#!/bin/sh
### BEGIN INIT INFO
# Provides:          upload_detector
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Re-link sftp logs under /srv/sftp and manage upload_detector
# Description:       Start, stop, restart upload_detector server for a specific application.
### END INIT INFO
set -e

# Feel free to change any of the following variables for your app:
PATH=/usr/local/bin:$PATH
TIMEOUT=${TIMEOUT-60}
APP_ROOT=/srv/import/upload_detector/current
SFTP_ROOT=/srv/sftp
PID=/srv/import/upload_detector/tmp/upload_detector.pid
CMD="cd $APP_ROOT; UPLOAD_DETECTOR_ENV=tonga nohup bin/upload_detector.rb &"
AS_USER=import
SANITIZE_HARDLINKS_CMD="$APP_ROOT/bin/sftp_hardlink_to_socket.sh $SFTP_ROOT"
set -u

sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}

run () {
  if [ "$(id -un)" = "$AS_USER" ]; then
    eval $1
  else
    su -c "$1" - $AS_USER
  fi
}

case "$1" in
start)
  sig 0 && echo >&2 "Already running" && exit 0
  $SANITIZE_HARDLINKS_CMD
  echo "Starting upload_detector"
  run "$CMD"
  ;;
stop)
  sig QUIT && exit 0
  echo >&2 "Not running"
  ;;
force-stop)
  sig TERM && exit 0
  echo >&2 "Not running"
  ;;
restart)
  stop
  run "$CMD"
  ;;
*)
  echo >&2 "Usage: $0 <start|stop|restart>"
  exit 1
  ;;
esac
