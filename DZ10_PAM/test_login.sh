#!/bin/bash

day=$(date +%a)

is_weekend=$(($(test $day -eq "Сб"; echo $?)+$(test $day -eq "Вс"; echo $?)))

admins_gr=$(getent group admins | grep "\b${PAM_USER}\b")


if [ -z "$admins_gr"]; then
        if [[ $is_weekend -eq 0 ]]; then
                exit 0
        else
                exit 1
        fi
else
        exit 0
fi
