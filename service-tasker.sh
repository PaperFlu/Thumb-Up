#########################################
#
# Thumb Gesture Tasker Service
# by PaperFlu
#
#########################################

. baseAPI.sh

###########
# Settings
###########

. ./%ThumbSettingsFile

DRIVER_TYPE="%ThumbSettingsDriverType"
MIN_MOVED_DISTANCE=%ThumbSettingsMinMovedDistance
ENABLE_REL_TOUCH_PART=%ThumbSettingsEnableRelTouchPart

LOG_LEVEL=0
LOG_UI_ENABLED=false


ENABLE_TASKER=false
CUR_GESTURE="%ThumbActionNamesNone"

on_thumb_change()
{
  ENABLE_TASKER=true
  may_change
}

may_change()
{
  local IFS="-"

  if [[ $ENABLE_TASKER == true ]]; then
    if [[ $IS_MOVED == true ]]; then
      case "${DIRECTIONS_THUMB[*]}" in
        sideup)
          announce_tasker "%ThumbActionNamesBack"
          ;;
        sidedown)
          announce_tasker "%ThumbActionNamesHome"
          ;;
        centerdown)
          announce_tasker "%ThumbActionNamesRecents"
          ;;
        sideup-centerdown)
          announce_tasker "%ThumbActionNamesMediaNext"
          ;;
        sideup-sidedown)
          announce_tasker "%ThumbActionNamesMediaPlayOrPause"
          ;;
        sideup-sidedown-centerdown)
          announce_tasker "%ThumbActionNamesScreenLock"
          ;;
        *)
          announce_tasker "%ThumbActionNamesNone"
          ;;
      esac
    else
      announce_tasker "%ThumbActionNamesNone"
    fi
  fi
}

announce_tasker()
{
  if [[ $ENABLE_TASKER == true ]]; then
    local NEW_GESTURE="$1"
    if [ "$NEW_GESTURE" != "$CUR_GESTURE" ]; then
      echo -n ";$NEW_GESTURE" >> ./%ThumbActionFile
      CUR_GESTURE=$NEW_GESTURE
    fi
  fi
}

on_gesture_change_thumb()
{
  may_change
}

on_moved_change()
{
  may_change
}

on_touch_end()
{
  if [[ $ENABLE_TASKER == true ]]; then
    announce_tasker "%ThumbActionNamesFire"

    ENABLE_TASKER=false
    CUR_GESTURE="%ThumbActionNamesNone"
  fi
}

##########################
# Start Observing Touches
##########################

start_service &

