#!/bin/bash
case $1 in
    post)
        sleep 3
        systemctl restart python3-validity
        echo "fingerprint: fixed after $2" | logger
        ;;
esac
