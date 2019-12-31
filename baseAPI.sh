##########################################################################################
#
# Thumb Gesture General Utility Functions
# by PaperFlu
#
# Inspired by pretty girls. Pretty Girl, I'm PaperFlu @ future
#
##########################################################################################

# Stop if already executed.
if [[ $IS_BASE_LOADED == true ]]; then
  ui_log 3 "Base API has already been loaded."
  ui_log
  return
fi

IS_BASE_LOADED=true

######################
# Temporary Directory
######################

THUMB_TMP=/data/local/tmp/thumb-up

# Set up.
mkdir -p $THUMB_TMP

##########
# Busybox
##########

BUSYBOX_DIR=$THUMB_TMP/busybox

# Yeah, ensure busybox.
# Mostly copy from Magisk util_functions.sh file.
ensure_busybox() {
  if [ -x $THUMB_TMP/busybox/busybox ]; then
    [ -z $BUSYBOX_DIR ] && BUSYBOX_DIR=$THUMB_TMP/busybox
  else
    # Construct the PATH
    [ -z $BUSYBOX_DIR ] && BUSYBOX_DIR=$THUMB_TMP/busybox
    mkdir -p $BUSYBOX_DIR
    cp ./busybox $BUSYBOX_DIR/
    chmod 755 $BUSYBOX_DIR/*
    $BUSYBOX_DIR/busybox --install -s $BUSYBOX_DIR
  fi
  echo $PATH | grep -q "^$BUSYBOX_DIR" || export PATH=$BUSYBOX_DIR:$PATH
}

ensure_busybox

#########
# Logger
#########

# Default log level.
LOG_LEVEL=0
OUTPUT_FILE=

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

LOG_TEXT=""
LOG_TEXT_FIXES=("$NOCOLOR" "$NOCOLOR\n")
LOG_UI_ENABLED=true

ui_log()
{
  if [ ! -z $1 ]; then
    if [ "$1" == "clear" ]; then
      if [ "$OUTPUT_FILE" != "" ]; then
        echo -n "" > ./$OUTPUT_FILE
      fi
      clear
    elif [ "$1" == "cancel" ]; then
      LOG_TEXT=""
    elif [ $1 -le $LOG_LEVEL ]; then
      LOG_TEXT+="${LOG_TEXT_FIXES[0]}${2}${LOG_TEXT_FIXES[1]}"
    fi
  else
    if [ ! -z $OUTPUT_FILE ]; then
      echo -e -n "$LOG_TEXT" >> ./$OUTPUT_FILE
    fi
    if [[ $LOG_UI_ENABLED == true ]]; then
      echo -e -n "$LOG_TEXT"
    fi
    LOG_TEXT=""
  fi
}

###########################
# Code Language Extensions
###########################

# Let the pipe line-buffered instead of buffered a lot to process instantly.
# Modified from: https://unix.stackexchange.com/a/61833 along with it's comments.
line_buffer()
{
  echo | script -q -c "$*" /dev/null
}

#########################
# Touch Status Recorders
#########################

# Default.
TOUCH_EVENT_PATH=
EVENT_WIDTH=0
EVENT_HEIGHT=0
SCREEN_WIDTH=0
SCREEN_HEIGHT=0
MIN_THUMB_AREA=160
MIN_MOVED_DISTANCE=110
ENABLE_REL_TOUCH_PART=true
DRIVER_TYPE="39-ff"
on_service_start()
{
  :
}
on_service_end()
{
  :
}
on_touch_start()
{
  :
}
on_touch_change()
{
  :
}
on_touch_end()
{
  :
}
on_thumb_change()
{
  :
}
on_moved_change()
{
  :
}
on_gesture_change_normal()
{
  :
}
on_gesture_change_thumb()
{
  :
}

# Event trends.
# 1: Impossible, 2: Probably, 3: Definitely
TRENDS_JUST_STARTED=1
TRENDS_JUST_ENDED=1

# Absolute touch info.
START_POSITION=(0 0)
POSITION=(0 0)
DISPLACEMENT=(0 0)
AREA_MAX=0
DISTANCE=0

# Relative touch position info.
REL_SCREEN_WIDTH=0
REL_START_POSITION_X=0
REL_DISPLACEMENT=(0 0)
REL_TOUCH_PART=""

# Touch quality. Booleans.
IS_THUMB=false
IS_MOVED=false

# Device status.
SCREEN_ORIENTATION="1"

# Direction.
# sin(45)x100=70.7...
SIN_45_DEG_100X=70
DIRECTIONS_NORMAL=()
DIRECTIONS_THUMB=()

touch_status_update()
{
  # Mark running service.
  echo -n "$BASHPID" > ./process-id

  on_service_start

  handle_x()
  {
    local SCREEN_VALUE=$(( $EVENT_VALUE * $SCREEN_WIDTH / $EVENT_WIDTH ))

    if [ $TRENDS_JUST_STARTED -eq 3 ]; then
      START_POSITION[0]=$SCREEN_VALUE
    fi

    POSITION[0]=$SCREEN_VALUE
    DISPLACEMENT[0]=$[${POSITION[0]} - ${START_POSITION[0]}]
  }

  handle_y()
  {
    local SCREEN_VALUE=$(( $EVENT_VALUE * $SCREEN_HEIGHT / $EVENT_HEIGHT ))

    if [ $TRENDS_JUST_STARTED -eq 3 ]; then
      START_POSITION[1]=$SCREEN_VALUE
    fi

    POSITION[1]=$SCREEN_VALUE
    DISPLACEMENT[1]=$[${POSITION[1]} - ${START_POSITION[1]}]
  }
  
  handle_size()
  {
    if [ $AREA_MAX -lt $EVENT_VALUE ]; then
      AREA_MAX=$EVENT_VALUE
    fi
  }
  
  handle_just_start()
  {
    TRENDS_JUST_STARTED=3

    AREA_MAX=0
    DISTANCE=0

    IS_THUMB=false
    IS_MOVED=false

    DIRECTIONS_NORMAL=()
    DIRECTIONS_THUMB=()

    screen_orientation_update
  }
  
  handle_just_end()
  {
    TRENDS_JUST_ENDED=3
  }

  while read EVENT; do
    local EVENT_TYPE=${EVENT:33:4}
    local EVENT_VALUE=$((16#${EVENT:38:4}))

    # For a full list of event types, event values and their meanings,
    # read input.h file from Android Open Source Code.
    case $EVENT_TYPE in
      # X
      0035)
        handle_x
        ;;
      # Y
      0036)
        handle_y
        ;;
      # Size or Pressure
      003a)
        handle_size
        ;;
      # Division Line
      0000)
        if [ $TRENDS_JUST_STARTED -eq 3 ]; then
          # Touch started.
          TRENDS_JUST_STARTED=1

          # Call other stuff.
          on_touch_start

        elif [ $TRENDS_JUST_ENDED -eq 3 ]; then
          # Touch ended.
          TRENDS_JUST_ENDED=1

          # Call other stuff.
          on_touch_end

        else
          # Normally touching.
          rel_info_update
          distance_update
          direction_update

          thumb_judge
          moved_judge

          # Call other stuff.
          on_touch_change

        fi
        ;;
      *)
        if [ "$DRIVER_TYPE" == "39-ff" ]; then

          if [ "$EVENT_TYPE" == "0039" ]; then
            # Start or End
            if [ $EVENT_VALUE != "65535" ]; then
              handle_just_start
            else
              handle_just_end
            fi
          fi

        elif [ "$DRIVER_TYPE" == "39-0202" ]; then

          case $EVENT_TYPE in
            # Start
            0039)
              if [ $TRENDS_JUST_ENDED -eq 1 ]; then
                handle_just_start
              elif [ $TRENDS_JUST_ENDED -eq 2 ]; then
                TRENDS_JUST_ENDED=1
              fi
              ;;
            # End, probably
            0002)
              if [ $TRENDS_JUST_ENDED -eq 1 ]; then
                TRENDS_JUST_ENDED=2
              elif [ $TRENDS_JUST_ENDED -eq 2 ]; then
                handle_just_end
              fi
              ;;
          esac

        fi
        ;;
    esac
    
  done
}

thumb_judge()
{
  if [ $AREA_MAX -gt $MIN_THUMB_AREA ]; then
    IS_THUMB=true
    on_thumb_change
  fi
}

moved_judge()
{
  local PRE_IS_MOVED=$IS_MOVED

  if [ $DISTANCE -gt $MIN_MOVED_DISTANCE ]; then
    IS_MOVED=true
  else
    IS_MOVED=false
  fi

  if [ $PRE_IS_MOVED != $IS_MOVED ]; then
    on_moved_change
  fi
}

distance_update()
{
  local DISTANCE_SQUARE=$(( $((${DISPLACEMENT[0]} ** 2)) + $((${DISPLACEMENT[1]} ** 2)) ))

  DISTANCE=$(awk -v x=$DISTANCE_SQUARE 'BEGIN{ print int(sqrt(x)) }')
}

rel_info_update()
{
  case $SCREEN_ORIENTATION in
    # portrait
    0)
      REL_SCREEN_WIDTH=$SCREEN_WIDTH
      REL_START_POSITION_X=${START_POSITION[0]}

      REL_DISPLACEMENT[0]=${DISPLACEMENT[0]}
      REL_DISPLACEMENT[1]=$((0 - ${DISPLACEMENT[1]}))
      ;;
    # landscape
    1)
      REL_SCREEN_WIDTH=$SCREEN_HEIGHT
      REL_START_POSITION_X=${START_POSITION[1]}

      REL_DISPLACEMENT[0]=${DISPLACEMENT[1]}
      REL_DISPLACEMENT[1]=${DISPLACEMENT[0]}
      ;;
    # rev. portrait
    2)
      REL_SCREEN_WIDTH=$SCREEN_WIDTH
      REL_START_POSITION_X=$(($REL_SCREEN_WIDTH - ${START_POSITION[0]}))

      REL_DISPLACEMENT[0]=$((0 - ${DISPLACEMENT[0]}))
      REL_DISPLACEMENT[1]=${DISPLACEMENT[1]}
      ;;
    # rev. landscape
    3)
      REL_SCREEN_WIDTH=$SCREEN_HEIGHT
      REL_START_POSITION_X=$(($REL_SCREEN_WIDTH - ${START_POSITION[1]}))

      REL_DISPLACEMENT[0]=$((0 - ${DISPLACEMENT[1]}))
      REL_DISPLACEMENT[1]=$((0 - ${DISPLACEMENT[0]}))
      ;;
  esac
  # echo "-${REL_DISPLACEMENT[*]} +${REL_DISPLACEMENT[*]}"

  if [[ $ENABLE_REL_TOUCH_PART == true ]]; then
    if [ $REL_START_POSITION_X -lt $(($REL_SCREEN_WIDTH / 2)) ]; then
      REL_TOUCH_PART="left"
    else
      REL_TOUCH_PART="right"
    fi
  else
    REL_TOUCH_PART="right"
  fi
}

direction_update()
{
  local CUR_DIRECTION_NORMAL=""
  local CUR_DIRECTION_THUMB=""

  if [ $DISTANCE -gt $MIN_MOVED_DISTANCE ]; then

    local CUR_SIN_100X=$(( $((${REL_DISPLACEMENT[1]} * 100)) / $DISTANCE ))
    local CUR_COS_100X=$(( $((${REL_DISPLACEMENT[0]} * 100)) / $DISTANCE ))

    if (( $((0 - $SIN_45_DEG_100X)) <= $CUR_SIN_100X && $CUR_SIN_100X <= $SIN_45_DEG_100X )); then
      if [[ $CUR_COS_100X > 0 && $REL_TOUCH_PART == "right"
         || $CUR_COS_100X < 0 && $REL_TOUCH_PART == "left" ]]; then
        CUR_DIRECTION_NORMAL="side"
      else
        CUR_DIRECTION_NORMAL="center"
      fi
    else
      if (( $CUR_SIN_100X > 0 )); then
        CUR_DIRECTION_NORMAL="up"
      else
        CUR_DIRECTION_NORMAL="down"
      fi
    fi

    if [[ ${REL_DISPLACEMENT[0]} -ge 0 && $REL_TOUCH_PART == "right"
       || ${REL_DISPLACEMENT[0]} -le 0 && $REL_TOUCH_PART == "left" ]]; then
      CUR_DIRECTION_THUMB="side"
    else
      CUR_DIRECTION_THUMB="center"
    fi
    if [[ ${REL_DISPLACEMENT[1]} -ge 0 ]]; then
      CUR_DIRECTION_THUMB+="up"
    else
      CUR_DIRECTION_THUMB+="down"
    fi


    if [[ ${DIRECTIONS_NORMAL[@]: -1} != $CUR_DIRECTION_NORMAL ]]; then
      DIRECTIONS_NORMAL+=($CUR_DIRECTION_NORMAL)
      on_gesture_change_normal
    fi

    if [[ ${DIRECTIONS_THUMB[@]: -1} != $CUR_DIRECTION_THUMB ]]; then
      DIRECTIONS_THUMB+=($CUR_DIRECTION_THUMB)
      on_gesture_change_thumb
    fi

  fi
}

screen_orientation_update()
{
  SCREEN_ORIENTATION="$(dumpsys input | grep 'SurfaceOrientation' | awk '{ print $2 }')"
}

#################
# Service Toggle
#################

start_service()
{
  # Stop previous process.
  end_service

  # Gain touch event stream by hexdump.
  line_buffer hexdump $TOUCH_EVENT_PATH | touch_status_update
}

end_service()
{
  local RUNNING_PID="$(cat ./process-id)"
  if [ ! -z $RUNNING_PID ]; then
    on_service_end

    echo -n "" > ./process-id
    kill $RUNNING_PID &
  fi
}


