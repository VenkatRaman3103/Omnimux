#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

default_key_binding="J"
key_binding=$(tmux show-option -gqv @termonaut-key)
key_binding=${key_binding:-$default_key_binding}

tmux bind-key "$key_binding" run-shell "$CURRENT_DIR/script.sh"
