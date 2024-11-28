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
  xrandr --newmode "800x1280_60.00"  86.50  800 856 944 1088  1280 1281 1284 1325  ->
  xrandr --addmode HDMI-1 800x1280_60.00
  xrandr --output HDMI-1 --mode 800x1280_60.00 --left-of eDP-1
  DISPLAY_MODE="vertical"
}

# Function to set up horizontal display
setup_horizontal() {
  echo -e "Setting up horizontal display...\n"
  xrandr --newmode "1280x800_60.00"  83.46  1280 1344 1480 1680  800 801 804 828  -H>
  xrandr --addmode HDMI-1 1280x800_60.00
  xrandr --output HDMI-1 --mode 1280x800_60.00 --left-of eDP-1
  DISPLAY_MODE="horizontal"
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
  # Start x11vnc based on display mode
  if [ "$DISPLAY_MODE" == "vertical" ]; then
    echo "Starting x11vnc for vertical display..."
    x11vnc -clip 800x1280+0+0 &
  elif [ "$DISPLAY_MODE" == "horizontal" ]; then
    echo "Starting x11vnc for horizontal display..."
    x11vnc -clip 1280x800+0+0 &
  fi
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
  echo
done
