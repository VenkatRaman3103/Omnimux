#!/bin/bash

ACTIVE_BG="#444444"
ACTIVE_FG="#ffffff"
INACTIVE_BG="#222222"
INACTIVE_FG="#777777"

SELECTED_TAB=1

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

draw_tabs() {
    local selected=$1

    clear

    if [ "$selected" -eq 1 ]; then
        tab1="\033[48;5;8m\033[38;5;15m 1:Load \033[0m"
    else
        tab1="\033[48;5;235m\033[38;5;244m 1:Load \033[0m"
    fi

    if [ "$selected" -eq 2 ]; then
        tab2="\033[48;5;8m\033[38;5;15m 2:Edit \033[0m"
    else
        tab2="\033[48;5;235m\033[38;5;244m 2:Edit \033[0m"
    fi

    if [ "$selected" -eq 3 ]; then
        tab3="\033[48;5;8m\033[38;5;15m 3:Delete \033[0m"
    else
        tab3="\033[48;5;235m\033[38;5;244m 3:Delete \033[0m"
    fi

    local tabs_line="$tab1 $tab2 $tab3"

    local visible_length=$(echo -e "$tabs_line" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)
    visible_length=$((visible_length - 1))

    local terminal_width=$(tput cols)
    local padding=$(( (terminal_width - visible_length) / 2 ))

    printf "%*s" "$padding" ""
    echo -e "$tabs_line"
    echo
}

get_tmuxifier_sessions() {
    local tmuxifier_dir=$(find_tmuxifier)
    
    if [ -n "$tmuxifier_dir" ]; then
        local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
        
        if [ -d "$layouts_dir" ]; then
            find "$layouts_dir" -name "*.session.sh" -exec basename {} \; | sed 's/\.session\.sh$//'
        else
            echo "No tmuxifier layouts found."
            exit 1
        fi
    else
        echo "tmuxifier not found. Please install it first."
        exit 1
    fi
}

load_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)
    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local session_file="$layouts_dir/$session.session.sh"
    
    tmux display-message "Loading tmuxifier session: $session"
    
    if [ -f "$session_file" ]; then
        local temp_script=$(mktemp)
        cat > "$temp_script" << EOF
#!/bin/bash
export TMUXIFIER="$tmuxifier_dir"
export PATH="\$TMUXIFIER/bin:\$PATH"
export TMUXIFIER_LAYOUT_PATH="$layouts_dir"

# Source tmuxifier
if [ -f "\$TMUXIFIER/init.sh" ]; then
    source "\$TMUXIFIER/init.sh"
fi

if tmux has-session -t "$session" 2>/dev/null; then
    tmux switch-client -t "$session"
else
    if command -v tmuxifier >/dev/null 2>&1; then
        tmuxifier load-session "$session"
    else
        source "$session_file"
    fi
fi
EOF
        
        chmod +x "$temp_script"
        
        tmux detach-client -E "$temp_script"
        rm -f "$temp_script"
    else
        tmux display-message "Error: Session file not found at $session_file"
    fi
}

edit_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)
    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local session_file="$layouts_dir/$session.session.sh"
    local editor="${EDITOR:-vim}"
    
    if [ -f "$session_file" ]; then
        tmux new-window "$editor $session_file"
    else
        tmux display-message "Error: Session file not found at $session_file"
    fi
}

delete_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)
    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local session_file="$layouts_dir/$session.session.sh"
    
    if [ -f "$session_file" ]; then
        read -p "Are you sure you want to delete $session? (y/n): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            rm "$session_file"
            tmux display-message "Deleted tmuxifier session: $session"
        else
            tmux display-message "Deletion cancelled"
        fi
    else
        tmux display-message "Error: Session file not found at $session_file"
    fi
}

main() {
    tab=$SELECTED_TAB
    
    draw_tabs $tab
    
    while true; do
        
        result=$(get_tmuxifier_sessions | fzf \
            --header "$header" \
            --height 90% \
            --expect=1,2,3)
        
        key=$(echo "$result" | head -1)
        selection=$(echo "$result" | tail -1)
        
        if [ -n "$key" ] && [ "$key" != "$selection" ]; then
            case $key in
                1) tab=1 ;;
                2) tab=2 ;;
                3) tab=3 ;;
            esac
            draw_tabs $tab
            continue
        fi
        
        if [ -n "$selection" ]; then
            case $tab in
                1) load_session "$selection" ;;
                2) edit_session "$selection" ;;
                3) delete_session "$selection" ;;
            esac
            break
        else
            break
        fi
    done
}

main

