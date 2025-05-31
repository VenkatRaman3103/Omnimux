#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

default_key_binding="J"
default_display_mode="popup"

key_binding=$(tmux show-option -gqv @termonaut-key)
key_binding=${key_binding:-$default_key_binding}

display_mode=$(tmux show-option -gqv @termonaut-display-mode)
display_mode=${display_mode:-$default_display_mode}

case "$display_mode" in
    "popup")
        display_command="display-popup -E -w 100% -h 90% -S \"bg=#0c0c0c fg=#0c0c0c\" \"$CURRENT_DIR/script.sh\""
        ;;
    "window")
        display_command="new-window \"$CURRENT_DIR/script.sh\""
        ;;
    *)
        display_command="display-popup -E -w 100% -h 90% -S \"bg=#0c0c0c fg=#0c0c0c\" \"$CURRENT_DIR/script.sh\""
        ;;
esac

tmux bind-key "$key_binding" $display_command
