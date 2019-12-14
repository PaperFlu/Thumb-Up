########################################################################
#
# Device and Finger dependent Info & Gestures Customize
# by PaperFlu and you
#
# Please use adjuster.sh to acquire the accurate info.
#
########################################################################

# Device and Finger dependent Info
MIN_THUMB_AREA=145
MIN_MOVED_DISTANCE=160

TOUCH_EVENT_PATH=/dev/input/event0
SCREEN_WIDTH=3072
SCREEN_HEIGHT=2304

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
  if [ $IS_MOVED == true ]; then
    if [ $IS_THUMB == true ]; then
      case "${DIRECTIONS_THUMB[*]}" in
        sideup) navigation_back;;
        sidedown) navigation_home;;
        centerdown) navigation_recents;;
        sideup-centerdown) media_next;;
        sideup-sidedown) media_play_pause;;
      esac
    fi
  fi
}

