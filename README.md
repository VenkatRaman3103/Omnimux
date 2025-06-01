# Termonaut 🚀

A powerful, interactive tmux session manager that brings together tmux, tmuxifier, zoxide, and fzf for a seamless terminal workflow experience.

## Features ✨

- **Unified Session Management**: Browse and switch between active tmux sessions, tmuxifier layouts, zoxide paths, and find results in one interface
- **Interactive Preview**: Real-time preview of session content, running processes, directory contents, and git status
- **Smart Path Integration**: Automatically create sessions from frequently visited directories (zoxide) or discovered paths (find)
- **Window Management**: Navigate, rename, create, and delete windows within sessions
- **Tmuxifier Integration**: Load, edit, rename, and manage tmuxifier session layouts
- **Highly Customizable**: Extensive configuration options for colors, layout, and behavior
- **Keyboard-Driven**: Fast navigation with intuitive keyboard shortcuts

## Prerequisites 📋

### Required

- **tmux** - Terminal multiplexer
- **fzf** - Fuzzy finder for interactive selection

### Optional (Recommended)

- **tmuxifier** - Tmux session layouts manager
- **zoxide** - Smart directory jumper
- **bat** or **highlight** - Syntax highlighting for session file previews

## Installation 🔧

### Option 1: TPM (Recommended)

If you're using [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm):

1. **Add to your `~/.tmux.conf`:**

   ```bash
   set -g @plugin 'VenkatRaman3103/Termonaut_Across_the_Tmux_Verse'
   ```

2. **Install the plugin:**
   Press `prefix + I` (default: `Ctrl-b + I`) to install the plugin via TPM.

3. **Reload tmux configuration:**
   ```bash
   tmux source-file ~/.tmux.conf
   ```

The default key binding `J` will be automatically configured.

### Option 2: Manual Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/VenkatRaman3103/Termonaut_Across_the_Tmux_Verse.git ~/.tmux/plugins/termonaut
   ```

2. **Add to your `~/.tmux.conf`:**

   ```bash
   # Source termonaut plugin
   run-shell ~/.tmux/plugins/termonaut/termonaut.tmux
   ```

3. **Reload tmux configuration:**
   ```bash
   tmux source-file ~/.tmux.conf
   ```

### Option 3: Standalone Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/VenkatRaman3103/Termonaut_Across_the_Tmux_Verse.git
   cd Termonaut_Across_the_Tmux_Verse
   ```

2. **Make the script executable:**

   ```bash
   chmod +x termonaut.sh
   ```

3. **Add to your PATH (optional):**

   ```bash
   # Add to your ~/.bashrc or ~/.zshrc
   export PATH="$PATH:/path/to/Termonaut_Across_the_Tmux_Verse"
   ```

4. **Set up tmux key binding manually:**
   ```bash
   # Add to your ~/.tmux.conf
   bind-key J run-shell 'path/to/termonaut.sh'
   ```

## Usage 🎯

### Basic Usage

**Default Key Binding**: Press `J` from within any tmux session to launch Termonaut.

You can also run the script directly:

```bash
./termonaut.sh
```

### Keyboard Shortcuts

#### Main Interface

| Key      | Action                              |
| -------- | ----------------------------------- |
| `Enter`  | Select session (switch/load/create) |
| `Ctrl+R` | Rename selected session             |
| `Ctrl+E` | Edit tmuxifier session file         |
| `Ctrl+T` | Terminate active tmux session       |
| `Ctrl+D` | Delete tmuxifier session file       |
| `Ctrl+W` | Show windows in selected session    |
| `Ctrl+N` | Create new session                  |
| `Ctrl+P` | Toggle preview mode                 |
| `Ctrl+F` | Filter/search sessions              |
| `?`      | Show help menu                      |
| `Escape` | Exit                                |

#### Window Management

| Key      | Action                    |
| -------- | ------------------------- |
| `Enter`  | Switch to selected window |
| `Ctrl+R` | Rename selected window    |
| `Ctrl+D` | Delete selected window    |
| `Ctrl+N` | Create new window         |
| `Escape` | Return to sessions        |

## Configuration ⚙️

Termonaut is highly customizable through tmux options. Set these in your `~/.tmux.conf`:

### Key Binding & Display Options

```bash
# Change the default key binding (default: "J")
set -g @termonaut-key "s"

# Display mode: popup (default) or window
set -g @termonaut-display-mode "popup"

# Popup dimensions (only applies to popup mode)
set -g @termonaut-window-width "100%"
set -g @termonaut-window-height "100%"

# Popup border colors
set -g @termonaut-border-fg "#0c0c0c"
set -g @termonaut-border-bg "#0c0c0c"
```

### Colors & Appearance

```bash
# Color scheme
set -g @termonaut-active-bg "#444444"
set -g @termonaut-active-fg "#ffffff"
set -g @termonaut-inactive-bg "#222222"
set -g @termonaut-inactive-fg "#777777"
set -g @termonaut-active-color "\033[38;5;39m"
set -g @termonaut-tmuxifier-color "\033[38;5;39m"
set -g @termonaut-tmux-color "\033[38;5;39m"
set -g @termonaut-zoxide-color "\033[38;5;208m"
set -g @termonaut-find-color "\033[38;5;118m"
```

### FZF Configuration

```bash
# FZF appearance
set -g @termonaut-fzf-height "100%"
set -g @termonaut-fzf-border "none"
set -g @termonaut-fzf-layout "no-reverse"
set -g @termonaut-fzf-prompt "> "
set -g @termonaut-fzf-pointer "▶"

# Preview settings
set -g @termonaut-preview-enabled "true"
set -g @termonaut-fzf-preview-position "bottom:60%"
set -g @termonaut-fzf-preview-window-position "right:75%"
```

### Path & Search Settings

```bash
# Directory discovery
set -g @termonaut-find-base-dir "$HOME"
set -g @termonaut-find-max-depth "3"
set -g @termonaut-find-min-depth "1"
set -g @termonaut-max-zoxide-paths "20"
set -g @termonaut-max-find-paths "15"

# Display settings
set -g @termonaut-ls-command "ls -la"
set -g @termonaut-show-process-count "3"
set -g @termonaut-show-preview-lines "15"
set -g @termonaut-show-ls-lines "20"
set -g @termonaut-show-git-status-lines "10"

# Editor for tmuxifier files
set -g @termonaut-editor "vim"
```

### Complete Configuration Example

```bash
# ~/.tmux.conf

# Install termonaut via TPM
set -g @plugin 'VenkatRaman3103/Termonaut_Across_the_Tmux_Verse'

# Termonaut key binding (default is "J", change if desired)
set -g @termonaut-key "s"

# Display as popup (default) or window
set -g @termonaut-display-mode "popup"

# Termonaut configuration
set -g @termonaut-preview-enabled "true"
set -g @termonaut-fzf-height "100%"
set -g @termonaut-fzf-border "rounded"
set -g @termonaut-active-bg "#2d3748"
set -g @termonaut-active-fg "#e2e8f0"
set -g @termonaut-tmuxifier-color "\033[38;5;75m"
set -g @termonaut-zoxide-color "\033[38;5;215m"
set -g @termonaut-find-color "\033[38;5;156m"
set -g @termonaut-max-zoxide-paths "25"
set -g @termonaut-editor "nvim"
```

## Display Modes 🖥️

Termonaut supports two display modes:

### Popup Mode (Default)

- Opens Termonaut in a tmux popup overlay
- Non-intrusive and quick to access
- Customizable size and border colors
- Perfect for quick session switching

### Window Mode

- Opens Termonaut in a new tmux window
- Provides more space for complex operations
- Useful when working with many sessions
- Can be easily navigated back to

```bash
# Switch to window mode
set -g @termonaut-display-mode "window"
```

## How It Works 🔍

Termonaut aggregates different sources of sessions and paths:

1. **Active Tmux Sessions** - Currently running tmux sessions
2. **Tmuxifier Layouts** - Predefined session templates (filtered to exclude active ones)
3. **Zoxide Paths** - Frequently visited directories from your zoxide database
4. **Find Results** - Directories discovered through filesystem search

Each source is color-coded and labeled for easy identification. The preview pane shows relevant information like session content, directory listings, git status, and running processes.

## Integration Examples 🔗

### Basic Setup with TPM

```bash
# ~/.tmux.conf

# Install termonaut via TPM
set -g @plugin 'VenkatRaman3103/Termonaut_Across_the_Tmux_Verse'

# Optional: customize the key binding (default is "J")
set -g @termonaut-key "s"

# Optional: change display mode (default is "popup")
set -g @termonaut-display-mode "window"
```

### With Tmuxifier

Create session layouts in `~/.tmuxifier/layouts/`:

```bash
# ~/.tmuxifier/layouts/project.session.sh
session_name "myproject"
new_window "editor"
new_window "server"
new_window "logs"
```

### With Zoxide

Your frequently visited directories automatically appear:

```bash
# Visit directories to build zoxide database
z ~/projects/awesome-app
z ~/dotfiles
z ~/documents/notes
```

### Advanced tmux.conf Integration

```bash
# Custom key binding with modifier
set -g @termonaut-key "C-Space"

# Window mode for more screen real estate
set -g @termonaut-display-mode "window"

# Custom popup dimensions
set -g @termonaut-window-width "90%"
set -g @termonaut-window-height "80%"

# Custom border styling
set -g @termonaut-border-fg "#ff6b6b"
set -g @termonaut-border-bg "#2d3748"
```

## Troubleshooting 🔧

### Common Issues

**"This script must be run inside a tmux session"**

- Ensure you're running the script from within an active tmux session

**"fzf is not installed"**

- Install fzf: `brew install fzf` (macOS) or `apt install fzf` (Ubuntu)

**Key binding "J" not working**

- Make sure you've installed the plugin via TPM (`prefix + I`) or sourced the termonaut.tmux file manually
- Try reloading tmux config: `tmux source-file ~/.tmux.conf` or restart tmux
- Check if "J" conflicts with other bindings

**Preview not working**

- Check that preview is enabled: `tmux show-option -g @termonaut-preview-enabled`
- Ensure required commands are available (ls, ps, git)

**Tmuxifier sessions not appearing**

- Verify tmuxifier installation and layout directory
- Check `TMUXIFIER_LAYOUT_PATH` environment variable

**Zoxide paths not showing**

- Install zoxide and ensure it's in your PATH
- Build the zoxide database by visiting directories with `z`

### Debug Mode

To troubleshoot issues, you can add debug output:

```bash
# Temporarily add to the script
set -x  # Enable debug mode
# ... rest of script
set +x  # Disable debug mode
```

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly in different tmux environments
5. Submit a pull request

## License 📝

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- **tmux** - The amazing terminal multiplexer
- **fzf** - Fantastic fuzzy finder that makes this tool possible
- **tmuxifier** - Excellent tmux session management
- **zoxide** - Smart directory navigation
- The tmux and terminal communities for inspiration

---

**Happy terminal navigation! 🚀**
