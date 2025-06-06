#!/bin/bash

ACTIVE_BG="#444444"
ACTIVE_FG="#ffffff"
INACTIVE_BG="#222222"
INACTIVE_FG="#777777"

SELECTED_TAB=1

current_session=$(tmux display-message -p '#S')

get_windows() {
  tmux list-windows -t "$current_session" -F "#I: #W #{?window_active,(active),}" | sort -n
}

draw_tabs() {
  local selected=$1
  clear

  local tab1 tab2 tab3

  if [ "$selected" -eq 1 ]; then
    tab1="\033[48;5;8m\033[38;5;15m 1:Switch \033[0m"
  else
    tab1="\033[48;5;235m\033[38;5;244m 1:Switch \033[0m"
  fi

  if [ "$selected" -eq 2 ]; then
    tab2="\033[48;5;8m\033[38;5;15m 2:Rename \033[0m"
  else
    tab2="\033[48;5;235m\033[38;5;244m 2:Rename \033[0m"
  fi

  if [ "$selected" -eq 3 ]; then
    tab3="\033[48;5;8m\033[38;5;15m 3:Delete \033[0m"
  else
    tab3="\033[48;5;235m\033[38;5;244m 3:Delete \033[0m"
  fi

  local tabs_line="$tab1 $tab2 $tab3"

  local visible_tabs_length=$(echo -e "$tabs_line" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)
  visible_tabs_length=$((visible_tabs_length - 1))  # Remove newline count

  local terminal_width=$(tput cols)
  local padding=$(( (terminal_width - visible_tabs_length) / 2 ))

  printf "%*s" "$padding" ""
  echo -e "$tabs_line"
  echo
}

switch_window() {
  local selection=$1
  local index=$(echo "$selection" | cut -d':' -f1 | tr -d ' ')
  tmux select-window -t "$current_session:$index"
}

rename_window() {
  local selection=$1
  local index=$(echo "$selection" | cut -d':' -f1 | tr -d ' ')
  local old_name=$(echo "$selection" | cut -d':' -f2- | awk '{print $1}')

  tput cup $(tput lines) 0
  tput el
  echo -n "Current name: $old_name | New name: "
  read -r new_name

  if [ -n "$new_name" ]; then
    tmux rename-window -t "$current_session:$index" "$new_name"
  fi
}

delete_window() {
  local selection=$1
  local index=$(echo "$selection" | cut -d':' -f1 | tr -d ' ')

  tput cup $(tput lines) 0
  tput el
  echo -n "Are you sure you want to delete window '$index'? (y/n): "
  read -r confirm

  if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    tmux kill-window -t "$current_session:$index"
  fi
}

main() {
  local tab=$SELECTED_TAB

  while true; do
    draw_tabs $tab

    if [ $tab -eq 1 ]; then
      header=""
    elif [ $tab -eq 2 ]; then
      header=""
    else
      header=""
    fi

    windows=$(get_windows)

    if [ -z "$windows" ]; then
      echo "No tmux windows found."
      echo "Press any key to exit..."
      read -n 1
      break
    fi

    result=$(echo "$windows" | fzf \
      --header "$header" \
      --expect=1,2,3 \
      --height=90% \
      --ansi)

    key=$(echo "$result" | head -1)
    selection=$(echo "$result" | tail -1)

    if [ -z "$selection" ] && [ -z "$key" ]; then
      break
    elif [ "$key" = "1" ]; then
      tab=1
      continue
    elif [ "$key" = "2" ]; then
      tab=2
      continue
    elif [ "$key" = "3" ]; then
      tab=3
      continue
    fi

    if [ -n "$selection" ]; then
      case $tab in
        1) switch_window "$selection"; break ;;
        2) rename_window "$selection"; draw_tabs $tab; continue ;;
        3) delete_window "$selection"; draw_tabs $tab; continue ;;
      esac
    fi
  done
}

if [ -z "$TMUX" ]; then
  echo "This script must be run inside a tmux session."
  exit 1
fi

if ! command -v fzf &> /dev/null; then
  echo "Error: fzf is not installed. Please install it first."
  exit 1
fi

main

