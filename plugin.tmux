#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

default_omnimux_key="J"
default_omnimux_display_mode="popup"
default_omnimux_window_width="100%"
default_omnimux_window_height="100%"
default_omnimux_border_fg="#0c0c0c"
default_omnimux_border_bg="#0c0c0c"

omnimux_key=$(tmux show-option -gqv @omnimux-key)
omnimux_key=${omnimux_key:-$default_omnimux_key}

omnimux_display_mode=$(tmux show-option -gqv @omnimux-display-mode)
omnimux_display_mode=${omnimux_display_mode:-$default_omnimux_display_mode}

omnimux_window_width=$(tmux show-option -gqv @omnimux-window-width)
omnimux_window_width=${omnimux_window_width:-$default_omnimux_window_width}

omnimux_window_height=$(tmux show-option -gqv @omnimux-window-height)
omnimux_window_height=${omnimux_window_height:-$default_omnimux_window_height}

omnimux_border_fg=$(tmux show-option -gqv @omnimux-border-fg)
omnimux_border_fg=${omnimux_border_fg:-$default_omnimux_border_fg}

omnimux_border_bg=$(tmux show-option -gqv @omnimux-border-bg)
omnimux_border_bg=${omnimux_border_bg:-$default_omnimux_border_bg}

case "$omnimux_display_mode" in
    "popup")
        tmux bind-key "$omnimux_key" display-popup -E -w "$omnimux_window_width" -h "$omnimux_window_height" -S "bg=$omnimux_border_bg fg=$omnimux_border_bg" "$CURRENT_DIR/script.sh"
        ;;
    "window")
        tmux bind-key "$omnimux_key" new-window "$CURRENT_DIR/script.sh"
        ;;
    *)
        tmux bind-key "$omnimux_key" display-popup -E -w "$omnimux_window_width" -h "$omnimux_window_height" -S "bg=$omnimux_border_bg fg=$omnimux_border_bg" "$CURRENT_DIR/script.sh"
        ;;
esac

default_harpoon_key="h"
default_harpoon_add_key="a"
default_harpoon_display_mode="popup"
default_harpoon_window_width="100%"
default_harpoon_window_height="100%"
default_harpoon_border_fg="#0c0c0c"
default_harpoon_border_bg="#0c0c0c"

harpoon_key=$(tmux show-option -gqv @harpoon-key)
harpoon_key=${harpoon_key:-$default_harpoon_key}

harpoon_add_key=$(tmux show-option -gqv @harpoon-add-key)
harpoon_add_key=${harpoon_add_key:-$default_harpoon_add_key}

harpoon_display_mode=$(tmux show-option -gqv @harpoon-display-mode)
harpoon_display_mode=${harpoon_display_mode:-$default_harpoon_display_mode}

harpoon_window_width=$(tmux show-option -gqv @harpoon-window-width)
harpoon_window_width=${harpoon_window_width:-$default_harpoon_window_width}

harpoon_window_height=$(tmux show-option -gqv @harpoon-window-height)
harpoon_window_height=${harpoon_window_height:-$default_harpoon_window_height}

harpoon_border_fg=$(tmux show-option -gqv @harpoon-border-fg)
harpoon_border_fg=${harpoon_border_fg:-$default_harpoon_border_fg}

harpoon_border_bg=$(tmux show-option -gqv @harpoon-border-bg)
harpoon_border_bg=${harpoon_border_bg:-$default_harpoon_border_bg}

case "$harpoon_display_mode" in
    "popup")
        tmux bind-key "$harpoon_key" display-popup -E -w "$harpoon_window_width" -h "$harpoon_window_height" -S "bg=$harpoon_border_bg fg=$harpoon_border_fg" "$CURRENT_DIR/tmux-harpoon.sh"
        ;;
    "window")
        tmux bind-key "$harpoon_key" new-window "$CURRENT_DIR/tmux-harpoon.sh"
        ;;
    *)
        tmux bind-key "$harpoon_key" display-popup -E -w "$harpoon_window_width" -h "$harpoon_window_height" -S "bg=$harpoon_border_bg fg=$harpoon_border_fg" "$CURRENT_DIR/tmux-harpoon.sh"
        ;;
esac

tmux bind-key "$harpoon_add_key" run-shell "$CURRENT_DIR/add.sh"
