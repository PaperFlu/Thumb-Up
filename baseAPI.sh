##########################################################################################
#
# Thumb Gesture General Utility Functions
# by PaperFlu
#
# Inspired by pretty girls. Pretty Girl, I'm PaperFlu @ future
#
##########################################################################################

# Stop if already executed.
if [ $is_base_loaded ]; then
  ui_log 3 "Base API has already been loaded."
  return
fi

is_base_loaded=true

#########
# Logger
#########

# Default log level.
LOG_LEVEL=0

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

ui_log()
{
  if [[ $1 -le $LOG_LEVEL ]]; then
    echo -e "${NOCOLOR}$2${NOCOLOR}"
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
MIN_THUMB_AREA=145
MIN_MOVED_DISTANCE=160
on_touch_start()
{
  :
}
on_touch_change()
{
  :
}
on_touch_end ()
{
  :
}

# Event trends.
IS_JUST_STARTED=false
IS_JUST_ENDED=false

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
  while read EVENT; do
    local EVENT_TYPE=${EVENT:33:4}
    local EVENT_VALUE=$((16#${EVENT:38:4}))

    # For a full list of event types, event values and their meanings,
    # read input.h file from Android Open Source Code.
    case $EVENT_TYPE in
      # X
      0035)
        if [ $IS_JUST_STARTED == true ]; then
          START_POSITION[0]=$EVENT_VALUE
        fi

        POSITION[0]=$EVENT_VALUE
        DISPLACEMENT[0]=$[${POSITION[0]} - ${START_POSITION[0]}]
        ;;
      # Y
      0036)
        if [ $IS_JUST_STARTED == true ]; then
          START_POSITION[1]=$EVENT_VALUE
        fi

        POSITION[1]=$EVENT_VALUE
        DISPLACEMENT[1]=$[${POSITION[1]} - ${START_POSITION[1]}]
        ;;
      # Size or Pressure
      003a)
        if [ $AREA_MAX -lt $EVENT_VALUE ]; then
          AREA_MAX=$EVENT_VALUE
        fi
        ;;
      # Start and End
      0039)
        if [ $EVENT_VALUE != "65535" ]; then
          IS_JUST_STARTED=true

          AREA_MAX=0
          DISTANCE=0

          IS_THUMB=false
          IS_MOVED=false

          DIRECTIONS_NORMAL=()
          DIRECTIONS_THUMB=()

          screen_orientation_update

        else
          IS_JUST_ENDED=true

          thumb_judge
          moved_judge

        fi
        ;;
      # Division Line
      0000)
        if [ $IS_JUST_STARTED == true ]; then
          # Touch started.
          IS_JUST_STARTED=false

          # Call other stuff.
          on_touch_start

        elif [ $IS_JUST_ENDED == true ]; then
          # Touch ended.
          IS_JUST_ENDED=false

          # Call other stuff.
          on_touch_end

        else
          # Normally touching.
          rel_info_update
          distance_update
          direction_update

          # Call other stuff.
          on_touch_change

        fi
        ;;
    esac
    
  done
}

thumb_judge()
{
  if [ $AREA_MAX -gt $MIN_THUMB_AREA ]; then
    IS_THUMB=true
  else
    IS_THUMB=false
  fi
}

moved_judge()
{
  if [ $DISTANCE -gt $MIN_MOVED_DISTANCE ]; then
    IS_MOVED=true
  else
    IS_MOVED=false
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

  if [ $REL_START_POSITION_X -lt $(($REL_SCREEN_WIDTH / 2)) ]; then
    REL_TOUCH_PART="left"
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
    fi

    if [[ ${DIRECTIONS_THUMB[@]: -1} != $CUR_DIRECTION_THUMB ]]; then
      DIRECTIONS_THUMB+=($CUR_DIRECTION_THUMB)
    fi

  fi
}

screen_orientation_update()
{
  SCREEN_ORIENTATION="$(dumpsys input | grep 'SurfaceOrientation' | awk '{ print $2 }')"
}

