#!/bin/bash
# /usr/lib/systemd/system-sleep/fingerprint-resume.sh

case $1 in
    post)
        sleep 3
        systemctl restart python3-validity
        echo "fingerprint: fixed after $2" | logger
        ;;
esac
