########################################################################
#
# Device-dependent Info Adjuster
# by PaperFlu
#
# This script is poorly designed at present.
#
########################################################################

. adjusterAPI.sh

SPAWN_VERSION="v2.002-Tasker"

SPAWN_REQUIRED_TOUCHED_TIMES=%ThumbAdjusterRequiredTouchTimes
DRIVER_TYPE="%ThumbSettingsDriverType"
TASKER_CONSOLE_FILE=%ThumbAdjusterConsoleFile
TASKER_RESULTS_FILE=%ThumbSettingsFile

NOCOLOR='</font><font color="#EEEEEE">'
RED='</font><font color="#CD0000">'
GREEN='</font><font color="#00CD00">'
ORANGE='</font><font color="#CDCD00">'
BLUE='</font><font color="#6495ED">'
PURPLE='</font><font color="#CD00CD">'
CYAN='</font><font color="#00CDCD">'
LIGHTGRAY='</font><font color="#E5E5E5">'
DARKGRAY='</font><font color="#7F7F7F">'
LIGHTRED='</font><font color="#FF0000">'
LIGHTGREEN='</font><font color="#00FF00">'
YELLOW='</font><font color="#FFFF00">'
LIGHTBLUE='</font><font color="#5C5CFF">'
LIGHTPURPLE='</font><font color="#FF00FF">'
LIGHTCYAN='</font><font color="#00FFFF">'
WHITE='</font><font color="white">'

LOG_LEVEL=1
LOG_TEXT_FIXES=("<font>" "</font><br />\n")
LOG_UI_ENABLED=false

on_spawn_start()
{
  OUTPUT_FILE=$TASKER_CONSOLE_FILE
}

on_spawn_end()
{
  OUTPUT_FILE=$TASKER_RESULTS_FILE
  LOG_TEXT_FIXES=("" "\n")

  ui_log clear
  ui_log 0 "TOUCH_EVENT_PATH=$TOUCH_EVENT_PATH"
  ui_log 0 "EVENT_WIDTH=$EVENT_WIDTH"
  ui_log 0 "EVENT_HEIGHT=$EVENT_HEIGHT"
  ui_log 0 "SCREEN_WIDTH=$SCREEN_WIDTH"
  ui_log 0 "SCREEN_HEIGHT=$SCREEN_HEIGHT"
  ui_log 0 "MIN_THUMB_AREA=$MIN_THUMB_AREA"
  ui_log
}

spawn_data &

