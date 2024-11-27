# arch-droid-display

With this tutorial you will be able to use your Android tablet as a second screen on Linux. For this purpose we are going to use a USB cable.

## My environment

- Laptop Dell XPS 15
	- 13th Gen Intel(R) Core(TM) i9-13900H
	- Nvidia GeForce RTX 4070
	- Arch Linux with i3 and polybar

```shell
$ neofetch
                   -`                    xxxx@xxxx
                  .o+`                   ------------
                 `ooo/                   OS: Arch Linux x86_64
                `+oooo:                  Host: XPS 15 9530
               `+oooooo:                 Kernel: 6.11.7-arch1-1
               -+oooooo+:                Uptime: 43 mins
             `/:-:++oooo+:               Packages: 1493 (pacman)
            `/++++/+++++++:              Shell: bash 5.2.37
           `/++++++++++++++:             Resolution: 1920x1200
          `/+++ooooooooooooo/`           WM: i3
         ./ooosssso++osssssso+`          Theme: Materia-dark [GTK2/3]
        .oossssso-````/ossssss+`         Icons: ePapirus-Dark [GTK2/3]
       -osssssso.      :ssssssso.        Terminal: alacritty
      :osssssss/        osssso+++.       CPU: 13th Gen Intel i9-13900H
     /ossssssss/        +ssssooo/-       GPU: NVIDIA GeForce RTX 4070 Max-Q 
   `/ossssso+/:-        -:/+osssso+-     GPU: Intel Raptor Lake-P [Iris Xe]
  `+sso+:-`                 `.-/+oso:    Memory: 2412MiB / 63943MiB
 `++:.                           `-/+/
 .`                                 `/
```
- Samsung Tablet S5e (SM-T720)
	- Android version 11
	- Version One UI 3.1
## Software

- In Linux:
    - a display manager: xrandr
    - a VNC server:  x11vnc
    -  Android SDK (adb and fastboot)
    
```shell
paru xrandr
paru x11vnc
paru android-sdk-platform-tools
```
![alt text](<img/Pasted image 20241123222632.png>)
 On the tablet:
    - a VNC client app: I use [RealVNC Viewer]( https://play.google.com/store/apps/details?id=com.realvnc.viewer.android)

# Installation
## Get display information
First we start with checking display information with xrandr

```
$ xrandr
Screen 0: minimum 320 x 200, current 1920 x 1200, maximum 16384 x 16384
eDP-1 connected primary 1920x1200+0+0 (normal left inverted right x axis y axis) 336mm x 210mm
   3456x2160     60.00 +
   3200x1800     59.96    59.94
   2880x1620     59.96    59.97
   2560x1600     59.99    59.97
   2560x1440     59.99    59.99    59.96    59.95
   2048x1536     60.00
   1920x1440     60.00
   1856x1392     60.01
   1792x1344     60.01
   2048x1152     59.99    59.98    59.90    59.91
   1920x1200     59.88*   59.95
   1920x1080     60.01    59.97    59.96    59.93
   1600x1200     60.00
   1680x1050     59.95    59.88
   1400x1050     59.98
   1600x900      59.99    59.94    59.95    59.82
   1280x1024     60.02
   1400x900      59.96    59.88
   1280x960      60.00
   1440x810      60.00    59.97
   1368x768      59.88    59.85
   1280x800      59.99    59.97    59.81    59.91
   1280x720      60.00    59.99    59.86    59.74
   1024x768      60.04    60.00
   960x720       60.00
   928x696       60.05
   896x672       60.01
   1024x576      59.95    59.96    59.90    59.82
   960x600       59.93    60.00
   960x540       59.96    59.99    59.63    59.82
   800x600       60.00    60.32    56.25
   840x525       60.01    59.88
   864x486       59.92    59.57
   700x525       59.98
   800x450       59.95    59.82
   640x512       60.02
   700x450       59.96    59.88
   640x480       60.00    59.94
   720x405       59.51    58.99
   684x384       59.88    59.85
   640x400       59.88    59.98
   640x360       59.86    59.83    59.84    59.32
   512x384       60.00
   512x288       60.00    59.92
   480x270       59.63    59.82
   400x300       60.32    56.34
   432x243       59.92    59.57
   320x240       60.05
   360x202       59.51    59.13
   320x180       59.84    59.32
DP-1 disconnected (normal left inverted right x axis y axis)
HDMI-1 disconnected (normal left inverted right x axis y axis)
DP-2 disconnected (normal left inverted right x axis y axis)
DP-3 disconnected (normal left inverted right x axis y axis)
DP-4 disconnected (normal left inverted right x axis y axis)
```

This tells `eDP-1` is connected as primary display  with resolution`1920x1200` and `DP-1`, `HDMI-1`, `DP-2`,`DP-3` and `DP-4` are disconnected at this moment (because I'm not docked at the moment).

We also need the screen resolution of the tablet, we can check this easy online at https://whatismyandroidversion.com/

![alt text](<img/Pasted image 20241123230911.png>)

We know the tablet's resolution is `2560x1600`. Now we can make a virtual monitor.

## Create a virtual monitor

Generate a modeline for the resolution of the VPN screen which we will maken the same size as the tablet. 

Run in terminal:

```shell
$ gtf 2560 1600 60
```

The modeline generated by this command is:

```shell
# 2560x1600 @ 60.00 Hz (GTF) hsync: 99.36 kHz; pclk: 348.16 MHz
Modeline "2560x1600_60.00"  348.16  2560 2752 3032 3504  1600 1601 1604 1656  -HSync +Vsync
```

Copy everything after the word `Modeline` (exclude it) into the next command. Now let's add a new mode for our Android device:

```shell
$ xrandr --newmode "2560x1600_60.00"  348.16  2560 2752 3032 3504  1600 1601 1604 1656  -HSync +Vsync
```

Add this new mode to an unused output port. `HDMI-1` in my case.

*You may have a different output ports so you need to try the output ports that work for you.*

``` shell
$ xrandr --addmode HDMI-1 2560x1600_60.00
```

Now let’s enable `HDMI-1` and move it to the left of the default display (`eDP-1-1`). After this mouse cursor can be moved to the left side more than your default display allows. It is because we are adding 2560×1600 to the left side of our default screen.

```
xrandr --output HDMI-1 --mode 2560x1600_60.00 --left-of eDP-1
```

> If you want to put the second screen in the right side of the default display just change the option `--left-of` by `--right-of`.

## Start VNC Server

Next step is to start the VNC server:

```shell
$ x11vnc -clip 2560x1600+0+0 &
```

## Make a local network with the tablet

Now we're ready to connect the tablet and reverse to port so we can connect like local network. Follow this steps:
- connect your table to the laptop
- turn on USB debugging on your device
- run the reverse command

```shell
$ adb reverse tcp:5900 tcp:5900
```

- Check the tablet, it is possible you need to accept, otherwise adb will tell that the device is unauthorized. When this happen, just accept the connection on the tablet and run the reverse command again.

![alt text](<img/Pasted image 20241124000138.png>)

Now we can connect the tablet to the server, add new, use address `127.0.0.1` and give it a nice name.

![alt text](<img/Pasted image 20241124001210.png>)

![alt text](<img/Pasted image 20241124001230.png>)

![alt text](<img/Pasted image 20241124001241.png>)

![alt text](<img/Pasted image 20241124001300.png>)
![[img/Pasted image 20241124001300.png]]

![alt text](<img/Pasted image 20241124001319.png>)
And we have a tablet as our second screen :)

When ready, close all stuff :

```shell
kill $(ps aux | grep 'x11vnc' | awk '{print $2}')
```

```shell
$ adb kill-server
```

```shell
$ xrandr --output HDMI-1 --off
```

## Summary and scripting

After a reboot of the computer you will have to add the modeline again. I wrote a little script for that

``` shell
$ cat tablet_display.sh
#! /bin/bash
# Create the virtual monitor
xrandr --newmode "2560x1600_60.00"  348.16  2560 2752 3032 3504  1600 1601 1604 1656  -HSync +Vsync
xrandr --addmode HDMI-1 2560x1600_60.00
xrandr --output HDMI-1 --mode 2560x1600_60.00 --left-of eDP-1

# Enable VNC display
x11vnc -clip 2560x1600+0+0 &
```

Connect the tablet and start adb

```shell
$ adb reverse tcp:5900 tcp:5900
```
## Cleaning script

``` shell
$ cat cleaning.sh
#! /bin/bash
kill $(ps aux | grep 'x11vnc' | awk '{print $2}')
adb kill-server
xrandr --output HDMI-1 --off
xrandr --delmode HDMI-1 2560x1600_60.00
xrandr --rmmode "2560x1600_60.00"
```

## Complete script

I wrote a complete script with a menu to start horizontal or vertical, using usb or network and cleaning all settings.

``` shell
#!/bin/bash

# Header
cat << "EOF"

#################################################
#  __  __     ____  _           _               #
#  \ \/ /    |  _ \(_)___ _ __ | | __ _ _   _   #
#   \  /_____| | | | / __| '_ \| |/ _` | | | |  #
#   /  \_____| |_| | \__ \ |_) | | (_| | |_| |  #
#  /_/\_\    |____/|_|___/ .__/|_|\__,_|\__, |  #
#                        |_|            |___/   #
#                                               #
#        Script by r03n - X-DISPLAY Manager     #
#                                               #
#################################################

EOF

# Function to set up vertical display
setup_vertical() {
  echo -e "Setting up vertical display...\n"
  xrandr --newmode "800x1280_60.00"  86.50  800 856 944 1088  1280 1281 1284 1325  -HSync +Vsync
  xrandr --addmode HDMI-1 800x1280_60.00
  xrandr --output HDMI-1 --mode 800x1280_60.00 --left-of eDP-1
}

# Function to set up horizontal display
setup_horizontal() {
  echo -e "Setting up horizontal display...\n"
  xrandr --newmode "1280x800_60.00"  83.46  1280 1344 1480 1680  800 801 804 828  -HSync +Vsync
  xrandr --addmode HDMI-1 1280x800_60.00
  xrandr --output HDMI-1 --mode 1280x800_60.00 --left-of eDP-1
}

# Function to clean display settings
clean_settings() {
  echo -e "Cleaning up settings...\n"

  # Kill x11vnc if running
  X11VNC_PID=$(ps aux | grep 'x11vnc' | grep -v 'grep' | awk '{print $2}')
  if [ -n "$X11VNC_PID" ]; then
      kill "$X11VNC_PID" >/dev/null 2>&1
      echo -e "x11vnc killed (PID: $X11VNC_PID).\n"
  else
      echo -e "x11vnc is not running.\n"
  fi

  # Kill adb server if running
  adb kill-server >/dev/null 2>&1
  if [ $? -eq 0 ]; then
      echo -e "ADB server killed.\n"
  else
      echo -e "ADB server is not running.\n"
  fi

  # Find HDMI-1 mode
  MODE=$(xrandr | grep "HDMI-1" -A 1 | grep "*" | awk '{print $1}')
  if [ -n "$MODE" ]; then
      echo -e "Active mode: $MODE\n"

      # Use var to shutdown HDMI-1 and remove mode
      xrandr --output HDMI-1 --off
      xrandr --delmode HDMI-1 "$MODE"
      xrandr --rmmode "$MODE"
      echo -e "Mode $MODE removed from HDMI-1.\n"
  else
      echo -e "No active mode found for HDMI-1.\n"
  fi
}

# Function to handle connection options
handle_connection() {
  echo "Choose connection type:"
  echo "1) USB"
  echo "2) Network"
  read -p "Enter your choice [1-2]: " connection_choice

  case $connection_choice in
    1)
      echo -e "Checking USB connection...\n"
      adb devices > /tmp/adb_output
      DEVICE_COUNT=$(grep -c "device$" /tmp/adb_output)

      if [ $DEVICE_COUNT -eq 0 ]; then
        echo -e "No suitable devices found.\n"
        echo "Ensure USB tethering is enabled on the tablet and approve the connection if required."
        clean_settings
        exit 1
      else
        echo "Device detected. Setting up VNC connection..."
        adb reverse tcp:5900 tcp:5900
        echo -e "Connection with tablet is ready. \nConnect to VNC using IP address: \n127.0.0.1"
      fi
      ;;
    2)
      echo "Setting up network connection..."
      IP_ADDRESS=$(ip -4 addr show | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1)
      if [ -z "$IP_ADDRESS" ]; then
        echo "Unable to determine IP address. Cleaning up settings..."
        clean_settings
        exit 1
      fi
      echo -e "Network is ready. \nConnect to VNC using IP address: \n$IP_ADDRESS"
      exit 0
      ;;
    *)
      echo "Invalid choice. Returning to main menu."
      ;;
  esac
}

# Main menu
while true; do
  echo "Please select an option:"
  echo "1) Set up vertical display"
  echo "2) Set up horizontal display"
  echo "3) Clean settings"
  echo "4) Exit"
  read -p "Enter your choice [1-4]: " choice

  case $choice in
    1)
      setup_vertical
      handle_connection
      ;;
    2)
      setup_horizontal
      handle_connection
      ;;
    3)
      clean_settings
      echo "Settings cleaned."
      ;;
    4)
      echo "Exiting script. Goodbye!"
      exit 0
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac

  echo # Add a blank line for better readability
done
```
## TODO

1. ~~Write tutorial for over Bluetooth / WiFi~~
2. Secure connection with password and other ports
3. Set polybar and display background correct after connection second screen
4. ~~Create one script to select display resolution, virtual port, start services, close and clean.~~ 
# Resources

Some resources I've used

- https://www.baeldung.com/linux/android-tablet-another-display
- https://sangams.com.np/using-android-pc-as-a-second-monitor-in-linux/