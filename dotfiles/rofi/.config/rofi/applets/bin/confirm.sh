#!/bin/bash

## Author  : Julian Jee
## Github  : @jeewangue
#
## Applets : Confirm

# Import Current Theme
source "$HOME/.config/rofi/applets/shared/theme.bash"
theme="$type/$style"

# Theme Elements
prompt="${1:-Confirm}"
mesg="${2:-Are you sure?}"

if [[ "$theme" == *'type-1'* ]]; then
  list_col='1'
  list_row='2'
  win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
  list_col='1'
  list_row='2'
  win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
  list_col='1'
  list_row='2'
  win_width='425px'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
  list_col='2'
  list_row='1'
  win_width='550px'
fi

# Options

option_1="  Yes"
option_2="  No"

# Rofi CMD
rofi_cmd() {
  rofi -theme-str "window {width: $win_width;}" \
    -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme "${theme}"
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2" | rofi_cmd
}

# Execute Command
run_cmd() {
  if [[ "$1" == '--opt1' ]]; then
    notify-send "$prompt" "Confirmed"
    exit 0
  elif [[ "$1" == '--opt2' ]]; then
    notify-send "$prompt" "Cancelled"
    exit 1
  fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
"$option_1")
  run_cmd --opt1
  ;;
"$option_2")
  run_cmd --opt2
  ;;
esac

