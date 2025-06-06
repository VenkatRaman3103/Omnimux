#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# defaults
default_key_binding="J"
default_display_mode="popup"
default_utility_mode="verbose"
default_window_width="100%"
default_window_height="100%"

default_editor_window_width="50%"
default_editor_window_height="50%"

default_utility_window_width="40%"
default_utility_window_height="50%"

default_border_fg="#0c0c0c"
default_border_bg="#0c0c0c"

default_bookmarks_key="H"
default_bookmarks_add_key="a"

default_edit_session_key="y"
default_edit_windows_key="Y"

default_utlity_session_key="j"
default_utlity_windows_key="k"
default_utlity_tmuxifier_key="h"

# mapping to keybindings
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

bookmarks_key=$(tmux show-option -gqv @omnimux-bookmarks-key)
bookmarks_key=${bookmarks_key:-$default_bookmarks_key}

bookmarks_add_key=$(tmux show-option -gqv @omnimux-bookmarks-add-key)
bookmarks_add_key=${bookmarks_add_key:-$default_bookmarks_add_key}

edit_session_key=$(tmux show-option -gqv @omnimux-edit-session-key)
edit_session_key=${edit_session_key:-$default_edit_session_key}

edit_windows_key=$(tmux show-option -gqv @omnimux-edit-windows-key)
edit_windows_key=${edit_windows_key:-$default_edit_windows_key}  

editor_window_width=$(tmux show-option -gqv @omnimux-editor-window-width)
editor_window_width=${editor_window_width:-$default_editor_window_width}

editor_window_height=$(tmux show-option -gqv @omnimux-editor-window-height)
editor_window_height=${editor_window_height:-$default_editor_window_height}

# utility
utlity_session_key=$(tmux show-option -gqv @omnimux-utility-session-key)
utlity_session_key=${utlity_session_key:-$default_utlity_session_key}  

utlity_window_key=$(tmux show-option -gqv @omnimux-utility-windows-key)
utlity_window_key=${utlity_window_key:-$default_utlity_windows_key}

utlity_tmuxfier_key=$(tmux show-option -gqv @omnimux-utility-tmuxifier-key)
utlity_tmuxfier_key=${utlity_tmuxfier_key:-$default_utlity_tmuxifier_key}

utility_mode=$(tmux show-option -gqv @omnimux-utility--mode)
utility_mode=${utility_mode:-$default_utility_mode}

utility_window_height=$(tmux show-option -gqv @omnimux-utility-window-height)
utility_window_height=${utility_window_height:-$default_utility_window_height}

utility_window_width=$(tmux show-option -gqv @omnimux-utility-window-width)
utility_window_width=${utility_window_width:-$default_utility_window_width}

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
        tmux bind-key "$bookmarks_key" display-popup -E -w "$window_width" -h "$window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/bookmarks_interface.sh"
        tmux bind-key "$bookmarks_add_key" run-shell "$CURRENT_DIR/scripts/bookmarks_add.sh"
        ;;
    "window")
        tmux bind-key "$bookmarks_key" new-window "$CURRENT_DIR/scripts/bookmarks_interface.sh"
        tmux bind-key "$bookmarks_add_key" run-shell "$CURRENT_DIR/scripts/bookmarks_add.sh"
        ;;
    *)
        tmux bind-key "$bookmarks_key" display-popup -E -w "$window_width" -h "$window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/bookmarks_interface.sh"
        tmux bind-key "$bookmarks_add_key" run-shell "$CURRENT_DIR/scripts/bookmarks_add.sh"
        ;;
esac

case "$display_mode" in
    "popup")
        tmux bind-key "$edit_session_key" display-popup -E -w "$editor_window_width" -h "$editor_window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/editor_sessions.sh"
        ;;
    "window")
        tmux bind-key "$edit_session_key" new-window "$CURRENT_DIR/scripts/editor_sessions.sh"
        ;;
    *)
        tmux bind-key "$edit_session_key" display-popup -E -w "$editor_window_width" -h "$editor_window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/editor_sessions.sh"
        ;;
esac

case "$display_mode" in
    "popup")
        tmux bind-key "$edit_windows_key" display-popup -E -w "$editor_window_width" -h "$editor_window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/editor_windows.sh"
        ;;
    "window")
        tmux bind-key "$edit_windows_key" new-window "$CURRENT_DIR/scripts/editor_windows.sh"
        ;;
    *)
        tmux bind-key "$edit_windows_key" display-popup -E -w "$editor_window_width" -h "$editor_window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/editor_windows.sh"
        ;;
esac

# utility
case "$utility_mode" in
    "verbose")
        tmux bind-key "$utlity_session_key" display-popup -E -w "$utility_window_width" -h "$utility_window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/utility/verbose/sessions.sh"
        tmux bind-key "$utlity_window_key" display-popup -E -w "$utility_window_width" -h "$utility_window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/utility/verbose/windows.sh"
        tmux bind-key "$utlity_tmuxfier_key" display-popup -E -w "$utility_window_width" -h "$utility_window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/utility/verbose/tmuxifier.sh"
        ;;
    "minimal")
        tmux bind-key "$utlity_session_key" display-popup -E -w "$utility_window_width" -h "$utility_window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/utility/minimal/sessions.sh"
        tmux bind-key "$utlity_window_key" display-popup -E -w "$utility_window_width" -h "$utility_window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/utility/minimal/windows.sh"
        tmux bind-key "$utlity_tmuxfier_key" display-popup -E -w "$utility_window_width" -h "$utility_window_height" -S "bg=$border_bg fg=$border_fg" "$CURRENT_DIR/scripts/utility/minimal/tmuxifier.sh"
        ;;
esac
