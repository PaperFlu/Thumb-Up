########################################################################
#
# Device-dependent Info Adjuster
# by PaperFlu
#
# This script is poorly designed at present.
#
########################################################################

. baseAPI.sh

LOG_LEVEL=0

######################
# Spawn Settings Data
######################

SPAWN_API_VERSION="v4.003-2019.12.31"
SPAWN_VERSION="Unknown"

SPAWN_REQUIRED_TOUCHED_TIMES=5
SPAWN_TOUCHED_TIMES=0
SPAWN_STEP=0
SPAWN_MAX_SIZE_IN_NORMAL=0
SPAWN_MIN_SIZE_IN_THUMB=1000
on_spawn_start()
{
  :
}
on_spawn_end()
{
  :
}

spawn_data()
{
  shopt -s lastpipe
  set +m

  on_spawn_start

  print_spawn_step_info

  # Screen Surface Info.
  local SCREEN_INFO="$(dumpsys input)"

  local SCREEN_WIDTH_TEMP=$(echo "$SCREEN_INFO" | grep 'SurfaceWidth' | awk '{ print $2 }')
  SCREEN_WIDTH=${SCREEN_WIDTH_TEMP:0:-2}

  local SCREEN_HEIGHT_TEMP=$(echo "$SCREEN_INFO" | grep 'SurfaceHeight' | awk '{ print $2 }')
  SCREEN_HEIGHT=${SCREEN_HEIGHT_TEMP:0:-2}

  SPAWN_STEP=1
  print_spawn_step_info

  # Touch Driver Info.
  TOUCH_EVENT_PATH=$(getevent -l -c 6 | grep -m1 "ABS" | cut -b 0-17)

  local TOUCH_EVENT_INFO=$(getevent -l -i $TOUCH_EVENT_PATH)

  local EVENT_WIDTH_TEMP=$(echo "$TOUCH_EVENT_INFO" | awk '$1 ~ /POSITION_X/ && $7=="max" { print $8 }')
  EVENT_WIDTH=${EVENT_WIDTH_TEMP:0:-1}

  local EVENT_HEIGHT_TEMP=$(echo "$TOUCH_EVENT_INFO" | awk '$1 ~ /POSITION_Y/ && $7=="max" { print $8 }')
  EVENT_HEIGHT=${EVENT_HEIGHT_TEMP:0:-1}
  
  SPAWN_STEP=2
  print_spawn_step_info

  # TO DO: Logic.
  on_touch_end() {
    SPAWN_TOUCHED_TIMES=$(( $SPAWN_TOUCHED_TIMES+1 ))
  
    if [ $SPAWN_STEP == 2 ]; then
      if [ $SPAWN_MAX_SIZE_IN_NORMAL -lt $AREA_MAX ]; then
        SPAWN_MAX_SIZE_IN_NORMAL=$AREA_MAX
      fi
      if [ $SPAWN_TOUCHED_TIMES == $SPAWN_REQUIRED_TOUCHED_TIMES ]; then
        SPAWN_TOUCHED_TIMES=0
        
        SPAWN_STEP=3
        print_spawn_step_info
      fi
    elif [ $SPAWN_STEP == 3 ]; then
      if [ $AREA_MAX -lt $SPAWN_MAX_SIZE_IN_NORMAL ]; then
        # Invalid touch.
        SPAWN_TOUCHED_TIMES=$(( $SPAWN_TOUCHED_TIMES-1 ))
        ui_log 0 "${DARKGREY}Invalid thumb touch. Try again please."
        ui_log
      elif [ $AREA_MAX -lt $SPAWN_MIN_SIZE_IN_THUMB ]; then
        SPAWN_MIN_SIZE_IN_THUMB=$AREA_MAX
      fi
      if [ $SPAWN_TOUCHED_TIMES == $SPAWN_REQUIRED_TOUCHED_TIMES ]; then
        SPAWN_STEP=4
        print_spawn_step_info

        on_spawn_end

        end_service
      fi
    fi
  }

  start_service

}

print_spawn_step_info()
{
  case $SPAWN_STEP in
    0)
      ui_log clear
      ui_log 0 ""
      ui_log 0 "= ${WHITE}Device-dependent${LIGHTRED} Info Adjuster"
      ui_log 0 "  ${LIGHTGREY}${SPAWN_VERSION} (API: ${SPAWN_API_VERSION})"
      ui_log 0 ""
      ui_log 0 "- ${LIGHTCYAN}Notes:"
      ui_log 0 ""
      ui_log 0 "1. We made it a single script to get your device-dependent info for efficiency and mostly for that we are not responsible for its correctness,"
      ui_log 0 "   which means that you have to check the results ${WHITE}BY YOURSELF${NOCOLOR} before editing your settings file."
      ui_log 0 "2. It's ${WHITE}NOT${NOCOLOR} strange if EVENT_WIDTH is greater than EVENT_HEIGHT or not."
      ui_log 0 "3. MIN_THUMB_AREA varies between each test. Just choose an average one."
      ui_log 0 ""
      ui_log 0 "- ${LIGHTCYAN}Begin:"
      ui_log
      ;;
    1)
      ui_log 1 "Screen width: $SCREEN_WIDTH"
      ui_log 1 "Screen height: $SCREEN_HEIGHT"
      ui_log 0 ""
      ui_log 0 "Step ${BLUE}1/3${NOCOLOR}, touch screen to get touch driver info."
      ui_log
      ;;
    2)
      ui_log 1 "Touch event path: $TOUCH_EVENT_PATH"
      ui_log 1 "Event width: $EVENT_WIDTH"
      ui_log 1 "Event height: $EVENT_HEIGHT"
      ui_log 0 ""
      ui_log 0 "Step ${BLUE}2/3${NOCOLOR}, swipe or press your screen $SPAWN_REQUIRED_TOUCHED_TIMES times in the way you used to."
      ui_log
      ;;
    3)
      ui_log 1 "Max touch size: $SPAWN_MAX_SIZE_IN_NORMAL"
      ui_log 0 ""
      ui_log 0 "Step ${BLUE}3/3${NOCOLOR}, swipe or press your screen another $SPAWN_REQUIRED_TOUCHED_TIMES times using your thumb, the front part of the finger, the opposite side of the fingernail."
      ui_log
      ;;
    4)
      ui_log 1 "Min touch size: $SPAWN_MIN_SIZE_IN_THUMB"
      ui_log 0 ""
      ui_log 0 "Done."
      ui_log

      MIN_THUMB_AREA=$(( ($SPAWN_MAX_SIZE_IN_NORMAL + $SPAWN_MIN_SIZE_IN_THUMB) / 2 ))

      ui_log 0 ""
      ui_log 0 "- ${LIGHTCYAN}Results:"
      ui_log 0 ""
      ui_log 0 "TOUCH_EVENT_PATH: $TOUCH_EVENT_PATH"
      ui_log 0 "EVENT_WIDTH: $EVENT_WIDTH"
      ui_log 0 "EVENT_HEIGHT: $EVENT_HEIGHT"
      ui_log 0 "SCREEN_WIDTH: $SCREEN_WIDTH"
      ui_log 0 "SCREEN_HEIGHT: $SCREEN_HEIGHT"
      ui_log 0 "MIN_THUMB_AREA: $MIN_THUMB_AREA"
      ui_log 0 ""
      ui_log 0 "Now, you could fill these data into your settings file."
      ui_log 0 ""
      ui_log
      ;;
  esac
}


