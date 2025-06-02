#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

default_key_binding="J"
default_display_mode="popup"
default_window_width="100%"
default_window_height="100%"
default_border_fg="#0c0c0c"
default_border_bg="#0c0c0c"

default_harpoon_key="H"
default_harpoon_add_key="h"

key_binding=$(tmux show-option -gqv @omnimux-key)
key_binding=${key_binding:-$default_key_binding}

display_mode=$(tmux show-option -gqv @omnimux-display-mode)
display_mode=${display_mode:-$default_display_mode}

window_width=$(tmux show-option -gqv @omnimux-window-width)
window_width=${window_width:-$default_window_width}

window_height=$(tmux show-option -gqv @omnimux-window-height)
window_height=${window_height:-$default_window_height}

border_fg=$(tmux show-option -gqv @omnimux-border-fg)
border_fg=${border_fg:-$default_border_fg}

border_bg=$(tmux show-option -gqv @omnimux-border-bg)
border_bg=${border_bg:-$default_border_bg}

harpoon_key=$(tmux show-option -gqv @omnimux-harpoon-key)
harpoon_key=${harpoon_key:-$default_harpoon_key}

harpoon_add_key=$(tmux show-option -gqv @omnimux-harpoon-add-key)
harpoon_add_key=${harpoon_add_key:-$default_harpoon_add_key}

case "$display_mode" in
    "popup")
        tmux bind-key "$key_binding" display-popup -E -w "$window_width" -h "$window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/omnimux_main.sh"
        ;;
    "window")
        tmux bind-key "$key_binding" new-window "$CURRENT_DIR/scripts/omnimux_main.sh"
        ;;
    *)
        tmux bind-key "$key_binding" display-popup -E -w "$window_width" -h "$window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/omnimux_main.sh"
        ;;
esac

case "$display_mode" in
    "popup")
        tmux bind-key "$harpoon_key" display-popup -E -w "$window_width" -h "$window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/harpoon_interface.sh"
        tmux bind-key "$harpoon_add_key" run-shell "$CURRENT_DIR/scripts/harpoon_add.sh"
        ;;
    "window")
        tmux bind-key "$harpoon_key" new-window "$CURRENT_DIR/scripts/harpoon_interface.sh"
        tmux bind-key "$harpoon_add_key" run-shell "$CURRENT_DIR/scripts/harpoon_add.sh"
        ;;
    *)
        tmux bind-key "$harpoon_key" display-popup -E -w "$window_width" -h "$window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/harpoon_interface.sh"
        tmux bind-key "$harpoon_add_key" run-shell "$CURRENT_DIR/scripts/harpoon_add.sh"
        ;;
esac
