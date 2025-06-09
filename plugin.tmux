#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

# Float
default_float_key="f"
default_float_menu_key="F"
default_float_width="80%"
default_float_height="80%"
default_float_border_color="#666666"
default_float_text_color="white"
default_float_session_name="scratch"

# Float resize
default_float_wider_key="M-Right"
default_float_narrower_key="M-Left"
default_float_taller_key="M-Up"
default_float_shorter_key="M-Down"
default_float_reset_key="M-r"
default_float_embed_key="M-e"

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

# Utility
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

# Float
float_key=$(tmux show-option -gqv @omnimux-float-key)
float_key=${float_key:-$default_float_key}

float_menu_key=$(tmux show-option -gqv @omnimux-float-menu-key)
float_menu_key=${float_menu_key:-$default_float_menu_key}

float_width=$(tmux show-option -gqv @omnimux-float-width)
float_width=${float_width:-$default_float_width}

float_height=$(tmux show-option -gqv @omnimux-float-height)
float_height=${float_height:-$default_float_height}

float_border_color=$(tmux show-option -gqv @omnimux-float-border-color)
float_border_color=${float_border_color:-$default_float_border_color}

float_text_color=$(tmux show-option -gqv @omnimux-float-text-color)
float_text_color=${float_text_color:-$default_float_text_color}

float_session_name=$(tmux show-option -gqv @omnimux-float-session-name)
float_session_name=${float_session_name:-$default_float_session_name}

# Float resize
float_wider_key=$(tmux show-option -gqv @omnimux-float-wider-key)
float_wider_key=${float_wider_key:-$default_float_wider_key}

float_narrower_key=$(tmux show-option -gqv @omnimux-float-narrower-key)
float_narrower_key=${float_narrower_key:-$default_float_narrower_key}

float_taller_key=$(tmux show-option -gqv @omnimux-float-taller-key)
float_taller_key=${float_taller_key:-$default_float_taller_key}

float_shorter_key=$(tmux show-option -gqv @omnimux-float-shorter-key)
float_shorter_key=${float_shorter_key:-$default_float_shorter_key}

float_reset_key=$(tmux show-option -gqv @omnimux-float-reset-key)
float_reset_key=${float_reset_key:-$default_float_reset_key}

float_embed_key=$(tmux show-option -gqv @omnimux-float-embed-key)
float_embed_key=${float_embed_key:-$default_float_embed_key}

tmux setenv -g OMNIMUX_FLOAT_WIDTH "$float_width"
tmux setenv -g OMNIMUX_FLOAT_HEIGHT "$float_height"
tmux setenv -g OMNIMUX_FLOAT_BORDER_COLOR "$float_border_color"
tmux setenv -g OMNIMUX_FLOAT_TEXT_COLOR "$float_text_color"
tmux setenv -g OMNIMUX_FLOAT_SESSION_NAME "$float_session_name"

# Omnimux
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

# Bookmarks
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

# Editor
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

# Utility
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

# Float 
tmux bind-key "$float_key" run-shell "$CURRENT_DIR/scripts/float.sh"
tmux bind-key "$float_menu_key" run-shell "$CURRENT_DIR/scripts/float.sh menu"

tmux bind-key "$float_wider_key" run-shell "$CURRENT_DIR/scripts/float.sh wider"
tmux bind-key "$float_narrower_key" run-shell "$CURRENT_DIR/scripts/float.sh narrower"
tmux bind-key "$float_taller_key" run-shell "$CURRENT_DIR/scripts/float.sh taller"
tmux bind-key "$float_shorter_key" run-shell "$CURRENT_DIR/scripts/float.sh shorter"
tmux bind-key "$float_reset_key" run-shell "$CURRENT_DIR/scripts/float.sh reset-size"
tmux bind-key "$float_embed_key" run-shell "$CURRENT_DIR/scripts/float.sh embed"
