#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

default_key_binding="J"
default_display_mode="popup"
default_window_width="100%"
default_window_height="100%"

key_binding=$(tmux show-option -gqv @termonaut-key)
key_binding=${key_binding:-$default_key_binding}

display_mode=$(tmux show-option -gqv @termonaut-display-mode)
display_mode=${display_mode:-$default_display_mode}

window_width=$(tmux show-option -gqv @termonaut-window-width)
window_width=${window_width:-$default_window_width}

window_height=$(tmux show-option -gqv @termonaut-window-height)
window_height=${window_height:-$default_window_height}

case "$display_mode" in
    "popup")
        tmux bind-key "$key_binding" display-popup -E -w "$window_width" -h "$window_height" -S "bg=#0c0c0c fg=#0c0c0c" "$CURRENT_DIR/script.sh"
        ;;
    "window")
        tmux bind-key "$key_binding" new-window "$CURRENT_DIR/script.sh"
        ;;
    *)
        tmux bind-key "$key_binding" display-popup -E -w "$window_width" -h "$window_height" -S "bg=#0c0c0c fg=#0c0c0c" "$CURRENT_DIR/script.sh"
        ;;
esac
