#!/bin/dash
# Catppuccin Macchiato Dark Theme with Pastel Foreground Colors for Functions

# Dark Background Colors
black="#1e1e2e"
grey="#2a2e3b"
darkblue="#5e81ac"

# Pastel Foreground Colors
green="#a6e3a1"        # Pastel Green
white="#f5e0dc"        # Pastel White
blue="#89b4fa"         # Pastel Blue
red="#f28f8f"          # Pastel Red
cyan="#94e2d5"         # Pastel Cyan
yellow="#f9e2af"       # Pastel Yellow
magenta="#d6a0f7"      # Pastel Magenta
peach="#f5a97f"        # Pastel Peach
lavender="#b5a0e1"     # Pastel Lavender
rosewater="#f5e0dc"
crust="#11111b"
# ^c$var^ = fg color (bright pastel foreground)
# ^b$var^ = bg color (dark background)

interval=0

bluet() {
  vol=$(pamixer --get-volume)

  # Check if Bluetooth is unblocked
  bluetooth_status=$(bluetoothctl info | grep "Battery" | awk '{print $4}')
  b_i=" "

  if [ -z "$bluetooth_status" ]; then
    # Bluetooth is blocked
    printf "^c$red^^b$black^$b_i^c$white^:$vol"
  else
    # Bluetooth is unblocked, check if a device is connected using bluetoothctl
    connected_device=$(bluetoothctl info | grep "Device" | awk '{print $2}')

    if [ -z "$connected_device" ]; then
      # No device connected
      printf "^c$red^^b$black^$b_i^c$white^:$vol"
    else
      # Device is connected
      printf "^c$green^^b$black^$b_i^c$white^battery:$bluetooth_status:$vol"
    fi
  fi
}

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

  # Changing color for CPU function
  printf "^c$crust^^b$lavender^  "
  printf "^c$crust^^b$magenta^ $cpu_val"
}

pkg_updates() {
  updates=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l) # arch

  # Change color for package updates function
  if [ -z "$updates" ]; then
    printf "^c$green^^b$black^  "
  else
    printf "^c$red^^b$black^   $updates"
  fi
}

battery() {
  get_capacity="$(cat /sys/class/power_supply/BAT1/capacity)"
  # Changing color for battery
  printf "^c$cyan^   $get_capacity"
}

mem() {
  # Changing color for memory usage
  printf "^c$crust^^b$lavender^  "
  printf "^c$crust^^b$magenta^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
  # Changing color for wlan status
  case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
    up) printf "^c$green^^b$black^󰤨 ";;
    down) printf "^c$red^^b$black^󰤭 ";;
  esac
}

clock() {
  # Changing color for clock
  printf "^c$crust^^b$lavender^   "
  printf "^c$crust^^b$magenta^ $(date '+%H:%M')  "
}

while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
  interval=$((interval + 1))
    # $(battery) $(brightness) $(cpu) $(mem) $(wlan) $(clock)
    sleep 1 && xsetroot -name "$(cpu) $(mem) $updates $(wlan) $(bluet) $(clock)  "
done
