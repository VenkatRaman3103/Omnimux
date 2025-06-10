#!/usr/bin/env bash

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value=$(tmux show-option -gqv "$option")
    echo "${option_value:-$default_value}"
}

FLOAT_WIDTH=$(get_tmux_option "@omnimux-float-width" "80%")
FLOAT_HEIGHT=$(get_tmux_option "@omnimux-float-height" "80%")
FLOAT_BORDER_COLOR=$(get_tmux_option "@omnimux-float-border-color" "#666666")
FLOAT_TEXT_COLOR=$(get_tmux_option "@omnimux-float-text-color" "white")
FLOAT_SESSION_NAME=$(get_tmux_option "@omnimux-float-session-name" "scratch")
FLOAT_BORDER_STYLE=$(get_tmux_option "@omnimux-float-border-style" "rounded")
FLOAT_SIZE_STEP=$(get_tmux_option "@omnimux-float-size-step" "10")
FLOAT_MIN_SIZE=$(get_tmux_option "@omnimux-float-min-size" "10")
FLOAT_MAX_SIZE=$(get_tmux_option "@omnimux-float-max-size" "100")
FLOAT_SHOW_STATUS=$(get_tmux_option "@omnimux-float-show-status" "off")

envvar_value() {
    local value
    value="$(tmux showenv -g "$1" 2>/dev/null | cut -d '=' -f 2-)"
    if [ -z "$value" ]; then
        case "$1" in
            OMNIMUX_FLOAT_WIDTH) echo "$FLOAT_WIDTH" ;;
            OMNIMUX_FLOAT_HEIGHT) echo "$FLOAT_HEIGHT" ;;
            OMNIMUX_FLOAT_BORDER_COLOR) echo "$FLOAT_BORDER_COLOR" ;;
            OMNIMUX_FLOAT_TEXT_COLOR) echo "$FLOAT_TEXT_COLOR" ;;
            OMNIMUX_FLOAT_SESSION_NAME) echo "$FLOAT_SESSION_NAME" ;;
            ORIGIN_SESSION) echo "" ;;
            *) echo "" ;;
        esac
    else
        echo "$value"
    fi
}

init_size_settings() {
    local current_width current_height
    current_width=$(tmux showenv -g OMNIMUX_FLOAT_WIDTH 2>/dev/null | cut -d '=' -f 2-)
    current_height=$(tmux showenv -g OMNIMUX_FLOAT_HEIGHT 2>/dev/null | cut -d '=' -f 2-)
    
    if [ -z "$current_width" ]; then
        tmux setenv -g OMNIMUX_FLOAT_WIDTH "$FLOAT_WIDTH"
    fi
    if [ -z "$current_height" ]; then
        tmux setenv -g OMNIMUX_FLOAT_HEIGHT "$FLOAT_HEIGHT"
    fi
}

get_session_specific_scratch_name() {
    local origin_session="$1"
    echo "${origin_session}_scratch"
}

is_tmux_version_supported() {
    local version
    IFS='.' read -r -a version < <(tmux -V | cut -d ' ' -f 2)
    if [ "${version[0]}" -gt 3 ]; then
        return 0
    fi
    if [ "${version[0]}" -eq 3 ] && [ "${version[1]//[!0-9]}" -ge 3 ]; then
        return 0
    fi
    return 1
}

is_in_popup() {
    local popup_status
    popup_status=$(tmux display-message -p '#{?popup_active,1,0}' 2>/dev/null || echo "0")
    [ "$popup_status" = "1" ]
}

is_scratch_session() {
    local current_session="$1"
    [[ "$current_session" =~ _scratch$ ]]
}

get_origin_from_scratch() {
    local scratch_session="$1"
    echo "${scratch_session%_scratch}"
}

percent_to_int() {
    local value="$1"
    echo "${value%\%}"
}

int_to_percent() {
    local value="$1"
    echo "${value}%"
}

adjust_size() {
    local dimension="$1"  
    local adjustment="$2"
    local current_value current_int new_int
    
    if [ "$adjustment" = "increase" ]; then
        adjustment="$FLOAT_SIZE_STEP"
    elif [ "$adjustment" = "decrease" ]; then
        adjustment="-$FLOAT_SIZE_STEP"
    fi
    
    if [ "$dimension" = "width" ]; then
        current_value=$(envvar_value OMNIMUX_FLOAT_WIDTH)
    else
        current_value=$(envvar_value OMNIMUX_FLOAT_HEIGHT)
    fi
    
    current_int=$(percent_to_int "$current_value")
    new_int=$((current_int + adjustment))
    
    if [ "$new_int" -lt "$FLOAT_MIN_SIZE" ]; then
        new_int="$FLOAT_MIN_SIZE"
    elif [ "$new_int" -gt "$FLOAT_MAX_SIZE" ]; then
        new_int="$FLOAT_MAX_SIZE"
    fi
    
    local new_value
    new_value=$(int_to_percent "$new_int")
    
    if [ "$dimension" = "width" ]; then
        tmux setenv -g OMNIMUX_FLOAT_WIDTH "$new_value"
    else
        tmux setenv -g OMNIMUX_FLOAT_HEIGHT "$new_value"
    fi
    
    echo "$new_value"
}

resize_popup() {
    local dimension="$1"
    local adjustment="$2"
    local new_size
    
    new_size=$(adjust_size "$dimension" "$adjustment")
    
    if is_in_popup; then
        local current_session scratch_session_name
        current_session=$(tmux display-message -p '#{session_name}')
        
        if is_scratch_session "$current_session"; then
            tmux detach-client
            sleep 0.1
            local origin_session
            origin_session=$(get_origin_from_scratch "$current_session")
            if tmux has-session -t "$origin_session" 2>/dev/null; then
                tmux switch-client -t "$origin_session"
                show_popup
            fi
        fi
        tmux display-message -d 1000 "Popup ${dimension} adjusted to ${new_size}"
    else
        tmux display-message -d 1000 "Popup ${dimension} set to ${new_size} (will apply to next popup)"
    fi
}

show_popup() {
    local omnimux_float_width omnimux_float_height current_session scratch_session_name
    
    init_size_settings
    
    omnimux_float_width=$(tmux showenv -g OMNIMUX_FLOAT_WIDTH 2>/dev/null | cut -d '=' -f 2-)
    omnimux_float_height=$(tmux showenv -g OMNIMUX_FLOAT_HEIGHT 2>/dev/null | cut -d '=' -f 2-)
    
    [ -z "$omnimux_float_width" ] && omnimux_float_width="$FLOAT_WIDTH"
    [ -z "$omnimux_float_height" ] && omnimux_float_height="$FLOAT_HEIGHT"
    
    current_session=$(tmux display-message -p '#{session_name}')
    
    scratch_session_name=$(get_session_specific_scratch_name "$current_session")
    
    if ! tmux has-session -t "$scratch_session_name" 2>/dev/null; then
        tmux new-session -d -c "$(tmux display-message -p '#{pane_current_path}')" -s "$scratch_session_name"
        tmux setenv -t "$scratch_session_name" ORIGIN_SESSION "$current_session"
        tmux setenv -t "$scratch_session_name" SCRATCH_WIDTH "$omnimux_float_width"
        tmux setenv -t "$scratch_session_name" SCRATCH_HEIGHT "$omnimux_float_height"
    fi
    
    tmux set-option -t "$scratch_session_name" detach-on-destroy on
    tmux set-option -t "$scratch_session_name" status "$FLOAT_SHOW_STATUS"
    
    tmux popup \
        -S fg="$(envvar_value OMNIMUX_FLOAT_BORDER_COLOR)" \
        -s fg="$(envvar_value OMNIMUX_FLOAT_TEXT_COLOR)" \
        -T " $(envvar_value OMNIMUX_FLOAT_SESSION_NAME): $current_session " \
        -w "$omnimux_float_width" \
        -h "$omnimux_float_height" \
        -b "$FLOAT_BORDER_STYLE" \
        -E \
        "tmux attach-session -t \"$scratch_session_name\""
}

toggle() {
    if ! is_tmux_version_supported; then
        tmux display-message -d 2000 "Omnimux_float requires tmux version 3.3 or newer"
        return 1
    fi
    
    init_size_settings
    
    local current_session scratch_session_name origin_session
    current_session=$(tmux display-message -p '#{session_name}')
    
    if is_scratch_session "$current_session"; then
        tmux detach-client
    elif is_in_popup; then
        tmux detach-client
    else
        scratch_session_name=$(get_session_specific_scratch_name "$current_session")
        
        tmux setenv -g OMNIMUX_FLOAT_WIDTH "$(tmux showenv -g OMNIMUX_FLOAT_WIDTH 2>/dev/null | cut -d '=' -f 2- || echo "$FLOAT_WIDTH")"
        tmux setenv -g OMNIMUX_FLOAT_HEIGHT "$(tmux showenv -g OMNIMUX_FLOAT_HEIGHT 2>/dev/null | cut -d '=' -f 2- || echo "$FLOAT_HEIGHT")"
        tmux setenv -g OMNIMUX_FLOAT_BORDER_COLOR "$(envvar_value OMNIMUX_FLOAT_BORDER_COLOR)"
        tmux setenv -g OMNIMUX_FLOAT_TEXT_COLOR "$(envvar_value OMNIMUX_FLOAT_TEXT_COLOR)"
        
        show_popup
    fi
}

show_menu() {
    local current_session scratch_session_name script_path current_width current_height
    
    current_session=$(tmux display-message -p '#{session_name}')
    script_path="$(realpath "$0" 2>/dev/null || readlink -f "$0" 2>/dev/null || echo "$0")"
    
    current_width=$(tmux showenv -g OMNIMUX_FLOAT_WIDTH 2>/dev/null | cut -d '=' -f 2- || echo "$FLOAT_WIDTH")
    current_height=$(tmux showenv -g OMNIMUX_FLOAT_HEIGHT 2>/dev/null | cut -d '=' -f 2- || echo "$FLOAT_HEIGHT")
    
    if is_scratch_session "$current_session" || is_in_popup; then
        tmux menu \
            "close popup" c "detach-client" \
            "embed in session" e "run \"$script_path embed\"" \
            "" \
            "Current Size: ${current_width} x ${current_height}" "" "" \
            "" \
            "wider (+${FLOAT_SIZE_STEP}%)" "M-Right" "run \"$script_path wider\"" \
            "narrower (-${FLOAT_SIZE_STEP}%)" "M-Left" "run \"$script_path narrower\"" \
            "taller (+${FLOAT_SIZE_STEP}%)" "M-Up" "run \"$script_path taller\"" \
            "shorter (-${FLOAT_SIZE_STEP}%)" "M-Down" "run \"$script_path shorter\"" \
            "" \
            "reset size" r "run \"$script_path reset-size\""
    else
        tmux menu \
            "show popup" g "run \"$script_path toggle\"" \
            "move to float" f "run \"$script_path to-float\"" \
            "" \
            "Current Size: ${current_width} x ${current_height}" "" "" \
            "" \
            "wider (+${FLOAT_SIZE_STEP}%)" "M-Right" "run \"$script_path wider\"" \
            "narrower (-${FLOAT_SIZE_STEP}%)" "M-Left" "run \"$script_path narrower\"" \
            "taller (+${FLOAT_SIZE_STEP}%)" "M-Up" "run \"$script_path taller\"" \
            "shorter (-${FLOAT_SIZE_STEP}%)" "M-Down" "run \"$script_path shorter\"" \
            "" \
            "reset size" r "run \"$script_path reset-size\"" \
            "" \
            "menu" m "run \"$script_path menu\""
    fi
}

reset_size() {
    tmux setenv -g OMNIMUX_FLOAT_WIDTH "$FLOAT_WIDTH"
    tmux setenv -g OMNIMUX_FLOAT_HEIGHT "$FLOAT_HEIGHT"
    
    if is_in_popup; then
        local current_session
        current_session=$(tmux display-message -p '#{session_name}')
        
        if is_scratch_session "$current_session"; then
            tmux detach-client
            sleep 0.1
            local origin_session
            origin_session=$(get_origin_from_scratch "$current_session")
            if tmux has-session -t "$origin_session" 2>/dev/null; then
                tmux switch-client -t "$origin_session"
                show_popup
            fi
        fi
        tmux display-message -d 1000 "Popup size reset to ${FLOAT_WIDTH}x${FLOAT_HEIGHT}"
    else
        tmux display-message -d 1000 "Popup size reset to ${FLOAT_WIDTH}x${FLOAT_HEIGHT} (will apply to next popup)"
    fi
}

embed_window() {
    local current_session origin_session number_of_windows
    
    current_session=$(tmux display-message -p '#{session_name}')
    
    echo "Debug: Current session: $current_session"
    echo "Debug: In popup: $(is_in_popup && echo "yes" || echo "no")"
    echo "Debug: Is scratch session: $(is_scratch_session "$current_session" && echo "yes" || echo "no")"
    
    if is_scratch_session "$current_session"; then
        origin_session=$(get_origin_from_scratch "$current_session")
        echo "Debug: Origin from session name: $origin_session"
    else
        origin_session=$(tmux showenv -t "$current_session" ORIGIN_SESSION 2>/dev/null | cut -d '=' -f 2-)
        if [ -z "$origin_session" ]; then
            origin_session=$(tmux list-sessions -F '#{session_name} #{session_last_attached}' 2>/dev/null | \
                            grep -v "_scratch " | \
                            sort -k2 -nr | \
                            head -1 | \
                            cut -d' ' -f1)
        fi
        echo "Debug: Origin from environment/fallback: $origin_session"
    fi
    
    if [ -z "$origin_session" ]; then
        origin_session="main"
        if ! tmux has-session -t "$origin_session" 2>/dev/null; then
            tmux new-session -d -s "$origin_session"
            echo "Created new session: $origin_session"
        fi
        echo "Using fallback origin session: $origin_session"
    fi
    
    if ! tmux has-session -t "$origin_session" 2>/dev/null; then
        echo "Origin session '$origin_session' doesn't exist, creating it..."
        tmux new-session -d -s "$origin_session"
    fi
    
    if is_scratch_session "$current_session"; then
        number_of_windows=$(tmux list-windows -t "$current_session" 2>/dev/null | wc -l)
        
        if [ "$number_of_windows" -le 1 ]; then
            echo "Creating backup window in scratch session..."
            if ! tmux neww -d -t "$current_session" 2>/dev/null; then
                echo "Warning: Could not create backup window"
            fi
        fi
    fi
    
    local current_window
    current_window=$(tmux display-message -p '#{window_index}')
    
    echo "Moving window $current_window to session $origin_session..."
    
    if tmux movew -t "$origin_session" 2>/dev/null; then
        echo "Successfully moved window to $origin_session"
        tmux detach-client
        return 0
    else
        echo "Error: Failed to move window to $origin_session"
        if tmux break-pane -t "$origin_session" 2>/dev/null; then
            echo "Successfully moved pane to $origin_session as new window"
            tmux detach-client
            return 0
        else
            tmux display-message -d 3000 "Error: Could not move window or pane to target session"
            return 1
        fi
    fi
}

move_to_float() {
    local current_session scratch_session_name current_window number_of_windows
    
    current_session=$(tmux display-message -p '#{session_name}')
    
    if is_scratch_session "$current_session" || is_in_popup; then
        tmux display-message -d 2000 "Already in floating session"
        return 1
    fi
    
    scratch_session_name=$(get_session_specific_scratch_name "$current_session")
    
    if ! tmux has-session -t "$scratch_session_name" 2>/dev/null; then
        tmux new-session -d -c "$(tmux display-message -p '#{pane_current_path}')" -s "$scratch_session_name" >/dev/null 2>&1
        tmux setenv -t "$scratch_session_name" ORIGIN_SESSION "$current_session"
        
        local omnimux_float_width omnimux_float_height
        omnimux_float_width=$(tmux showenv -g OMNIMUX_FLOAT_WIDTH 2>/dev/null | cut -d '=' -f 2- || echo "$FLOAT_WIDTH")
        omnimux_float_height=$(tmux showenv -g OMNIMUX_FLOAT_HEIGHT 2>/dev/null | cut -d '=' -f 2- || echo "$FLOAT_HEIGHT")
        
        tmux setenv -t "$scratch_session_name" SCRATCH_WIDTH "$omnimux_float_width"
        tmux setenv -t "$scratch_session_name" SCRATCH_HEIGHT "$omnimux_float_height"
    fi
    
    number_of_windows=$(tmux list-windows -t "$current_session" 2>/dev/null | wc -l)
    
    if [ "$number_of_windows" -le 1 ]; then
        tmux neww -d -t "$current_session" >/dev/null 2>&1
    fi
    
    if tmux movew -t "$scratch_session_name" >/dev/null 2>&1; then
        tmux set-option -t "$scratch_session_name" detach-on-destroy on
        tmux set-option -t "$scratch_session_name" status "$FLOAT_SHOW_STATUS"
        
        show_popup
        return 0
    else
        if tmux break-pane -t "$scratch_session_name" >/dev/null 2>&1; then
            tmux set-option -t "$scratch_session_name" detach-on-destroy on
            tmux set-option -t "$scratch_session_name" status "$FLOAT_SHOW_STATUS"
            
            show_popup
            return 0
        else
            tmux display-message -d 3000 "Error: Could not move window or pane to floating session"
            return 1
        fi
    fi
}

case "${1:-toggle}" in
    toggle)
        toggle
        ;;
    menu)
        show_menu
        ;;
    embed)
        embed_window
        ;;
    to-float)
        move_to_float
        ;;
    wider)
        resize_popup "width" "$FLOAT_SIZE_STEP"
        ;;
    narrower)
        resize_popup "width" "-$FLOAT_SIZE_STEP"
        ;;
    taller)
        resize_popup "height" "$FLOAT_SIZE_STEP"
        ;;
    shorter)
        resize_popup "height" "-$FLOAT_SIZE_STEP"
        ;;
    reset-size)
        reset_size
        ;;
    *)
        echo "Usage: $0 {toggle|menu|embed|to-float|wider|narrower|taller|shorter|reset-size}"
        echo ""
        echo "Commands:"
        echo "  toggle      - Toggle session-specific scratch popup (default)"
        echo "  menu        - Show context menu"
        echo "  embed       - Embed current window in original session"
        echo "  to-float    - Move current window to floating session"
        echo "  wider       - Increase popup width by ${FLOAT_SIZE_STEP}%"
        echo "  narrower    - Decrease popup width by ${FLOAT_SIZE_STEP}%"
        echo "  taller      - Increase popup height by ${FLOAT_SIZE_STEP}%"
        echo "  shorter     - Decrease popup height by ${FLOAT_SIZE_STEP}%"
        echo "  reset-size  - Reset popup size to default (${FLOAT_WIDTH}x${FLOAT_HEIGHT})"
        echo ""
        echo "Size adjustments are clamped between ${FLOAT_MIN_SIZE}% and ${FLOAT_MAX_SIZE}%"
        echo ""
        echo "Configurable options:"
        echo "  @omnimux-float-width             - Default width (current: $FLOAT_WIDTH)"
        echo "  @omnimux-float-height            - Default height (current: $FLOAT_HEIGHT)"
        echo "  @omnimux-float-border-color      - Border color (current: $FLOAT_BORDER_COLOR)"
        echo "  @omnimux-float-text-color        - Text color (current: $FLOAT_TEXT_COLOR)"
        echo "  @omnimux-float-session-name      - Session name prefix (current: $FLOAT_SESSION_NAME)"
        echo "  @omnimux-float-border-style      - Border style (current: $FLOAT_BORDER_STYLE)"
        echo "  @omnimux-float-size-step         - Size adjustment step (current: $FLOAT_SIZE_STEP)"
        echo "  @omnimux-float-min-size          - Minimum size percentage (current: $FLOAT_MIN_SIZE)"
        echo "  @omnimux-float-max-size          - Maximum size percentage (current: $FLOAT_MAX_SIZE)"
        exit 1
        ;;
esac
