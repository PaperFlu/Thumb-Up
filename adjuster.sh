########################################################################
#
# Device-dependent Info Adjuster
# by PaperFlu
#
# This script is poorly designed at present.
#
########################################################################

. baseAPI.sh
shopt -s lastpipe
set +m

LOG_LEVEL=1
REQUIRED_TOUCHED_TIMES=5

# Temp
TOUCHED_TIMES=0
STEP=1
MAX_SIZE_IN_ALL_TESTS=0
MIN_SIZE_IN_ALL_TESTS=1000

# Results
TOUCH_EVENT_PATH=
SCREEN_WIDTH=0
SCREEN_HEIGHT=0
MIN_THUMB_AREA=0

print_step_info()
{
  case $STEP in
    1)
      ui_log 0 ""
      ui_log 0 "= ${LIGHTRED}Device-dependent${LIGHTGREEN} Info Adjuster"
      ui_log 0 "  ${LIGHTGREY}v1.264-2019.12.11"
      ui_log 0 ""
      ui_log 0 "- ${LIGHTCYAN}Notes:"
      ui_log 0 ""
      ui_log 0 "1. We made it a single script to get your device-dependent info for efficiency and mostly that we are not responsible for the correctness,"
      ui_log 0 "   which means you have to check the data BY YOURSELF before you type it into parameters.sh."
      ui_log 0 "2. It's NOT strange if your device's width is greater than the height."
      ui_log 0 "3. MIN_THUMB_AREA varies between each test. Just choose an average one."
      ui_log 0 ""
      ui_log 0 "- ${LIGHTCYAN}Begin:"
      ui_log 0 ""
      ui_log 0 "Step ${BLUE}1/3${NOCOLOR}, touch screen to get touch driver info."
    ;;
    2)
      ui_log 1 "Touch event path: $TOUCH_EVENT_PATH"
      ui_log 1 "Screen width: $SCREEN_WIDTH"
      ui_log 1 "Screen height: $SCREEN_HEIGHT"
      ui_log 0 ""
      ui_log 0 "Step ${BLUE}2/3${NOCOLOR}, touch screen $REQUIRED_TOUCHED_TIMES times in the way you used to."
    ;;
    3)
      ui_log 1 "Max touch size: $MAX_SIZE_IN_ALL_TESTS"
      ui_log 0 ""
      ui_log 0 "Step ${BLUE}3/3${NOCOLOR}, touch screen another $REQUIRED_TOUCHED_TIMES times using your thumb, the front part of the finger, the opposite side of the fingernail."
    ;;
    4)
      ui_log 1 "Min touch size: $MIN_SIZE_IN_ALL_TESTS"
      ui_log 0 ""
      ui_log 0 "Done."

      MIN_THUMB_AREA=$(( ($MAX_SIZE_IN_ALL_TESTS + $MIN_SIZE_IN_ALL_TESTS) / 2 ))

      ui_log 0 ""
      ui_log 0 "- ${LIGHTCYAN}Results:"
      ui_log 0 ""
      ui_log 0 "TOUCH_EVENT_PATH: $TOUCH_EVENT_PATH"
      ui_log 0 "SCREEN_WIDTH: $SCREEN_WIDTH"
      ui_log 0 "SCREEN_HEIGHT: $SCREEN_HEIGHT"
      ui_log 0 "MIN_THUMB_AREA: $MIN_THUMB_AREA"
      ui_log 0 ""
      ui_log 0 "Now, you could fill these data into settings.sh"
    ;;
  esac
}

spawn_data()
{
  print_step_info
  
  # Step 1
  TOUCH_EVENT_PATH=$(getevent -l -c 6 | grep -m1 "ABS" | cut -b 0-17)
  
  local TOUCH_EVENT_INFO=$(getevent -l -i $TOUCH_EVENT_PATH)

  local SCREEN_WIDTH_TEMP=$(echo "$TOUCH_EVENT_INFO" | awk '$1 ~ /POSITION_X/ && $7=="max" { print $8 }')
  SCREEN_WIDTH=${SCREEN_WIDTH_TEMP:0:-1}

  local SCREEN_HEIGHT_TEMP=$(echo "$TOUCH_EVENT_INFO" | awk '$1 ~ /POSITION_Y/ && $7=="max" { print $8 }')
  SCREEN_HEIGHT=${SCREEN_HEIGHT_TEMP:0:-1}
  
  STEP=2
  print_step_info

  # TO DO: Logic.
  on_touch_end() {
    TOUCHED_TIMES=$(( $TOUCHED_TIMES+1 ))
  
    if [ $STEP == 2 ]; then
      if [ $MAX_SIZE_IN_ALL_TESTS -lt $AREA_MAX ]; then
        MAX_SIZE_IN_ALL_TESTS=$AREA_MAX
      fi
      if [ $TOUCHED_TIMES == $REQUIRED_TOUCHED_TIMES ]; then
        TOUCHED_TIMES=0
        
        STEP=3
        print_step_info
      fi
    elif [ $STEP == 3 ]; then
      if [ $MIN_SIZE_IN_ALL_TESTS -gt $AREA_MAX ]; then
        MIN_SIZE_IN_ALL_TESTS=$AREA_MAX
      fi
      if [ $TOUCHED_TIMES == $REQUIRED_TOUCHED_TIMES ]; then
        STEP=4
        print_step_info

        ui_log 0 ""
        exit 0
      fi
    fi
  }

  line_buffer hexdump $TOUCH_EVENT_PATH | touch_status_update
  
}

spawn_data

