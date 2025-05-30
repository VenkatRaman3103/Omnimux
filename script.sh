#!/bin/bash

ACTIVE_BG="#444444"
ACTIVE_FG="#ffffff"
INACTIVE_BG="#222222"
INACTIVE_FG="#777777"
TMUXIFIER_COLOR="\033[38;5;39m"
ACTIVE_COLOR=""
ZOXIDE_COLOR="\033[38;5;208m"
NORMAL=""

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
    tmux list-sessions -F "#S ${ACTIVE_COLOR}(active)${NORMAL}" | sort
}

get_tmuxifier_sessions() {
    local tmuxifier_dir=$(find_tmuxifier)
    
    if [ -n "$tmuxifier_dir" ]; then
        local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
        
        if [ -d "$layouts_dir" ]; then
            find "$layouts_dir" -name "*.session.sh" -exec basename {} \; | 
                sed 's/\.session\.sh$//' | 
                awk '{print $0 " '${TMUXIFIER_COLOR}'(tmuxifier)'"\033[0m"'"}' |
                sort
        fi
    fi
}

get_zoxide_paths() {
    if command -v zoxide &> /dev/null; then
        zoxide query -l | head -20 | 
            awk '{print $0 "'${TMUXIFIER_COLOR}' '${ZOXIDE_COLOR}'(zoxide)'"\033[0m"'"}' |
            sort
    fi
}

filter_tmuxifier_sessions() {
    local active_sessions=$(tmux list-sessions -F "#S" 2>/dev/null)
    local tmuxifier_sessions=$(get_tmuxifier_sessions)
    local filtered_sessions=""
    
    while IFS= read -r session_line; do
        local session_name=$(echo "$session_line" | awk '{print $1}')
        if ! echo "$active_sessions" | grep -q "^${session_name}$"; then
            filtered_sessions="${filtered_sessions}${session_line}
"
        fi
    done <<< "$tmuxifier_sessions"
    
    echo "$filtered_sessions" | sed '/^$/d' 
}

get_all_sessions() {
    local active_sessions=$(get_tmux_sessions)
    local tmuxifier_sessions=$(filter_tmuxifier_sessions)
    local zoxide_paths=$(get_zoxide_paths)
    echo "$active_sessions"
    echo "$tmuxifier_sessions"
    echo "$zoxide_paths"
}

get_session_windows() {
    local session=$1
    tmux list-windows -t "$session" -F "#I: #W #{window_active?*active*:}" | sed 's/*active*/(active)/'
}

handle_zoxide_path() {
    local path=$1
    
    local session_name=$(basename "$path" | tr '.' '_')
    
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
    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local session_file="$layouts_dir/$session.session.sh"
    
    local temp_script=$(mktemp)
    cat > "$temp_script" << EOF
#!/bin/bash

export TMUXIFIER="$tmuxifier_dir"
export PATH="\$TMUXIFIER/bin:\$PATH"
export TMUXIFIER_LAYOUT_PATH="$layouts_dir"

if [ -f "\$TMUXIFIER/init.sh" ]; then
    source "\$TMUXIFIER/init.sh"
fi

if command -v tmuxifier >/dev/null 2>&1; then
    tmuxifier load-session "$session"
else
    source "$session_file"
fi
EOF
    
    chmod +x "$temp_script"
    
    tmux detach-client -E "$temp_script"
    rm -f "$temp_script"
}

rename_tmux_session() {
    local old_name=$1
    
    local new_name=$(echo "$old_name" | fzf --print-query --query="$old_name" --prompt="Rename session to: " --header="Press Enter to confirm" --reverse)
    
    if [ -n "$new_name" ]; then
        tmux rename-session -t "$old_name" "$new_name"
    fi
}

rename_tmuxifier_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)
    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local old_file="$layouts_dir/$session.session.sh"
    
    local new_name=$(echo "$session" | fzf --print-query --query="$session" --prompt="Rename tmuxifier session to: " --header="Press Enter to confirm" --reverse)
    
    if [ -n "$new_name" ] && [ "$new_name" != "$session" ]; then
        local new_file="$layouts_dir/$new_name.session.sh"
        mv "$old_file" "$new_file"
        tmux display-message "Renamed tmuxifier session: $session → $new_name"
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
    local confirm=$(cat /tmp/tmux_confirm.txt)
    rm /tmp/tmux_confirm.txt
    
    if [ "$confirm" = "y" ]; then
        tmux kill-session -t "$session"
        tmux display-message "Terminated session: $session"
    fi
}

delete_tmuxifier_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)
    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local session_file="$layouts_dir/$session.session.sh"
    
    echo -e "y\nn" | fzf --header="Delete tmuxifier session $session? Select 'y' to confirm" --reverse > /tmp/tmux_confirm.txt
    local confirm=$(cat /tmp/tmux_confirm.txt)
    rm /tmp/tmux_confirm.txt
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        rm "$session_file"
        tmux display-message "Deleted tmuxifier session: $session"
    fi
}

edit_tmuxifier_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)
    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local session_file="$layouts_dir/$session.session.sh"
    local editor="${EDITOR:-vim}"
    
    tmux new-window "$editor $session_file"
}

generate_session_preview() {
    local session_name=$1
    
    if echo "$session_name" | grep -q "(active)"; then
        session_name=$(echo "$session_name" | awk '{print $1}')
        echo -e "\033[1;36mSession:\033[0m \033[1;33m$session_name\033[0m"
        
        active_window=$(tmux list-windows -t "$session_name" -F "#{window_active} #I" | grep "^1" | awk '{print $2}')
        if [ -z "$active_window" ]; then
            active_window=$(tmux list-windows -t "$session_name" -F "#I" | head -1)
        fi
        
        echo -e "\n\033[1;36mPreview of active window $active_window:\033[0m"
        active_pane=$(tmux list-panes -t "$session_name:$active_window" -F "#{pane_active} #{pane_id}" | grep "^1" | awk '{print $2}')
        if [ -z "$active_pane" ]; then
            active_pane=$(tmux list-panes -t "$session_name:$active_window" -F "#{pane_id}" | head -1)
        fi
        
        tmux capture-pane -e -t "$active_pane" -p | head -15
        
        echo -e "\n\033[1;36mRunning processes:\033[0m"
        pane_pid=$(tmux list-panes -t "$active_pane" -F "#{pane_pid}" | head -1)
        if [ -n "$pane_pid" ]; then
            ps --ppid $pane_pid -o pid=,cmd= | head -3 | while read line; do
                echo -e "\033[1;35m$(echo $line | awk '{print $1}')\033[0m \033[1;37m$(echo $line | cut -d" " -f2-)\033[0m"
            done
        fi
    elif echo "$session_name" | grep -q "(tmuxifier)"; then
        session_name=$(echo "$session_name" | awk '{print $1}')
        echo -e "\033[1;36mTmuxifier Session:\033[0m \033[1;33m$session_name\033[0m\n"
        
        local tmuxifier_dir=$(find_tmuxifier)
        if [ -n "$tmuxifier_dir" ]; then
            local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
            if command -v bat >/dev/null 2>&1; then
                bat --color=always --style=plain --line-range=:20 "$layouts_dir/$session_name.session.sh" 2>/dev/null || 
                cat "$layouts_dir/$session_name.session.sh" | head -20
            elif command -v highlight >/dev/null 2>&1; then
                highlight -O ansi "$layouts_dir/$session_name.session.sh" | head -20 2>/dev/null || 
                cat "$layouts_dir/$session_name.session.sh" | head -20
            else
                cat "$layouts_dir/$session_name.session.sh" | head -20
            fi
        else
            echo "Tmuxifier installation not found"
        fi
    elif echo "$session_name" | grep -q "(zoxide)"; then
        path=$(echo "$session_name" | awk '{print $1}')
        echo -e "\033[1;36mZoxide Path:\033[0m \033[1;33m$path\033[0m\n"
        
        if [ -d "$path" ]; then
            echo -e "\033[1;36mDirectory information:\033[0m"
            ls -lah "$path" | head -10
            
            echo -e "\n\033[1;36mRecent git history (if available):\033[0m"
            if [ -d "$path/.git" ]; then
                (cd "$path" && git log --oneline -n 5 2>/dev/null) || echo "No git history available"
            else
                echo "Not a git repository"
            fi
            
            echo -e "\n\033[1;36mREADME (if available):\033[0m"
            readme_file=$(find "$path" -maxdepth 1 -type f -iname "readme*" | head -1)
            if [ -n "$readme_file" ]; then
                cat "$readme_file" | head -10
            else
                echo "No README file found"
            fi
        else
            echo "Directory does not exist or is not accessible"
        fi
    fi
}

generate_window_preview() {
    local session=$1
    local window=$2
    
    local window_index=$(echo "$window" | cut -d':' -f1)
    
    echo -e "\033[1;36mWindow Preview:\033[0m \033[1;33m$window\033[0m\n"
    
    echo -e "\033[1;36mPanes:\033[0m"
    tmux list-panes -t "$session:$window_index" -F "\033[1;32m#P:\033[0m \033[1;37m#{pane_current_command}\033[0m [\033[1;34m#{pane_active?active:}\033[0m]" | sed "s/\[\]//g"
    echo ""
    
    local active_pane=$(tmux list-panes -t "$session:$window_index" -F "#{pane_active} #{pane_id}" | grep "^1" | awk '{print $2}')
    if [ -z "$active_pane" ]; then
        active_pane=$(tmux list-panes -t "$session:$window_index" -F "#{pane_id}" | head -1)
    fi
    
    echo -e "\033[1;36mPane content preview:\033[0m"
    tmux capture-pane -e -t "$active_pane" -p | head -15
    
    echo -e "\n\033[1;36mRunning processes:\033[0m"
    local pane_pid=$(tmux list-panes -t "$active_pane" -F "#{pane_pid}" | head -1)
    if [ -n "$pane_pid" ]; then
        ps --ppid $pane_pid -o pid=,cmd= | head -3 | while read line; do
            echo -e "\033[1;35m$(echo $line | awk '{print $1}')\033[0m \033[1;37m$(echo $line | cut -d" " -f2-)\033[0m"
        done
    fi
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
    fi
}

show_windows() {
    local session=$1
    
    local windows=$(get_session_windows "$session")
    
    if [ -z "$windows" ]; then
        echo "No windows found in session $session." | fzf --header="Error" --reverse
        return 1
    fi
    
    local preview_cmd='
        session="'$session'";
        window=$(echo {} | sed "s/ (active)//");
        window_index=$(echo "$window" | cut -d":" -f1);
        
        echo -e "\033[1;36mWindow Preview:\033[0m \033[1;33m$window\033[0m\n";
        
        echo -e "\033[1;36mPanes:\033[0m";
        tmux list-panes -t "$session:$window_index" -F "\033[1;32m#P:\033[0m \033[1;37m#{pane_current_command}\033[0m [\033[1;34m#{pane_active?active:}\033[0m]" | sed "s/\[\]//g";
        echo "";
        
        active_pane=$(tmux list-panes -t "$session:$window_index" -F "#{pane_active} #{pane_id}" | grep "^1" | awk "{print \$2}");
        if [ -z "$active_pane" ]; then
            active_pane=$(tmux list-panes -t "$session:$window_index" -F "#{pane_id}" | head -1);
        fi;
        
        echo -e "\033[1;36mPane content preview:\033[0m";
        tmux capture-pane -e -t "$active_pane" -p | head -15;
        
        echo -e "\n\033[1;36mRunning processes:\033[0m";
        pane_pid=$(tmux list-panes -t "$active_pane" -F "#{pane_pid}" | head -1);
        if [ -n "$pane_pid" ]; then
            ps --ppid $pane_pid -o pid=,cmd= | head -3 | while read line; do
                echo -e "\033[1;35m$(echo $line | awk "{print \$1}")\033[0m \033[1;37m$(echo $line | cut -d" " -f2-)\033[0m";
            done;
        fi;
    '
    
    local result=$(echo "$windows" | fzf \
        --header="[Enter:Select ?:Help] Windows for $session" \
        --prompt="> " \
        --ansi \
        --expect=? \
        --reverse \
        --height=100% \
        --border=none \
        --preview="$preview_cmd" \
        --preview-window=right:75%:wrap)
    
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
    cat << EOF | fzf --reverse --header "Keyboard Shortcuts" --prompt "Press Escape to return" --border=none --height=100%
Enter       Select session (switch to active, load tmuxifier, or create session from zoxide path)
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
    
    cat << EOF | fzf --reverse --header "Window Shortcuts" --prompt "Press Escape to return" --border=none --height=100%
Enter       Switch to selected window
Escape      Return to sessions
EOF
    show_windows "$session"
}

main() {
    local all_sessions=$(get_all_sessions)
    
    if [ -z "$all_sessions" ]; then
        echo "No tmux, tmuxifier sessions or zoxide paths found." | fzf --header="Error" --reverse
        return 1
    fi
    
    preview_cmd='
        session_name=$(echo {} | awk "{print \$1}");
        if echo {} | grep -q "(active)"; then
            echo -e "\033[1;36mSession:\033[0m \033[1;33m$session_name\033[0m";
            
            active_window=$(tmux list-windows -t "$session_name" -F "#{window_active} #I" | grep "^1" | awk "{print \$2}");
            if [ -z "$active_window" ]; then
                active_window=$(tmux list-windows -t "$session_name" -F "#I" | head -1);
            fi
            
            echo -e "\n\033[1;36mPreview of active window $active_window:\033[0m";

            active_pane=$(tmux list-panes -t "$session_name:$active_window" -F "#{pane_active} #{pane_id}" | grep "^1" | awk "{print \$2}");
            if [ -z "$active_pane" ]; then
                active_pane=$(tmux list-panes -t "$session_name:$active_window" -F "#{pane_id}" | head -1);
            fi
            
            tmux capture-pane -e -t "$active_pane" -p | head -15;
            
            echo "";
            echo -e "\033[1;36mRunning processes:\033[0m";
            pane_pid=$(tmux list-panes -t "$active_pane" -F "#{pane_pid}" | head -1);
            if [ -n "$pane_pid" ]; then
                ps --ppid $pane_pid -o pid=,cmd= | head -3 | while read line; do
                    echo -e "\033[1;35m$(echo $line | awk "{print \$1}")\033[0m \033[1;37m$(echo $line | cut -d" " -f2-)\033[0m";
                done
            fi
        elif echo {} | grep -q "(tmuxifier)"; then
            echo -e "\033[1;36mTmuxifier Session:\033[0m \033[1;33m$session_name\033[0m\n";
            tmuxifier_dir=$(find ~/.tmuxifier ~/.local/share/tmuxifier /usr/local/share/tmuxifier 2>/dev/null | head -1);
            if [ -n "$tmuxifier_dir" ]; then
                layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}";
                if command -v bat >/dev/null 2>&1; then
                    bat --color=always --style=plain --line-range=:20 "$layouts_dir/$session_name.session.sh" 2>/dev/null || 
                    cat "$layouts_dir/$session_name.session.sh" | head -20;
                elif command -v highlight >/dev/null 2>&1; then
                    highlight -O ansi "$layouts_dir/$session_name.session.sh" | head -20 2>/dev/null || 
                    cat "$layouts_dir/$session_name.session.sh" | head -20;
                else
                    cat "$layouts_dir/$session_name.session.sh" | head -20;
                fi
            else
                echo "Tmuxifier installation not found";
            fi
        elif echo {} | grep -q "(zoxide)"; then
            path=$(echo {} | awk "{print \$1}");
            echo -e "\033[1;36mZoxide Path:\033[0m \033[1;33m$path\033[0m\n";
            
            if [ -d "$path" ]; then
                echo -e "\033[1;36mDirectory information:\033[0m";
                ls -lah "$path" | head -10;
                
                echo -e "\n\033[1;36mRecent git history (if available):\033[0m";
                if [ -d "$path/.git" ]; then
                    (cd "$path" && git log --oneline -n 5 2>/dev/null) || echo "No git history available";
                else
                    echo "Not a git repository";
                fi
                
                echo -e "\n\033[1;36mREADME (if available):\033[0m";
                readme_file=$(find "$path" -maxdepth 1 -type f -iname "readme*" | head -1);
                if [ -n "$readme_file" ]; then
                    cat "$readme_file" | head -10;
                else
                    echo "No README file found";
                fi
            else
                echo "Directory does not exist or is not accessible";
            fi
        fi
    '
    
    local result=$(echo "$all_sessions" | fzf \
        --header="Enter:Select / ctrl-r:Rename / ctrl-e:Edit / ctrl-t:Terminate / ctrl-d:Delete / ctrl-w:Windows / ctrl-f:Filter / ?:Help" \
        --prompt="> " \
        --ansi \
        --expect=ctrl-r,ctrl-e,ctrl-t,ctrl-d,ctrl-w,ctrl-f,? \
        --reverse \
        --height=100% \
        --border=none \
        --preview="$preview_cmd" \
        --preview-window=bottom:60%)
    
    local key=$(echo "$result" | head -1)
    local selection=$(echo "$result" | tail -1)
    
    if [ -z "$selection" ]; then
        return 0
    fi
    
    case "$key" in
        "ctrl-r")
            local session_name=$(echo "$selection" | awk '{print $1}')
            if echo "$selection" | grep -q "(active)"; then
                rename_tmux_session "$session_name"
            elif echo "$selection" | grep -q "(tmuxifier)"; then
                rename_tmuxifier_session "$session_name"
            elif echo "$selection" | grep -q "(zoxide)"; then
                tmux display-message "Cannot rename zoxide paths"
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
        "?")
            show_help
        ;;
        *)
            handle_session "$selection"
        ;;
    esac
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
