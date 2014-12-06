#!/bin/sh

# print number of cmd line args
#echo $#

# CONSTANTS
ON="on"
OFF="off"

if [ $# -eq 1 ]
	then
	if [ $1 = $ON ]
		then
		#sudo chmod 777 /sys/class/leds/asus::kbd_backlight/brightness
		echo "3" > /sys/class/leds/asus::kbd_backlight/brightness
	elif [ $1 = $OFF ]
		then
		#sudo chmod 777 /sys/class/leds/asus::kbd_backlight/brightness
		echo "0" > /sys/class/leds/asus::kbd_backlight/brightness
	fi
else
	echo "USAGE:kb_backlight on|off"
fi

# echo "3" > /sys/class/leds/asus::kbd_backlight/brightness
# check=("echo $?")

# if [ $check -ne 0 ]
# 	then
# 	sudo chmod 777 /sys/class/leds/asus::kbd_backlight/brightness
# 	echo "3" > /sys/class/leds/asus::kbd_backlight/brightness
# 	echo "keyboard led is turned on..."
# else
# 	echo "ERROR!..."
# fi

exit 0
