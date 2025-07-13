#!/bin/bash

CACHE_DIR="/tmp/omnimux_$$"
mkdir -p "$CACHE_DIR"

cleanup() {
    rm -rf "$CACHE_DIR" 2>/dev/null
}
trap cleanup EXIT

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value=$(tmux show-option -gqv "$option")
    echo "${option_value:-$default_value}"
}

hex_to_ansi() {
    local hex="$1"
    hex="${hex#\#}"
    
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    
    printf "\033[38;2;%d;%d;%dm" "$r" "$g" "$b"
}

load_options() {
    ACTIVE_BG=$(get_tmux_option "@omnimux-active-bg" "#444444")
    ACTIVE_FG=$(get_tmux_option "@omnimux-active-fg" "#ffffff")
    INACTIVE_BG=$(get_tmux_option "@omnimux-inactive-bg" "#222222")
    INACTIVE_FG=$(get_tmux_option "@omnimux-inactive-fg" "#777777")

    TMUXIFIER_MARK_HEX=$(get_tmux_option "@omnimux-tmuxifier-mark-color" "#333333")
    TMUXIFIER_COLOR=$(hex_to_ansi "$TMUXIFIER_MARK_HEX")

    ZOXIDE_MARK_HEX=$(get_tmux_option "@omnimux-zoxide-mark-color" "#333333")
    ZOXIDE_COLOR=$(hex_to_ansi "$ZOXIDE_MARK_HEX")

    FIND_MARK_HEX=$(get_tmux_option "@omnimux-find-mark-color" "#333333")
    FIND_COLOR=$(hex_to_ansi "$FIND_MARK_HEX")

    TMUX_HEX=$(get_tmux_option "@omnimux-tmux-color" "#333333")
    TMUX_COLOR=$(hex_to_ansi "$TMUX_HEX")
    TMUX_MARK_HEX=$(get_tmux_option "@omnimux-tmux-mark-color" "#333333")
    TMUX_MARK_COLOR=$(hex_to_ansi "$TMUX_MARK_HEX")

    ACTIVE_SESSION_HEX=$(get_tmux_option "@omnimux-active-session-color" "#333333")
    ACTIVE_SESSION_COLOR=$(hex_to_ansi "$ACTIVE_SESSION_HEX")

    TMUX_SESSION_HEX=$(get_tmux_option "@omnimux-tmux-session-color" "#ffffff")
    TMUX_SESSION_COLOR=$(hex_to_ansi "$TMUX_SESSION_HEX")

    TMUXIFIER_SESSION_HEX=$(get_tmux_option "@omnimux-tmuxifier-session-color" "#87ceeb")
    TMUXIFIER_SESSION_COLOR=$(hex_to_ansi "$TMUXIFIER_SESSION_HEX")

    ZOXIDE_PATH_HEX=$(get_tmux_option "@omnimux-zoxide-path-color" "#90ee90")
    ZOXIDE_PATH_COLOR=$(hex_to_ansi "$ZOXIDE_PATH_HEX")

    FIND_PATH_HEX=$(get_tmux_option "@omnimux-find-path-color" "#dda0dd")
    FIND_PATH_COLOR=$(hex_to_ansi "$FIND_PATH_HEX")

    NORMAL="\033[0m"

    FZF_HEIGHT=$(get_tmux_option "@omnimux-fzf-height" "100%")
    FZF_BORDER=$(get_tmux_option "@omnimux-fzf-border" "none")
    FZF_LAYOUT=$(get_tmux_option "@omnimux-fzf-layout" "no-reverse")
    FZF_WINDOW_LAYOUT=$(get_tmux_option "@omnimux-fzf-window-layout" "reverse")
    FZF_PREVIEW_POSITION=$(get_tmux_option "@omnimux-fzf-preview-position" "bottom:60%")
    FZF_PREVIEW_WINDOW_POSITION=$(get_tmux_option "@omnimux-fzf-preview-window-position" "right:75%")
    FZF_PROMPT=$(get_tmux_option "@omnimux-fzf-prompt" "> ")
    FZF_WINDOW_PROMPT=$(get_tmux_option "@omnimux-fzf-window-prompt" "> ")
    FZF_POINTER=$(get_tmux_option "@omnimux-fzf-pointer" "▶")
    FZF_WINDOW_POINTER=$(get_tmux_option "@omnimux-fzf-window-pointer" "▶")

    PREVIEW_ENABLED=$(get_tmux_option "@omnimux-preview-enabled" "false")

    LS_COMMAND=$(get_tmux_option "@omnimux-ls-command" "ls -la")

    MAX_ZOXIDE_PATHS=$(get_tmux_option "@omnimux-max-zoxide-paths" "20")
    MAX_FIND_PATHS=$(get_tmux_option "@omnimux-max-find-paths" "500")
    FIND_BASE_DIR=$(get_tmux_option "@omnimux-find-base-dir" "$HOME")
    FIND_MAX_DEPTH=$(get_tmux_option "@omnimux-find-max-depth" "5")
    FIND_MIN_DEPTH=$(get_tmux_option "@omnimux-find-min-depth" "1")
    SHOW_PROCESS_COUNT=$(get_tmux_option "@omnimux-show-process-count" "3")
    SHOW_PREVIEW_LINES=$(get_tmux_option "@omnimux-show-preview-lines" "15")
    SHOW_LS_LINES=$(get_tmux_option "@omnimux-show-ls-lines" "20")
    SHOW_GIT_STATUS_LINES=$(get_tmux_option "@omnimux-show-git-status-lines" "10")

    DEFAULT_EDITOR=$(get_tmux_option "@omnimux-editor" "${EDITOR:-vim}")
}

find_tmuxifier() {
    local cache_file="$CACHE_DIR/tmuxifier_dir"
    
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
        return 0
    fi

    TMUXIFIER_PATHS=(
        "$HOME/.tmuxifier"
        "$HOME/.local/share/tmuxifier"
        "/usr/local/share/tmuxifier"
    )

    for path in "${TMUXIFIER_PATHS[@]}"; do
        if [ -d "$path" ]; then
            echo "$path" > "$cache_file"
            echo "$path"
            return 0
        fi
    done

    return 1
}

get_tmux_sessions() {
    local current_session=$(tmux display-message -p '#S' 2>/dev/null)
    local sessions=""
    local current_session_line=""
    local other_sessions=""
    
    local session_data=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | sort)
    
    while IFS= read -r session; do
        if [ -n "$session" ]; then 
            if [ "$session" = "$current_session" ]; then
                current_session_line=$(printf "%b%s%b %b(tmux)%b %b(active)%b" "${TMUX_SESSION_COLOR}" "$session" "${NORMAL}" "${TMUX_MARK_COLOR}" "${NORMAL}" "${ACTIVE_SESSION_COLOR}" "${NORMAL}")
            else
                other_sessions="${other_sessions}$(printf "%b%s%b %b(tmux)%b" "${TMUX_SESSION_COLOR}" "$session" "${NORMAL}" "${TMUX_MARK_COLOR}" "${NORMAL}")
"
            fi
        fi
    done <<< "$session_data"
    
    if [ -n "$current_session_line" ]; then
        sessions="$current_session_line"
        if [ -n "$other_sessions" ]; then
            sessions="${sessions}
${other_sessions}"
        fi
    else
        sessions="$other_sessions"
    fi
    
    echo "$sessions" | sed '/^$/d'
}

get_tmuxifier_sessions() {
    local cache_file="$CACHE_DIR/tmuxifier_sessions"
    
    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt 5 ]; then
        cat "$cache_file"
        return 0
    fi

    local tmuxifier_dir=$(find_tmuxifier)
    local sessions=""

    if [ -n "$tmuxifier_dir" ]; then
        local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"

        if [ -d "$layouts_dir" ]; then
            # Use a more efficient find command
            sessions=$(find "$layouts_dir" -maxdepth 1 -name "*.session.sh" -printf "%f\n" 2>/dev/null |
                sed 's/\.session\.sh$//' |
                sort |
                while read -r session; do
                    if [ -n "$session" ]; then
                        printf "%b%s%b %b(tmuxifier)%b\n" "${TMUXIFIER_SESSION_COLOR}" "$session" "${NORMAL}" "${TMUXIFIER_COLOR}" "${NORMAL}"
                    fi
                done)
        fi
    fi
    
    echo "$sessions" > "$cache_file"
    echo "$sessions"
}

get_zoxide_paths() {
    local cache_file="$CACHE_DIR/zoxide_paths"
    
    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt 10 ]; then
        cat "$cache_file"
        return 0
    fi

    if command -v zoxide &> /dev/null; then
        local paths=$(zoxide query -l 2>/dev/null | head -"$MAX_ZOXIDE_PATHS" |
            while read -r path; do
                if [ -n "$path" ]; then
                    printf "%b%s%b %b(zoxide)%b\n" "${ZOXIDE_PATH_COLOR}" "$path" "${NORMAL}" "${ZOXIDE_COLOR}" "${NORMAL}"
                fi
            done |
            sort)
        
        echo "$paths" > "$cache_file"
        echo "$paths"
    fi
}

get_find_paths() {
    local cache_file="$CACHE_DIR/find_paths"
    
    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt 30 ]; then
        cat "$cache_file"
        return 0
    fi

    if [ -d "$FIND_BASE_DIR" ]; then
        local paths=$(find "$FIND_BASE_DIR" -mindepth "$FIND_MIN_DEPTH" -maxdepth "$FIND_MAX_DEPTH" -type d \
            \( -name ".git" -o -name ".svn" -o -name ".hg" -o -name "node_modules" -o -name "__pycache__" -o -name ".cache" -o -name ".npm" \) -prune -o \
            -type d -readable -print 2>/dev/null |
            head -"$MAX_FIND_PATHS" |
            while read -r path; do
                if [ -n "$path" ]; then
                    printf "%b%s%b %b(find)%b\n" "${FIND_PATH_COLOR}" "$path" "${NORMAL}" "${FIND_COLOR}" "${NORMAL}"
                fi
            done |
            sort)
        
        echo "$paths" > "$cache_file"
        echo "$paths"
    fi
}

filter_tmuxifier_sessions() {
    local cache_file="$CACHE_DIR/active_sessions"
    
    if [ ! -f "$cache_file" ] || [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -gt 2 ]; then
        tmux list-sessions -F "#S" 2>/dev/null > "$cache_file"
    fi
    
    local active_sessions=$(cat "$cache_file")
    local tmuxifier_sessions=$(get_tmuxifier_sessions)
    local filtered_sessions=""

    while IFS= read -r session_line; do
        if [ -n "$session_line" ]; then
            local session_name=$(echo "$session_line" | awk '{print $1}')
            if ! echo "$active_sessions" | grep -qF "$session_name"; then
                filtered_sessions="${filtered_sessions}${session_line}
"
            fi
        fi
    done <<< "$tmuxifier_sessions"

    echo "$filtered_sessions" | sed '/^$/d'
}

get_all_sessions() {
    local temp_dir="$CACHE_DIR/parallel"
    mkdir -p "$temp_dir"
    
    get_tmux_sessions > "$temp_dir/tmux" &
    local tmux_pid=$!
    
    filter_tmuxifier_sessions > "$temp_dir/tmuxifier" &
    local tmuxifier_pid=$!
    
    get_zoxide_paths > "$temp_dir/zoxide" &
    local zoxide_pid=$!
    
    get_find_paths > "$temp_dir/find" &
    local find_pid=$!
    
    wait $tmux_pid $tmuxifier_pid $zoxide_pid $find_pid
    
    {
        cat "$temp_dir/tmux" 2>/dev/null
        cat "$temp_dir/tmuxifier" 2>/dev/null
        cat "$temp_dir/zoxide" 2>/dev/null
        cat "$temp_dir/find" 2>/dev/null
    } | sed '/^$/d'
}

get_session_windows() {
    local session=$1
    tmux list-windows -t "$session" -F "#I: #W #{window_active?*active*:}" 2>/dev/null | sed 's/*active*/(active)/'
}

handle_find_path() {
    local path=$1
    local session_name=$(basename "$path" | tr '.' '_' | tr ' ' '_' | tr '-' '_')

    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux switch-client -t "$session_name"
    else
        tmux new-session -d -s "$session_name" -c "$path"
        tmux switch-client -t "$session_name"
    fi
}

handle_zoxide_path() {
    local path=$1
    local session_name=$(basename "$path" | tr '.' '_' | tr ' ' '_' | tr '-' '_')

    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux switch-client -t "$session_name"
    else
        tmux new-session -d -s "$session_name" -c "$path"
        tmux switch-client -t "$session_name"
    fi
}

switch_session() {
    local session_name=$1
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux display-message "Session '$session_name' does not exist"
        return 1
    fi
    
    if tmux switch-client -t "$session_name" 2>/dev/null; then
        tmux display-message "Switched to session: $session_name"
    else
        if tmux attach-session -t "$session_name" 2>/dev/null; then
            tmux display-message "Attached to session: $session_name"
        else
            tmux display-message "Failed to switch to session: $session_name"
        fi
    fi
}

switch_window() {
    local session=$1
    local window=$2
    local window_index=$(echo "$window" | cut -d':' -f1)
    tmux select-window -t "$session:$window_index"
}

rename_window() {
    local session=$1
    local window=$2
    local window_index=$(echo "$window" | cut -d':' -f1)
    local current_name=$(echo "$window" | sed 's/^[0-9]*: //' | sed 's/ (active)//')

    local new_name=$(echo "$current_name" | fzf --print-query --query="$current_name" --prompt="Rename window to: " --header="Press Enter to confirm" --reverse)

    if [ -n "$new_name" ] && [ "$new_name" != "$current_name" ]; then
        if tmux rename-window -t "$session:$window_index" "$new_name" 2>/dev/null; then
            tmux display-message "Renamed window: $current_name → $new_name"
        else
            tmux display-message "Failed to rename window: $current_name"
        fi
    fi
}

delete_window() {
    local session=$1
    local window=$2
    local window_index=$(echo "$window" | cut -d':' -f1)
    local window_name=$(echo "$window" | sed 's/^[0-9]*: //' | sed 's/ (active)//')
    
    local window_count=$(tmux list-windows -t "$session" 2>/dev/null | wc -l)
    if [ "$window_count" -eq 1 ]; then
        echo "Cannot delete the only window in session. This would terminate the session." | fzf --header="Error" --reverse
        return 1
    fi

    local current_window=$(tmux display-message -p '#I')
    if [ "$window_index" = "$current_window" ]; then
        local confirmation=$(echo -e "y\nn" | fzf --header="Delete current window '$window_name'? This will switch to another window. Select 'y' to confirm" --reverse)
    else
        local confirmation=$(echo -e "y\nn" | fzf --header="Delete window '$window_name'? Select 'y' to confirm" --reverse)
    fi

    if [ "$confirmation" = "y" ]; then
        if tmux kill-window -t "$session:$window_index" 2>/dev/null; then
            tmux display-message "Deleted window: $window_name"
        else
            tmux display-message "Failed to delete window: $window_name"
        fi
    fi
}

create_window() {
    local session=$1
    local window_name=$(echo "" | fzf --print-query --prompt="New window name (optional): " --header="Press Enter to create window" --reverse)
    
    if [ -n "$window_name" ]; then
        tmux new-window -t "$session" -n "$window_name"
    else
        tmux new-window -t "$session"
    fi
    
    tmux display-message "Created new window"
}

create_new_session() {
    local session_name=$(echo "" | fzf --print-query --prompt="New session name: " --header="Press Enter to create session" --reverse)
    
    if [ -z "$session_name" ]; then
        return 0
    fi
    
    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux display-message "Session '$session_name' already exists"
        sleep 1
        main
        return 1
    fi
    
    local start_dir=$(echo "$HOME" | fzf --print-query --query="$HOME" --prompt="Starting directory (optional): " --header="Press Enter to use this directory or leave empty for current" --reverse)
    
    if [ -n "$start_dir" ] && [ -d "$start_dir" ]; then
        tmux new-session -d -s "$session_name" -c "$start_dir"
    else
        tmux new-session -d -s "$session_name"
    fi
    
    tmux switch-client -t "$session_name"
    tmux display-message "Created and switched to session: $session_name"
}

load_tmuxifier_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)

    if [ -z "$tmuxifier_dir" ]; then
        tmux display-message "Tmuxifier installation not found"
        return 1
    fi

    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local session_file="$layouts_dir/$session.session.sh"

    if [ ! -f "$session_file" ]; then
        tmux display-message "Session file not found: $session_file"
        return 1
    fi

    local temp_script=$(mktemp -t "tmuxifier_load_XXXXXX.sh")

    cat > "$temp_script" << 'SCRIPT_EOF'
#!/bin/bash

cleanup() {
    local script_path="$0"
    (sleep 2 && rm -f "$script_path") &
}
trap cleanup EXIT

export TMUXIFIER="%TMUXIFIER_DIR%"
export PATH="$TMUXIFIER/bin:$PATH"
export TMUXIFIER_LAYOUT_PATH="%LAYOUTS_DIR%"

if [ -f "$TMUXIFIER/init.sh" ]; then
    source "$TMUXIFIER/init.sh"
fi

if command -v tmuxifier >/dev/null 2>&1; then
    tmuxifier load-session "%SESSION_NAME%"
else
    if [ -f "%SESSION_FILE%" ]; then
        source "%SESSION_FILE%"
    else
        echo "Error: Session file not found: %SESSION_FILE%"
        exit 1
    fi
fi
SCRIPT_EOF

    sed -i "s|%TMUXIFIER_DIR%|$tmuxifier_dir|g" "$temp_script"
    sed -i "s|%LAYOUTS_DIR%|$layouts_dir|g" "$temp_script"
    sed -i "s|%SESSION_NAME%|$session|g" "$temp_script"
    sed -i "s|%SESSION_FILE%|$session_file|g" "$temp_script"

    chmod +x "$temp_script"
    tmux detach-client -E "exec '$temp_script'"
}

rename_tmux_session() {
    local old_name=$1
    local new_name=$(echo "$old_name" | fzf --print-query --query="$old_name" --prompt="Rename session to: " --header="Press Enter to confirm" --reverse)

    if [ -n "$new_name" ] && [ "$new_name" != "$old_name" ]; then
        if tmux rename-session -t "$old_name" "$new_name" 2>/dev/null; then
            tmux display-message "Renamed session: $old_name → $new_name"
        else
            tmux display-message "Failed to rename session: $old_name"
        fi
    fi
}

rename_tmuxifier_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)
    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local old_file="$layouts_dir/$session.session.sh"

    if [ ! -f "$old_file" ]; then
        tmux display-message "Session file not found: $old_file"
        return 1
    fi

    local new_name=$(echo "$session" | fzf --print-query --query="$session" --prompt="Rename tmuxifier session to: " --header="Press Enter to confirm" --reverse)

    if [ -n "$new_name" ] && [ "$new_name" != "$session" ]; then
        local new_file="$layouts_dir/$new_name.session.sh"
        if mv "$old_file" "$new_file" 2>/dev/null; then
            tmux display-message "Renamed tmuxifier session: $session → $new_name"
        else
            tmux display-message "Failed to rename tmuxifier session: $session"
        fi
    fi
}

terminate_tmux_session() {
    local session=$1
    local current_session=$(tmux display-message -p '#S')

    if [ "$session" = "$current_session" ]; then
        echo "Cannot terminate current session." | fzf --header="Error" --reverse
        return 1
    fi

    local confirmation=$(echo -e "y\nn" | fzf --header="Terminate session $session? Select 'y' to confirm" --reverse)

    if [ "$confirmation" = "y" ]; then
        if tmux kill-session -t "$session" 2>/dev/null; then
            tmux display-message "Terminated session: $session"
        else
            tmux display-message "Failed to terminate session: $session"
        fi
    fi
}

delete_tmuxifier_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)
    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local session_file="$layouts_dir/$session.session.sh"

    if [ ! -f "$session_file" ]; then
        tmux display-message "Session file not found: $session_file"
        return 1
    fi

    echo -e "y\nn" | fzf --header="Delete tmuxifier session $session? Select 'y' to confirm" --reverse > /tmp/tmux_confirm.txt
    local confirm=$(cat /tmp/tmux_confirm.txt 2>/dev/null)
    rm -f /tmp/tmux_confirm.txt

    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        if rm "$session_file" 2>/dev/null; then
            tmux display-message "Deleted tmuxifier session: $session"
        else
            tmux display-message "Failed to delete tmuxifier session: $session"
        fi
    fi
}

edit_tmuxifier_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)
    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local session_file="$layouts_dir/$session.session.sh"

    if [ ! -f "$session_file" ]; then
        tmux display-message "Session file not found: $session_file"
        return 1
    fi

    tmux new-window "$DEFAULT_EDITOR '$session_file'"
}

toggle_preview() {
    if [ "$PREVIEW_ENABLED" = "true" ]; then
        tmux set-option -g "@omnimux-preview-enabled" "false"
        tmux display-message "Preview disabled"
    else
        tmux set-option -g "@omnimux-preview-enabled" "true"
        tmux display-message "Preview enabled"
    fi
    PREVIEW_ENABLED=$(get_tmux_option "@omnimux-preview-enabled" "true")
    main
}

create_preview_script() {
    local preview_script=$(mktemp -t "tmux_preview_XXXXXX.sh")
    
    cat > "$preview_script" << PREVIEW_EOF
#!/bin/bash

session_line="\$1"
session_name=\$(echo "\$session_line" | awk '{print \$1}')

if echo "\$session_line" | grep -q "(tmux)"; then
    printf "\033[1;36mSession:\033[0m \033[1;33m%s\033[0m\n" "\$session_name"

    # Single tmux call to get window and pane info
    active_info=\$(tmux list-windows -t "\$session_name" -F "#{window_active} #I #{pane_id}" 2>/dev/null | grep "^1" | head -1)
    if [ -n "\$active_info" ]; then
        active_pane=\$(echo "\$active_info" | awk '{print \$3}')
        
        if [ -n "\$active_pane" ]; then
            tmux capture-pane -e -t "\$active_pane" -p 2>/dev/null | head -$SHOW_PREVIEW_LINES

            printf "\n\033[1;36mRunning processes:\033[0m\n"
            pane_pid=\$(tmux list-panes -t "\$active_pane" -F "#{pane_pid}" 2>/dev/null | head -1)
            if [ -n "\$pane_pid" ]; then
                ps --ppid \$pane_pid -o pid=,cmd= 2>/dev/null | head -$SHOW_PROCESS_COUNT | while read line; do
                    if [ -n "\$line" ]; then
                        printf "\033[1;35m%s\033[0m \033[1;37m%s\033[0m\n" "\$(echo \$line | awk '{print \$1}')" "\$(echo \$line | cut -d' ' -f2-)"
                    fi
                done
            fi
        fi
    fi
elif echo "\$session_line" | grep -q "(tmuxifier)"; then
    printf "\033[1;36mTmuxifier Session:\033[0m \033[1;33m%s\033[0m\n\n" "\$session_name"

    tmuxifier_dir=""
    for path in "\$HOME/.tmuxifier" "\$HOME/.local/share/tmuxifier" "/usr/local/share/tmuxifier"; do
        if [ -d "\$path" ]; then
            tmuxifier_dir="\$path"
            break
        fi
    done

    if [ -n "\$tmuxifier_dir" ]; then
        layouts_dir="\${TMUXIFIER_LAYOUT_PATH:-\$tmuxifier_dir/layouts}"
        session_file="\$layouts_dir/\$session_name.session.sh"
        if [ -f "\$session_file" ]; then
            if command -v bat >/dev/null 2>&1; then
                bat --color=always --style=plain "\$session_file" 2>/dev/null
            elif command -v highlight >/dev/null 2>&1; then
                highlight -O ansi "\$session_file" 2>/dev/null
            else
                cat "\$session_file"
            fi
        else
            echo "Session file not found: \$session_file"
        fi
    else
        echo "Tmuxifier installation not found"
    fi
elif echo "\$session_line" | grep -q "(zoxide)" || echo "\$session_line" | grep -q "(find)"; then
    path=\$(echo "\$session_line" | awk '{print \$1}')
    if echo "\$session_line" | grep -q "(zoxide)"; then
        printf "\033[1;36mZoxide Path:\033[0m \033[1;33m%s\033[0m\n\n" "\$path"
    else
        printf "\033[1;36mFind Path:\033[0m \033[1;33m%s\033[0m\n\n" "\$path"
    fi

    if [ -d "\$path" ]; then
        printf "\033[1;36mDirectory contents:\033[0m\n"
        $LS_COMMAND "\$path" 2>/dev/null | head -$SHOW_LS_LINES
        
        printf "\n\033[1;36mGit status (if applicable):\033[0m\n"
        if [ -d "\$path/.git" ]; then
            cd "\$path" && git status --porcelain 2>/dev/null | head -$SHOW_GIT_STATUS_LINES
        else
            echo "Not a git repository"
        fi
    else
        echo "Directory does not exist or is not accessible"
    fi
fi
PREVIEW_EOF

    chmod +x "$preview_script"
    echo "$preview_script"
}

show_windows() {
    local session=$1

    local windows=$(get_session_windows "$session")

    if [ -z "$windows" ]; then
        echo "No windows found in session $session." | fzf --header="Error" --reverse
        return 1
    fi

    local header_text="ctrl-r:Rename / ctrl-d:Delete / ctrl-n:New Window / ?:Help"
    local fzf_cmd="fzf --header=\"$header_text\" --prompt=\"$FZF_WINDOW_PROMPT\" --pointer=\"$FZF_WINDOW_POINTER\" --ansi --expect=ctrl-r,ctrl-d,ctrl-n,? --\"$FZF_WINDOW_LAYOUT\" --height=\"$FZF_HEIGHT\" --border=\"$FZF_BORDER\""

    if [ "$PREVIEW_ENABLED" = "true" ]; then
        local window_preview_script=$(mktemp -t "tmux_window_preview_XXXXXX.sh")
        
        cat > "$window_preview_script" << WINDOW_PREVIEW_EOF
#!/bin/bash
session="$session"
window=\$(echo "\$1" | sed 's/ (active)//')
window_index=\$(echo "\$window" | cut -d':' -f1)

echo -e "\033[1;36mWindow Preview:\033[0m \033[1;33m\$window\033[0m\n"

# Optimized single tmux call for pane info
pane_info=\$(tmux list-panes -t "\$session:\$window_index" -F "#{pane_active} #{pane_id} #{pane_pid}" 2>/dev/null | grep "^1" | head -1)
if [ -n "\$pane_info" ]; then
    active_pane=\$(echo "\$pane_info" | awk '{print \$2}')
    pane_pid=\$(echo "\$pane_info" | awk '{print \$3}')
    
    if [ -n "\$active_pane" ]; then
        tmux capture-pane -e -t "\$active_pane" -p 2>/dev/null | head -$SHOW_PREVIEW_LINES

        echo -e "\n\033[1;36mRunning processes:\033[0m"
        if [ -n "\$pane_pid" ]; then
            ps --ppid \$pane_pid -o pid=,cmd= 2>/dev/null | head -$SHOW_PROCESS_COUNT | while read line; do
                if [ -n "\$line" ]; then
                    echo -e "\033[1;35m\$(echo \$line | awk '{print \$1}')\033[0m \033[1;37m\$(echo \$line | cut -d' ' -f2-)\033[0m"
                fi
            done
        fi
    fi
fi
WINDOW_PREVIEW_EOF

        chmod +x "$window_preview_script"
        fzf_cmd="$fzf_cmd --preview=\"$window_preview_script {}\" --preview-window=\"$FZF_PREVIEW_WINDOW_POSITION\""
    fi

    local result=$(echo "$windows" | eval "$fzf_cmd")

    if [ "$PREVIEW_ENABLED" = "true" ] && [ -n "$window_preview_script" ]; then
        rm -f "$window_preview_script" 2>/dev/null
    fi

    local key=$(echo "$result" | head -1)
    local selection=$(echo "$result" | tail -1)

    if [ -z "$selection" ]; then
        return 0
    fi

    local window=$(echo "$selection" | sed 's/ (active)//')

    case "$key" in
        "ctrl-r")
            rename_window "$session" "$window"
            show_windows "$session" 
        ;;
        "ctrl-d")
            delete_window "$session" "$window"
            show_windows "$session"
        ;;
        "ctrl-n")
            create_window "$session"
            show_windows "$session"
        ;;
        "?")
            show_window_help "$session"
        ;;
        *)
            switch_window "$session" "$window"
        ;;
    esac
}

show_help() {
    local help_text="Enter       Select session (switch to active, load tmuxifier, or create session from path)
ctrl-r      Rename selected session
ctrl-e      Edit tmuxifier session file
ctrl-t      Terminate active tmux session
ctrl-d      Delete tmuxifier session file
ctrl-w      Show windows in the selected session
ctrl-n      Create new session
ctrl-p      Toggle preview mode (currently: $PREVIEW_ENABLED)
?           Show this help menu
Escape      Exit"

    echo "$help_text" | fzf --reverse --header "Keyboard Shortcuts" --prompt "Press Escape to return" --border="$FZF_BORDER" --height="$FZF_HEIGHT"
    main
}

show_window_help() {
    local session=$1

    cat << EOF | fzf --reverse --header "Window Shortcuts" --prompt "Press Escape to return" --border="$FZF_BORDER" --height="$FZF_HEIGHT"
Enter       Switch to selected window
ctrl-r      Rename selected window
ctrl-d      Delete selected window
ctrl-n      Create new window
Escape      Return to sessions
EOF
    show_windows "$session"
}

handle_session() {
    local selection="$1"
    local session_name=$(echo "$selection" | awk '{print $1}')

    if echo "$selection" | grep -q "(tmux)"; then
        switch_session "$session_name"
    elif echo "$selection" | grep -q "(tmuxifier)"; then
        load_tmuxifier_session "$session_name"
    elif echo "$selection" | grep -q "(zoxide)"; then
        handle_zoxide_path "$session_name"
    elif echo "$selection" | grep -q "(find)"; then
        handle_find_path "$session_name"
    else
        switch_session "$session_name"
    fi
}

main() {
    load_options
    
    {
        get_tmux_sessions > /dev/null 2>&1 &
        get_tmuxifier_sessions > /dev/null 2>&1 &
        if command -v zoxide &> /dev/null; then
            get_zoxide_paths > /dev/null 2>&1 &
        fi
    }
    
    local all_sessions=$(get_all_sessions)

    if [ -z "$all_sessions" ]; then
        echo "No tmux, tmuxifier sessions or directory paths found." | fzf --header="Error" --reverse
        return 1
    fi

    local preview_script=""
    local cleanup_preview_func=""
    
    if [ "$PREVIEW_ENABLED" = "true" ]; then
        preview_script=$(create_preview_script)
        cleanup_preview_func() {
            rm -f "$preview_script" 2>/dev/null
        }
        trap cleanup_preview_func EXIT
    fi

    local header_text="ctrl-r:Rename / ctrl-e:Edit / ctrl-t:Terminate / ctrl-d:Delete / ctrl-w:Windows / ctrl-n:New Session / ctrl-p:Preview ($PREVIEW_ENABLED) / ?:Help"
    local fzf_cmd="fzf --header=\"$header_text\" --prompt=\"$FZF_PROMPT\" --pointer=\"$FZF_POINTER\" --ansi --expect=ctrl-r,ctrl-e,ctrl-t,ctrl-d,ctrl-w,ctrl-n,ctrl-p,ctrl-/,? --\"$FZF_LAYOUT\" --height=\"$FZF_HEIGHT\" --border=\"$FZF_BORDER\""

    if [ "$PREVIEW_ENABLED" = "true" ]; then
        fzf_cmd="$fzf_cmd --preview=\"$preview_script {}\" --preview-window=\"$FZF_PREVIEW_POSITION\""
    fi

    local result=$(echo "$all_sessions" | eval "$fzf_cmd")

    local key=$(echo "$result" | head -1)
    local selection=$(echo "$result" | tail -1)

    if [ -z "$selection" ]; then
        [ -n "$cleanup_preview_func" ] && cleanup_preview_func
        return 0
    fi

    case "$key" in
        "ctrl-r")
            local session_name=$(echo "$selection" | awk '{print $1}')
            if echo "$selection" | grep -q "(active)"; then
                rename_tmux_session "$session_name"
            elif echo "$selection" | grep -q "(tmuxifier)"; then
                rename_tmuxifier_session "$session_name"
            elif echo "$selection" | grep -q "(zoxide)" || echo "$selection" | grep -q "(find)"; then
                if echo "$selection" | grep -q "(zoxide)"; then
                    tmux display-message "Cannot rename zoxide paths"
                else
                    tmux display-message "Cannot rename find paths"
                fi
                sleep 1
                main
            fi
        ;;
        "ctrl-e")
            local session_name=$(echo "$selection" | awk '{print $1}')
            if echo "$selection" | grep -q "(tmuxifier)"; then
                edit_tmuxifier_session "$session_name"
            else
                tmux display-message "Can only edit tmuxifier session files"
                sleep 1
                main
            fi
        ;;
        "ctrl-t")
            local session_name=$(echo "$selection" | awk '{print $1}')
            if echo "$selection" | grep -q "(tmux)"; then
                terminate_tmux_session "$session_name"
            else
                tmux display-message "Can only terminate tmux sessions"
                sleep 1
                main
            fi
        ;;
        "ctrl-d")
            local session_name=$(echo "$selection" | awk '{print $1}')
            if echo "$selection" | grep -q "(tmuxifier)"; then
                delete_tmuxifier_session "$session_name"
            else
                tmux display-message "Can only delete tmuxifier session files"
                sleep 1
                main
            fi
        ;;
        "ctrl-w")
            local session_name=$(echo "$selection" | awk '{print $1}')
            if echo "$selection" | grep -q "(active)"; then
                show_windows "$session_name"
            else
                tmux display-message "Can only show windows for active sessions"
                sleep 1
                main
            fi
        ;;
        "ctrl-n")
            create_new_session
            main
        ;;
        "ctrl-p")
            toggle_preview
        ;;
        "ctrl-/")
            local find_sessions=$(get_find_paths)
            if [ -z "$find_sessions" ]; then
                echo "No find results available." | fzf --header="Error" --reverse
                main
                return
            fi
            
            local find_fzf_cmd="fzf --header=\"Find Results - Enter:Select / Escape:Back\" --prompt=\"$FZF_PROMPT\" --pointer=\"$FZF_POINTER\" --ansi --\"$FZF_LAYOUT\" --height=\"$FZF_HEIGHT\" --border=\"$FZF_BORDER\""
            
            if [ "$PREVIEW_ENABLED" = "true" ]; then
                find_fzf_cmd="$find_fzf_cmd --preview=\"$preview_script {}\" --preview-window=\"$FZF_PREVIEW_POSITION\""
            fi
            
            local find_result=$(echo "$find_sessions" | eval "$find_fzf_cmd")
            
            if [ -n "$find_result" ]; then
                handle_session "$find_result"
            else
                main
            fi
            [ -n "$cleanup_preview_func" ] && cleanup_preview_func
            return
        ;;
        "?")
            show_help
        ;;
        *)
            handle_session "$selection"
        ;;
    esac
    
    [ -n "$cleanup_preview_func" ] && cleanup_preview_func
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
