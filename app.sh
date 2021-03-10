#!/usr/bin/env zsh

__PCLOCK=""

# https://gist.github.com/cjus/1047794#gistcomment-3313785
_json_value() {
    declare LC_ALL=C num="${2:-}"
    grep -o "\"""${1}""\"\:.*" | sed -e "s/.*\"""${1}""\": //" -e 's/[",]*$//' -e 's/["]*$//' -e 's/[,]*$//' -e "s/\"//" -n -e "${num}"p
}

if [ $(date +%u) -lt 6 ]
then
    __APP_PATH="`dirname \"$0\"`"
    __APP_PATH="`( cd \"$__APP_PATH\" && pwd )`"

    settings=`cat $__APP_PATH/settings.json`

    __PCLOCK_WORK_HOURS=`echo $settings | _json_value 'work_hours'`
    __PCLOCK_LUNCH_BREAKS=`echo $settings | _json_value 'lunch_breaks'`
    # echo $__PCLOCK_WORK_HOURS
    # echo $__PCLOCK_LUNCH_BREAKS

    IFS="-" read -A __PCLOCK_WORK_HOURS_ARY <<< $__PCLOCK_WORK_HOURS
    # echo ${__PCLOCK_WORK_HOURS_ARY[@]}

    IFS="-" read -A __PCLOCK_LUNCH_BREAKS_ARY <<< $__PCLOCK_LUNCH_BREAKS
    # echo ${__PCLOCK_LUNCH_BREAKS_ARY[@]}

    IFS=":" read -A __PCLOCK_WORK_HOURS_ARY1 <<< $__PCLOCK_WORK_HOURS_ARY[1]
    IFS=":" read -A __PCLOCK_WORK_HOURS_ARY2 <<< $__PCLOCK_WORK_HOURS_ARY[2]
    # echo ${__PCLOCK_WORK_HOURS_ARY1[@]}
    # echo ${__PCLOCK_WORK_HOURS_ARY2[@]}

    IFS=":" read -A __PCLOCK_LUNCH_BREAKS_ARY1 <<< $__PCLOCK_LUNCH_BREAKS_ARY[1]
    IFS=":" read -A __PCLOCK_LUNCH_BREAKS_ARY2 <<< $__PCLOCK_LUNCH_BREAKS_ARY[2]
    # echo ${__PCLOCK_LUNCH_BREAKS_ARY1[@]}
    # echo ${__PCLOCK_LUNCH_BREAKS_ARY2[@]}

    __PCLOCK_WORK_HOURS_ARY[1]=$(($__PCLOCK_WORK_HOURS_ARY1[1]*3600+$__PCLOCK_WORK_HOURS_ARY1[2]*60))
    __PCLOCK_WORK_HOURS_ARY[2]=$(($__PCLOCK_WORK_HOURS_ARY2[1]*3600+$__PCLOCK_WORK_HOURS_ARY2[2]*60))

    __PCLOCK_LUNCH_BREAKS_ARY[1]=$(($__PCLOCK_LUNCH_BREAKS_ARY1[1]*3600+$__PCLOCK_LUNCH_BREAKS_ARY1[2]*60))
    __PCLOCK_LUNCH_BREAKS_ARY[2]=$(($__PCLOCK_LUNCH_BREAKS_ARY2[1]*3600+$__PCLOCK_LUNCH_BREAKS_ARY2[2]*60))

    unset __PCLOCK_WORK_HOURS_ARY1
    unset __PCLOCK_WORK_HOURS_ARY2
    unset __PCLOCK_LUNCH_BREAKS_ARY1
    unset __PCLOCK_LUNCH_BREAKS_ARY2
    unset __PCLOCK_WORK_HOURS
    unset __PCLOCK_LUNCH_BREAKS

    # echo ${__PCLOCK_WORK_HOURS_ARY[@]}
    # echo ${__PCLOCK_LUNCH_BREAKS_ARY[@]}

    __PCLOCK_NOW=$(($(date +%H)*3600+$(date +%M)*60+$(date +%S)))
    # echo $__PCLOCK_NOW

    if [ $__PCLOCK_NOW -ge $__PCLOCK_WORK_HOURS_ARY[1] ]  && [ $__PCLOCK_NOW -le $(($__PCLOCK_WORK_HOURS_ARY[2]+1800)) ]
    then
        __PCLOCK_TOTAL=$(($__PCLOCK_WORK_HOURS_ARY[2]-$__PCLOCK_WORK_HOURS_ARY[1]-$__PCLOCK_LUNCH_BREAKS_ARY[2]+$__PCLOCK_LUNCH_BREAKS_ARY[1]))
        # echo $__PCLOCK_TOTAL

        __PCLOCK_ELAPSED=$__PCLOCK_NOW
        if [ $__PCLOCK_NOW -ge $__PCLOCK_LUNCH_BREAKS_ARY[1] ]  && [ $__PCLOCK_NOW -le $__PCLOCK_LUNCH_BREAKS_ARY[2] ]
        then
            __PCLOCK_ELAPSED=$__PCLOCK_LUNCH_BREAKS_ARY[1]
        fi
        __PCLOCK_ELAPSED=$(($__PCLOCK_ELAPSED-$__PCLOCK_WORK_HOURS_ARY[1]))
        # echo $__PCLOCK_ELAPSED

        if [ $__PCLOCK_NOW -ge $__PCLOCK_LUNCH_BREAKS_ARY[2] ]
        then
            __PCLOCK_ELAPSED=$(($__PCLOCK_ELAPSED-$__PCLOCK_LUNCH_BREAKS_ARY[2]+$__PCLOCK_LUNCH_BREAKS_ARY[1]))
        fi
        # echo $__PCLOCK_ELAPSED

        if [ $__PCLOCK_ELAPSED -gt $__PCLOCK_TOTAL ]
        then
            __PCLOCK_ELAPSED=$__PCLOCK_TOTAL
        fi

        __PCLOCK=`echo "scale=2; 100*$__PCLOCK_ELAPSED/$__PCLOCK_TOTAL" | bc -l`
        __PCLOCK=`echo $__PCLOCK | sed 's/0*$//g'`
        __PCLOCK=`echo $__PCLOCK | sed 's/\.$//g'`
        __PCLOCK="$__PCLOCK%"
    fi

fi
echo -n "$__PCLOCK"
