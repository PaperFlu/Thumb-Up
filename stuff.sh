########################################################################
#
# Thumb / Force / 3D / Whatever-You-Call Gesture Stuff
# by PaperFlu and you
#
########################################################################

#########################
# Navigation Bar Related
#########################

navigation_back()
{
  input keyevent 4
}

navigation_home()
{
  input keyevent 3
}

navigation_recents()
{
  input keyevent 187
}

navigation_back_alpha()
{
  screen_touch_relative 160 2300 4 90
}

navigation_home_alpha()
{
  screen_touch_relative 490 2300 4 270
}

navigation_recents_alpha()
{
  screen_touch_relative 2910 2300 4 2215
}

################
# Media Related
################

media_pause()
{
  input keyevent 127
}

media_play()
{
  input keyevent 126
}

media_play_pause()
{
  input keyevent 85
}

media_next()
{
  input keyevent 87
}

media_previous()
{
  input keyevent 88
}

##############
# App Related
##############

app_tasker_alpha()
{
  am broadcast --user current -a net.dinglisch.android.taskerm.thumbTouch
}

################
# Pre-functions
################

screen_touch_absolute()
{
  sendevent $TOUCH_EVENT_PATH 3 57 -1
  sendevent $TOUCH_EVENT_PATH 0 0 0

  sendevent $TOUCH_EVENT_PATH 3 57 20
  # ABS_MT_POSITION_X
  sendevent $TOUCH_EVENT_PATH 3 53 $1
  # ABS_MT_POSITION_Y
  sendevent $TOUCH_EVENT_PATH 3 54 $2
  # ABS_MT_PRESSURE
  #sendevent $TOUCH_EVENT_PATH 3 58 10
  # ABS_MT_TOUCH_MAJOR
  #sendevent $TOUCH_EVENT_PATH 3 48 11
  # ABS_MT_TOUCH_MINOR
  #sendevent $TOUCH_EVENT_PATH 3 49 10
  sendevent $TOUCH_EVENT_PATH 0 0 0

  sleep 0.005

  sendevent $TOUCH_EVENT_PATH 3 57 -1
  sendevent $TOUCH_EVENT_PATH 0 0 0
}

# Portial parameters first.
screen_touch_relative()
{
  case $SCREEN_ORIENTATION in
    0)
      local TOUCH_X=$1
      local TOUCH_Y=$2;;
    1)
      local TOUCH_X=$3
      local TOUCH_Y=$4;;
    2)
      local TOUCH_X=$(($SCREEN_WIDTH - $1))
      local TOUCH_Y=$(($SCREEN_HEIGHT - $2));;
    3)
      local TOUCH_X=$(($SCREEN_WIDTH - $3))
      local TOUCH_Y=$(($SCREEN_HEIGHT - $4));;
  esac
  screen_touch_absolute $TOUCH_X $TOUCH_Y &
}


