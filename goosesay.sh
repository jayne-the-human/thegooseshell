#!/bin/bash

# Released under MIT License
# (C) 2020 Jayne the Human

# USAGE
# Goose in the Shell
#     .-~~-.          goosage:
#    /   _  \           ./goosesay.sh [flags] "string to honk"
#   |     ` /'-.__    flags:
#   |  ._ ,;_.---~`     -h  Show this help message
#   \    '/             -s  Surprise goosening
#    \    \           beware:
#     \____\                The unfed goose

# GOOSE
#    .-~~-.            
#   /   _  \           
#  |     ` /'-.__   /  
#  |     ,;_.-,-~`  -  
#  \    '/  `-_\    \  
#   \    \             
#    \____\            

print_goose() {
    # Reads lines from this file and print them back
    # (hacky way to avoid escaping the ASCII goose art)
    START="$1"
    MESSAGE="$2"
    MAX_LENGTH=40
    MAX_LINES=7
    if [ ! -z "$MESSAGE" ]; then
        lines=()
        linecount=0
        currentline=""
        overflow=""
        IFS=' '
        # Word wrap the message
        for word in $MESSAGE; do
            if [ $linecount -ge $MAX_LINES ]; then
                overflow="$overflow $word"
            else
                if [ -z "$currentline" ]; then
                    currentline="$word"
                    lines[$linecount]="$currentline"
                    continue
                else
                    testline="$currentline $word"
                fi
                if [ ${#testline} -le $MAX_LENGTH ]; then
                    currentline="$testline"
                    lines[$linecount]="$currentline"
                else
                    lines[$linecount]="$currentline"
                    currentline="$word"
                    ((linecount++))
                    if [ $linecount -ge $MAX_LINES ]; then
                        overflow="$word"
                    else
                        lines[$linecount]="$currentline"
                    fi
                fi
            fi
        done

        # Lazy vertical centering
        case $linecount in
            0)
                lines[3]=${lines[0]}
                lines[0]=""
                ;;
            1 | 2)
                lines[4]=${lines[2]}
                lines[3]=${lines[1]}
                lines[2]=${lines[0]}
                lines[1]=""
                lines[0]=""
                ;;
            3 | 4 | 5)
                lines[6]=${lines[5]}
                lines[5]=${lines[4]}
                lines[4]=${lines[3]}
                lines[3]=${lines[2]}
                lines[2]=${lines[1]}
                lines[1]=${lines[0]}
                lines[0]=""
                ;;
        esac
    fi

    IFS=''
    echocount=0
    while read -r line; do
        if [ "$START" = true ]; then
            if [ "${line:0:1}" != "#" ]; then
                break
            else
                echo -n ${line:1}
                echo ${lines[$echocount]}
                ((echocount++))
            fi
        elif [ "$line" == "$START" ]; then
            START=true
            continue
        fi
    done < $0
}

LOOSE_GOOSE="/tmp/goose_on_the_loose"
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    print_goose "# USAGE"

    if [[ -z "$1" && ! -f "$LOOSE_GOOSE" ]]; then
        #echo " The goose hungers!" # (for command line arguments)
        touch $LOOSE_GOOSE
        bash -c "$0 -s"
    fi
    exit
fi

if [[ "$1" == "-s" || "$1" == "-S" ]]; then
    # Suprise goose
    if [ -z "$2" ]; then
        HONK="HONK!"
    else
        HONK="$2"
    fi
    randsleep=$(( ( RANDOM % 270 )  + 30 ))
    if [ "$1" == "-s" ]; then
        bash -c "sleep $randsleep; echo''; $0 '$HONK'; rm -f $LOOSE_GOOSE" &
    else
        # oh no
        bash -c "sleep $randsleep; echo''; $0 '$HONK'; $0 -S '$HONK';" &
    fi
else
    # Immediate goose
    print_goose "# GOOSE" "$1"
    while [ ! -z "$overflow" ]; do
       print_goose "# GOOSE" "$overflow"
    done
fi
