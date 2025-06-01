#!/bin/bash

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value=$(tmux show-option -gqv "$option")
    echo "${option_value:-$default_value}"
}

ACTIVE_BG=$(get_tmux_option "@termonaut-active-bg" "#444444")
ACTIVE_FG=$(get_tmux_option "@termonaut-active-fg" "#ffffff")
INACTIVE_BG=$(get_tmux_option "@termonaut-inactive-bg" "#222222")
INACTIVE_FG=$(get_tmux_option "@termonaut-inactive-fg" "#777777")
TMUXIFIER_COLOR=$(get_tmux_option "@termonaut-tmuxifier-color" "\033[38;5;39m")
ZOXIDE_COLOR=$(get_tmux_option "@termonaut-zoxide-color" "\033[38;5;208m")
FIND_COLOR=$(get_tmux_option "@termonaut-find-color" "\033[38;5;118m")
NORMAL=""
ACTIVE_COLOR=""

FZF_HEIGHT=$(get_tmux_option "@termonaut-fzf-height" "100%")
FZF_BORDER=$(get_tmux_option "@termonaut-fzf-border" "none")
FZF_LAYOUT=$(get_tmux_option "@termonaut-fzf-layout" "no-reverse")
FZF_WINDOW_LAYOUT=$(get_tmux_option "@termonaut-fzf-window-layout" "reverse")
FZF_PREVIEW_POSITION=$(get_tmux_option "@termonaut-fzf-preview-position" "bottom:60%")
FZF_PREVIEW_WINDOW_POSITION=$(get_tmux_option "@termonaut-fzf-preview-window-position" "right:75%")

MAX_ZOXIDE_PATHS=$(get_tmux_option "@termonaut-max-zoxide-paths" "20")
MAX_FIND_PATHS=$(get_tmux_option "@termonaut-max-find-paths" "15")
FIND_BASE_DIR=$(get_tmux_option "@termonaut-find-base-dir" "$HOME")
FIND_MAX_DEPTH=$(get_tmux_option "@termonaut-find-max-depth" "3")
FIND_MIN_DEPTH=$(get_tmux_option "@termonaut-find-min-depth" "1")
SHOW_PROCESS_COUNT=$(get_tmux_option "@termonaut-show-process-count" "3")
SHOW_PREVIEW_LINES=$(get_tmux_option "@termonaut-show-preview-lines" "15")
SHOW_LS_LINES=$(get_tmux_option "@termonaut-show-ls-lines" "20")
SHOW_GIT_STATUS_LINES=$(get_tmux_option "@termonaut-show-git-status-lines" "10")

DEFAULT_EDITOR=$(get_tmux_option "@termonaut-editor" "${EDITOR:-vim}")

find_tmuxifier() {
    TMUXIFIER_PATHS=(
        "$HOME/.tmuxifier"
        "$HOME/.local/share/tmuxifier"
        "/usr/local/share/tmuxifier"
    )

    for path in "${TMUXIFIER_PATHS[@]}"; do
        if [ -d "$path" ]; then
            echo "$path"
            return 0
        fi
    done

    return 1
}

get_tmux_sessions() {
    tmux list-sessions -F "#S ${ACTIVE_COLOR}(active)${NORMAL}" 2>/dev/null | sort
}

get_tmuxifier_sessions() {
    local tmuxifier_dir=$(find_tmuxifier)

    if [ -n "$tmuxifier_dir" ]; then
        local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"

        if [ -d "$layouts_dir" ]; then
            find "$layouts_dir" -name "*.session.sh" -exec basename {} \; 2>/dev/null |
                sed 's/\.session\.sh$//' |
                awk '{print $0 " '${TMUXIFIER_COLOR}'(tmuxifier)'"\033[0m"'"}' |
                sort
        fi
    fi
}

get_zoxide_paths() {
    if command -v zoxide &> /dev/null; then
        zoxide query -l 2>/dev/null | head -"$MAX_ZOXIDE_PATHS" |
            awk '{print $0 " '${ZOXIDE_COLOR}'(zoxide)'"\033[0m"'"}' |
            sort
    fi
}

get_find_paths() {
    if [ -d "$FIND_BASE_DIR" ]; then
        find "$FIND_BASE_DIR" -mindepth "$FIND_MIN_DEPTH" -maxdepth "$FIND_MAX_DEPTH" -type d \
            \( -name ".git" -o -name ".svn" -o -name ".hg" -o -name "node_modules" -o -name "__pycache__" \) -prune -o \
            -type d -readable -print 2>/dev/null |
            head -"$MAX_FIND_PATHS" |
            awk '{print $0 " '${FIND_COLOR}'(find)'"\033[0m"'"}' |
            sort
    fi
}

filter_tmuxifier_sessions() {
    local active_sessions=$(tmux list-sessions -F "#S" 2>/dev/null)
    local tmuxifier_sessions=$(get_tmuxifier_sessions)
    local filtered_sessions=""

    while IFS= read -r session_line; do
        if [ -n "$session_line" ]; then
            local session_name=$(echo "$session_line" | awk '{print $1}')
            if ! echo "$active_sessions" | grep -q "^${session_name}$"; then
                filtered_sessions="${filtered_sessions}${session_line}
"
            fi
        fi
    done <<< "$tmuxifier_sessions"

    echo "$filtered_sessions" | sed '/^$/d'
}

get_all_sessions() {
    local active_sessions=$(get_tmux_sessions)
    local tmuxifier_sessions=$(filter_tmuxifier_sessions)
    local zoxide_paths=$(get_zoxide_paths)
    local find_paths=$(get_find_paths)

    {
        echo "$active_sessions"
        echo "$tmuxifier_sessions"
        echo "$zoxide_paths"
        echo "$find_paths"
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
    tmux switch-client -t "$session_name"
}

switch_window() {
    local session=$1
    local window=$2

    local window_index=$(echo "$window" | cut -d':' -f1)

    tmux select-window -t "$session:$window_index"
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

    echo -e "y\nn" | fzf --header="Terminate session $session? Select 'y' to confirm" --reverse > /tmp/tmux_confirm.txt
    local confirm=$(cat /tmp/tmux_confirm.txt 2>/dev/null)
    rm -f /tmp/tmux_confirm.txt

    if [ "$confirm" = "y" ]; then
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

create_preview_script() {
    local preview_script=$(mktemp -t "tmux_preview_XXXXXX.sh")
    
    cat > "$preview_script" << PREVIEW_EOF
#!/bin/bash

session_line="\$1"
session_name=\$(echo "\$session_line" | awk '{print \$1}')

if echo "\$session_line" | grep -q "(active)"; then
    echo -e "\033[1;36mSession:\033[0m \033[1;33m\$session_name\033[0m"

    active_window=\$(tmux list-windows -t "\$session_name" -F "#{window_active} #I" 2>/dev/null | grep "^1" | awk '{print \$2}')
    if [ -z "\$active_window" ]; then
        active_window=\$(tmux list-windows -t "\$session_name" -F "#I" 2>/dev/null | head -1)
    fi

    if [ -n "\$active_window" ]; then
        echo -e "\n\033[1;36mPreview of active window \$active_window:\033[0m"
        active_pane=\$(tmux list-panes -t "\$session_name:\$active_window" -F "#{pane_active} #{pane_id}" 2>/dev/null | grep "^1" | awk '{print \$2}')
        if [ -z "\$active_pane" ]; then
            active_pane=\$(tmux list-panes -t "\$session_name:\$active_window" -F "#{pane_id}" 2>/dev/null | head -1)
        fi

        if [ -n "\$active_pane" ]; then
            tmux capture-pane -e -t "\$active_pane" -p 2>/dev/null | head -$SHOW_PREVIEW_LINES

            echo -e "\n\033[1;36mRunning processes:\033[0m"
            pane_pid=\$(tmux list-panes -t "\$active_pane" -F "#{pane_pid}" 2>/dev/null | head -1)
            if [ -n "\$pane_pid" ]; then
                ps --ppid \$pane_pid -o pid=,cmd= 2>/dev/null | head -$SHOW_PROCESS_COUNT | while read line; do
                    if [ -n "\$line" ]; then
                        echo -e "\033[1;35m\$(echo \$line | awk '{print \$1}')\033[0m \033[1;37m\$(echo \$line | cut -d' ' -f2-)\033[0m"
                    fi
                done
            fi
        fi
    fi
elif echo "\$session_line" | grep -q "(tmuxifier)"; then
    echo -e "\033[1;36mTmuxifier Session:\033[0m \033[1;33m\$session_name\033[0m\n"

    # Find tmuxifier directory
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
        echo -e "\033[1;36mZoxide Path:\033[0m \033[1;33m\$path\033[0m\n"
    else
        echo -e "\033[1;36mFind Path:\033[0m \033[1;33m\$path\033[0m\n"
    fi

    if [ -d "\$path" ]; then
        echo -e "\033[1;36mDirectory contents:\033[0m"
        ls -la "\$path" 2>/dev/null | head -$SHOW_LS_LINES
        
        echo -e "\n\033[1;36mGit status (if applicable):\033[0m"
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

    local result=$(echo "$windows" | fzf \
        --header="[Enter:Select ?:Help] Windows for $session" \
        --prompt="> " \
        --ansi \
        --expect=? \
        --"$FZF_WINDOW_LAYOUT" \
        --height="$FZF_HEIGHT" \
        --border="$FZF_BORDER" \
        --preview="
            session='$session';
            window=\$(echo {} | sed 's/ (active)//');
            window_index=\$(echo \"\$window\" | cut -d':' -f1);

            echo -e \"\033[1;36mWindow Preview:\033[0m \033[1;33m\$window\033[0m\n\";

            echo -e \"\033[1;36mPanes:\033[0m\";
            tmux list-panes -t \"\$session:\$window_index\" -F \"\033[1;32m#P:\033[0m \033[1;37m#{pane_current_command}\033[0m [\033[1;34m#{pane_active?active:}\033[0m]\" 2>/dev/null | sed 's/\[\]//g';
            echo \"\";

            active_pane=\$(tmux list-panes -t \"\$session:\$window_index\" -F \"#{pane_active} #{pane_id}\" 2>/dev/null | grep \"^1\" | awk '{print \$2}');
            if [ -z \"\$active_pane\" ]; then
                active_pane=\$(tmux list-panes -t \"\$session:\$window_index\" -F \"#{pane_id}\" 2>/dev/null | head -1);
            fi;

            if [ -n \"\$active_pane\" ]; then
                echo -e \"\033[1;36mPane content preview:\033[0m\";
                tmux capture-pane -e -t \"\$active_pane\" -p 2>/dev/null | head -$SHOW_PREVIEW_LINES;

                echo -e \"\n\033[1;36mRunning processes:\033[0m\";
                pane_pid=\$(tmux list-panes -t \"\$active_pane\" -F \"#{pane_pid}\" 2>/dev/null | head -1);
                if [ -n \"\$pane_pid\" ]; then
                    ps --ppid \$pane_pid -o pid=,cmd= 2>/dev/null | head -$SHOW_PROCESS_COUNT | while read line; do
                        if [ -n \"\$line\" ]; then
                            echo -e \"\033[1;35m\$(echo \$line | awk '{print \$1}')\033[0m \033[1;37m\$(echo \$line | cut -d' ' -f2-)\033[0m\";
                        fi
                    done;
                fi;
            fi;
        " \
        --preview-window="$FZF_PREVIEW_WINDOW_POSITION")

    local key=$(echo "$result" | head -1)
    local selection=$(echo "$result" | tail -1)

    if [ -z "$selection" ]; then
        return 0
    fi

    local window=$(echo "$selection" | sed 's/ (active)//')

    case "$key" in
        "?")
            show_window_help "$session"
        ;;
        *)
            switch_window "$session" "$window"
        ;;
    esac
}

show_help() {
    cat << EOF | fzf --reverse --header "Keyboard Shortcuts" --prompt "Press Escape to return" --border="$FZF_BORDER" --height="$FZF_HEIGHT"
Enter       Select session (switch to active, load tmuxifier, or create session from path)
ctrl-r      Rename selected session
ctrl-e      Edit tmuxifier session file
ctrl-t      Terminate active tmux session
ctrl-d      Delete tmuxifier session file
ctrl-w      Show windows in the selected session
ctrl-f      Filter/search sessions
?           Show this help menu
Escape      Exit
EOF
    main
}

show_window_help() {
    local session=$1

    cat << EOF | fzf --reverse --header "Window Shortcuts" --prompt "Press Escape to return" --border="$FZF_BORDER" --height="$FZF_HEIGHT"
Enter       Switch to selected window
Escape      Return to sessions
EOF
    show_windows "$session"
}

handle_session() {
    local selection="$1"
    local session_name=$(echo "$selection" | awk '{print $1}')

    if echo "$selection" | grep -q "(active)"; then
        switch_session "$session_name"
    elif echo "$selection" | grep -q "(tmuxifier)"; then
        load_tmuxifier_session "$session_name"
    elif echo "$selection" | grep -q "(zoxide)"; then
        handle_zoxide_path "$session_name"
    elif echo "$selection" | grep -q "(find)"; then
        handle_find_path "$session_name"
    fi
}

main() {
    local all_sessions=$(get_all_sessions)

    if [ -z "$all_sessions" ]; then
        echo "No tmux, tmuxifier sessions or directory paths found." | fzf --header="Error" --reverse
        return 1
    fi

    local preview_script=$(create_preview_script)
    
    cleanup_preview() {
        rm -f "$preview_script" 2>/dev/null
    }
    trap cleanup_preview EXIT

    local result=$(echo "$all_sessions" | fzf \
        --header="Enter:Select / ctrl-r:Rename / ctrl-e:Edit / ctrl-t:Terminate / ctrl-d:Delete / ctrl-w:Windows / ctrl-f:Filter / ?:Help" \
        --prompt="> " \
        --ansi \
        --expect=ctrl-r,ctrl-e,ctrl-t,ctrl-d,ctrl-w,ctrl-f,? \
        --"$FZF_LAYOUT" \
        --height="$FZF_HEIGHT" \
        --border="$FZF_BORDER" \
        --preview="$preview_script {}" \
        --preview-window="$FZF_PREVIEW_POSITION")

    local key=$(echo "$result" | head -1)
    local selection=$(echo "$result" | tail -1)

    if [ -z "$selection" ]; then
        cleanup_preview
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
            if echo "$selection" | grep -q "(active)"; then
                terminate_tmux_session "$session_name"
            else
                tmux display-message "Can only terminate active tmux sessions"
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
        "?")
            show_help
        ;;
        *)
            handle_session "$selection"
        ;;
    esac
    
    cleanup_preview
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
