########################################################################
#
# Device and Finger dependent Info & Gestures Customize
# by PaperFlu and you
#
# Please use adjuster.sh to acquire the accurate info.
#
########################################################################

###################################
# Device and Finger dependent Info
###################################

MIN_THUMB_AREA=165
MIN_MOVED_DISTANCE=110
ENABLE_REL_TOUCH_PART=true

TOUCH_EVENT_PATH=/dev/input/event0

# touch positions reported by the touch events differs between the screen hardware positions.
EVENT_WIDTH=3072
EVENT_HEIGHT=2304

SCREEN_WIDTH=1536
SCREEN_HEIGHT=2048

# Determine info of what importance should be logcat.
# An info of number N means M:
#
#  N  |          M
# ---------------------------
# -1  |        Errors
#  0  |   Intended Outputs
#  1  |   Variables Records
#  2  | Script Status Reports
#  3  |  Developing Outputs
#
# Info of number that isn't higher than $LOG_LEVEL will be print out.
# That means, increase $LOG_LEVEL will show more debugging information.
LOG_LEVEL=3

#####################
# Gestures Customize
#####################

# Import customized functions.
. stuff.sh

# Leave a ":" in it if there's nothing to do with some of them
# to avoid blank-errors.
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
  local IFS="-"

  # echo "+${DIRECTIONS_THUMB[*]}"
  if [[ $IS_MOVED == true ]]; then
    if [[ $IS_THUMB == true ]]; then
      case "${DIRECTIONS_THUMB[*]}" in
        sideup) navigation_back_alpha;;
        sidedown) navigation_home_alpha;;
        centerdown) navigation_recents_alpha;;
        sideup-centerdown) media_next;;
        sideup-sidedown) media_play_pause;;
      esac
    fi
  fi
}

