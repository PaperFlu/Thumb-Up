##########################################################################################
#
# Thumb Gesture Service
# by PaperFlu
#
##########################################################################################

. baseAPI.sh
. settings.sh

##########################
# Start Observing Touches
##########################

line_buffer hexdump $TOUCH_EVENT_PATH | touch_status_update

