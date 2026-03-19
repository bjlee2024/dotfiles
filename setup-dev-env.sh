#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Dev Environment Setup Script
# Installs and configures: kitty, tmux + oh-my-tmux, yazi, starship
# Supports: macOS (Homebrew) / Linux (apt + Homebrew)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# --- OS Detection ---
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux)  OS="linux" ;;
        *)      error "Unsupported OS: $(uname -s)" ;;
    esac
    info "Detected OS: $OS"
}

# --- Homebrew ---
ensure_homebrew() {
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [[ "$OS" == "linux" ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [[ "$OS" == "macos" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
        fi
    fi
    ok "Homebrew ready"
}

# --- Font: JetBrainsMono Nerd Font ---
install_font() {
    info "Installing JetBrainsMono Nerd Font..."
    if [[ "$OS" == "macos" ]]; then
        brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || true
    else
        local font_dir="$HOME/.local/share/fonts"
        if ! ls "$font_dir"/JetBrainsMono* &>/dev/null 2>&1; then
            mkdir -p "$font_dir"
            local tmp_dir
            tmp_dir=$(mktemp -d)
            curl -fsSL -o "$tmp_dir/jbmono.zip" \
                "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
            unzip -qo "$tmp_dir/jbmono.zip" -d "$font_dir"
            fc-cache -fv "$font_dir" >/dev/null 2>&1
            rm -rf "$tmp_dir"
        fi
    fi
    ok "JetBrainsMono Nerd Font installed"
}

# =============================================================================
# 1. Kitty
# =============================================================================
install_kitty() {
    info "Installing kitty..."
    if [[ "$OS" == "macos" ]]; then
        brew install --cask kitty 2>/dev/null || true
    else
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
        mkdir -p "$HOME/.local/bin"
        ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
        ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"
    fi
    ok "kitty installed"
}

configure_kitty() {
    info "Configuring kitty..."
    local kitty_dir="$HOME/.config/kitty"
    mkdir -p "$kitty_dir"

    # --- kitty.conf ---
    cat > "$kitty_dir/kitty.conf" << 'KITTY_CONF'
# vim:fileencoding=utf-8:foldmethod=marker

#: Fonts {{{
font_family      JetBrainsMono Nerd Font Mono
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size 14.0
force_ltr no
adjust_line_height  0
adjust_column_width 0
adjust_baseline 0
disable_ligatures always
#: }}}

#: Mouse {{{
copy_on_select yes
#: }}}

#: Advanced {{{
allow_remote_control yes
#: }}}

#: Color scheme {{{
background_opacity 0.90
#: }}}

cursor_trail 1

# KEYMAP
include keymap.conf

# BEGIN_KITTY_THEME
# Catppuccin Kitty Macchiato
include current-theme.conf
# END_KITTY_THEME
KITTY_CONF

    # --- keymap.conf ---
    cat > "$kitty_dir/keymap.conf" << 'KEYMAP_CONF'

map kitty_mod+h neighboring_window left
map kitty_mod+j neighboring_window bottom
map kitty_mod+k neighboring_window top
map kitty_mod+l neighboring_window right

enabled_layouts splits, stack
map kitty_mod+9 launch --location=hsplit
map kitty_mod+0 launch --location=vsplit

map kitty_mod+] next_tab
map kitty_mod+[ previous_tab
map kitty_mod+w close_tab

macos_option_as_alt yes

map alt+h send_text all \x1bh
map alt+j send_text all \x1bj
map alt+k send_text all \x1bk
map alt+l send_text all \x1bl
KEYMAP_CONF

    # --- current-theme.conf (Catppuccin Macchiato) ---
    cat > "$kitty_dir/current-theme.conf" << 'THEME_CONF'
# vim:ft=kitty

## name:     Catppuccin Kitty Macchiato
## author:   Catppuccin Org
## license:  MIT
## upstream: https://github.com/catppuccin/kitty/blob/main/macchiato.conf

# The basic colors
foreground              #CAD3F5
background              #24273A
selection_foreground    #24273A
selection_background    #F4DBD6

# Cursor colors
cursor                  #F4DBD6
cursor_text_color       #24273A

# URL underline color when hovering with mouse
url_color               #F4DBD6

# Kitty window border colors
active_border_color     #B7BDF8
inactive_border_color   #6E738D
bell_border_color       #EED49F

# OS Window titlebar colors
wayland_titlebar_color system
macos_titlebar_color system

# Tab bar colors
active_tab_foreground   #181926
active_tab_background   #C6A0F6
inactive_tab_foreground #CAD3F5
inactive_tab_background #1E2030
tab_bar_background      #181926

# Colors for marks
mark1_foreground #24273A
mark1_background #B7BDF8
mark2_foreground #24273A
mark2_background #C6A0F6
mark3_foreground #24273A
mark3_background #7DC4E4

# The 16 terminal colors
# black
color0 #494D64
color8 #5B6078
# red
color1 #ED8796
color9 #ED8796
# green
color2  #A6DA95
color10 #A6DA95
# yellow
color3  #EED49F
color11 #EED49F
# blue
color4  #8AADF4
color12 #8AADF4
# magenta
color5  #F5BDE6
color13 #F5BDE6
# cyan
color6  #8BD5CA
color14 #8BD5CA
# white
color7  #B8C0E0
color15 #A5ADCB
THEME_CONF

    ok "kitty configured"
}

# =============================================================================
# 2. tmux + oh-my-tmux
# =============================================================================
install_tmux() {
    info "Installing tmux..."
    brew install tmux 2>/dev/null || true
    ok "tmux installed"
}

configure_tmux() {
    info "Configuring oh-my-tmux..."
    local tmux_dir="$HOME/.config/tmux"

    # Clone oh-my-tmux if not present
    if [[ ! -f "$tmux_dir/tmux.conf" ]] || ! grep -q "gpakosz" "$tmux_dir/tmux.conf" 2>/dev/null; then
        # Backup existing config
        if [[ -d "$tmux_dir" ]]; then
            mv "$tmux_dir" "${tmux_dir}.bak.$(date +%s)"
        fi
        git clone https://github.com/gpakosz/.tmux.git "$tmux_dir"
    fi
    ok "oh-my-tmux cloned"

    # --- tmux.conf.local ---
    cat > "$tmux_dir/tmux.conf.local" << 'TMUX_LOCAL'
# : << EOF
# https://github.com/gpakosz/.tmux
# (‑●‑●)> dual licensed under the WTFPL v2 license and the MIT license,
#         without any warranty.
#         Copyright 2012— Gregory Pakosz (@gpakosz).

# -- bindings ------------------------------------------------------------------
tmux_conf_preserve_stock_bindings=false

# -- session creation ----------------------------------------------------------
tmux_conf_new_session_prompt=false
tmux_conf_new_session_retain_current_path=false

# -- windows & pane creation ---------------------------------------------------
tmux_conf_new_window_retain_current_path=false
tmux_conf_new_window_reconnect_ssh=false
tmux_conf_new_pane_retain_current_path=true
tmux_conf_new_pane_reconnect_ssh=false

# -- display -------------------------------------------------------------------
tmux_conf_24b_colour=auto

# -- theming -------------------------------------------------------------------
tmux_conf_theme=disabled

tmux_conf_theme_colour_1="#080808"
tmux_conf_theme_colour_2="#303030"
tmux_conf_theme_colour_3="#8a8a8a"
tmux_conf_theme_colour_4="#00afff"
tmux_conf_theme_colour_5="#ffff00"
tmux_conf_theme_colour_6="#080808"
tmux_conf_theme_colour_7="#e4e4e4"
tmux_conf_theme_colour_8="#080808"
tmux_conf_theme_colour_9="#ffff00"
tmux_conf_theme_colour_10="#ff00af"
tmux_conf_theme_colour_11="#5fff00"
tmux_conf_theme_colour_12="#8a8a8a"
tmux_conf_theme_colour_13="#e4e4e4"
tmux_conf_theme_colour_14="#080808"
tmux_conf_theme_colour_15="#080808"
tmux_conf_theme_colour_16="#d70000"
tmux_conf_theme_colour_17="#e4e4e4"

tmux_conf_theme_window_fg="default"
tmux_conf_theme_window_bg="default"
tmux_conf_theme_highlight_focused_pane=false
tmux_conf_theme_focused_pane_bg="$tmux_conf_theme_colour_2"
tmux_conf_theme_pane_border_style=thin
tmux_conf_theme_pane_border="$tmux_conf_theme_colour_2"
tmux_conf_theme_pane_active_border="$tmux_conf_theme_colour_4"
%if #{>=:#{version},3.2}
tmux_conf_theme_pane_active_border="#{?pane_in_mode,$tmux_conf_theme_colour_9,#{?synchronize-panes,$tmux_conf_theme_colour_16,$tmux_conf_theme_colour_4}}"
%endif
tmux_conf_theme_pane_indicator="$tmux_conf_theme_colour_4"
tmux_conf_theme_pane_active_indicator="$tmux_conf_theme_colour_4"

tmux_conf_theme_message_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_message_bg="$tmux_conf_theme_colour_5"
tmux_conf_theme_message_attr="bold"
tmux_conf_theme_message_command_fg="$tmux_conf_theme_colour_5"
tmux_conf_theme_message_command_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_message_command_attr="bold"
tmux_conf_theme_mode_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_mode_bg="$tmux_conf_theme_colour_5"
tmux_conf_theme_mode_attr="bold"
tmux_conf_theme_status_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_status_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_status_attr="none"
tmux_conf_theme_terminal_title="#h ❐ #S ● #I #W"

tmux_conf_theme_window_status_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_window_status_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_window_status_attr="none"
tmux_conf_theme_window_status_format="#I #W#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,}"
tmux_conf_theme_window_status_current_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_window_status_current_bg="$tmux_conf_theme_colour_4"
tmux_conf_theme_window_status_current_attr="bold"
tmux_conf_theme_window_status_current_format="#I #W#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,}"
tmux_conf_theme_window_status_activity_fg="default"
tmux_conf_theme_window_status_activity_bg="default"
tmux_conf_theme_window_status_activity_attr="underscore"
tmux_conf_theme_window_status_bell_fg="$tmux_conf_theme_colour_5"
tmux_conf_theme_window_status_bell_bg="default"
tmux_conf_theme_window_status_bell_attr="blink,bold"
tmux_conf_theme_window_status_last_fg="$tmux_conf_theme_colour_4"
tmux_conf_theme_window_status_last_bg="$tmux_conf_theme_colour_2"
tmux_conf_theme_window_status_last_attr="none"

tmux_conf_theme_left_separator_main=""
tmux_conf_theme_left_separator_sub="|"
tmux_conf_theme_right_separator_main=""
tmux_conf_theme_right_separator_sub="|"

tmux_conf_theme_status_left=" ❐ #S | ↑#{?uptime_y, #{uptime_y}y,}#{?uptime_d, #{uptime_d}d,}#{?uptime_h, #{uptime_h}h,}#{?uptime_m, #{uptime_m}m,} "
tmux_conf_theme_status_right=" #{prefix}#{mouse}#{pairing}#{synchronized}#{?battery_status,#{battery_status},}#{?battery_bar, #{battery_bar},}#{?battery_percentage, #{battery_percentage},} , %R , %d %b | #{username}#{root} | #{hostname} "

tmux_conf_theme_status_left_fg="$tmux_conf_theme_colour_6,$tmux_conf_theme_colour_7,$tmux_conf_theme_colour_8"
tmux_conf_theme_status_left_bg="$tmux_conf_theme_colour_9,$tmux_conf_theme_colour_10,$tmux_conf_theme_colour_11"
tmux_conf_theme_status_left_attr="bold,none,none"
tmux_conf_theme_status_right_fg="$tmux_conf_theme_colour_12,$tmux_conf_theme_colour_13,$tmux_conf_theme_colour_14"
tmux_conf_theme_status_right_bg="$tmux_conf_theme_colour_15,$tmux_conf_theme_colour_16,$tmux_conf_theme_colour_17"
tmux_conf_theme_status_right_attr="none,none,bold"

tmux_conf_theme_pairing="⚇"
tmux_conf_theme_pairing_fg="none"
tmux_conf_theme_pairing_bg="none"
tmux_conf_theme_pairing_attr="none"
tmux_conf_theme_prefix="⌨"
tmux_conf_theme_prefix_fg="none"
tmux_conf_theme_prefix_bg="none"
tmux_conf_theme_prefix_attr="none"
tmux_conf_theme_mouse="↗"
tmux_conf_theme_mouse_fg="none"
tmux_conf_theme_mouse_bg="none"
tmux_conf_theme_mouse_attr="none"
tmux_conf_theme_root="!"
tmux_conf_theme_root_fg="none"
tmux_conf_theme_root_bg="none"
tmux_conf_theme_root_attr="bold,blink"
tmux_conf_theme_synchronized="⚏"
tmux_conf_theme_synchronized_fg="none"
tmux_conf_theme_synchronized_bg="none"
tmux_conf_theme_synchronized_attr="none"

tmux_conf_battery_bar_symbol_full="◼"
tmux_conf_battery_bar_symbol_empty="◻"
tmux_conf_battery_bar_length="auto"
tmux_conf_battery_bar_palette="gradient"
tmux_conf_battery_hbar_palette="gradient"
tmux_conf_battery_vbar_palette="gradient"
tmux_conf_battery_status_charging="↑"
tmux_conf_battery_status_discharging="↓"

tmux_conf_theme_clock_colour="$tmux_conf_theme_colour_4"
tmux_conf_theme_clock_style="24"

# -- clipboard -----------------------------------------------------------------
tmux_conf_copy_to_os_clipboard=true

# -- urlscan -------------------------------------------------------------------
tmux_conf_urlscan_options="--compact --dedupe"

# -- user customizations -------------------------------------------------------
set -g mouse on
set -g set-clipboard on

# -- tpm -----------------------------------------------------------------------
tmux_conf_update_plugins_on_launch=true
tmux_conf_update_plugins_on_reload=true
tmux_conf_uninstall_plugins_on_reload=true

# catppuccin theme
set -g @plugin 'catppuccin/tmux#v2.1.1'
set -g @catppuccin_flavor 'macchiato'
set -g @catppuccin_window_status_style "rounded"
run ~/.config/tmux/plugins/tmux/catppuccin.tmux
set -g status-right-length 100
set -g status-left-length 100
set -g status-left "#{E:@catppuccin_status_session}"
set -g status-right "#{E:@catppuccin_status_application}"
set -ag status-right "#{E:@catppuccin_status_session}"
set -ag status-right "#{E:@catppuccin_status_uptime}"

# tmux nerd font window name plugin
set -g @plugin 'joshmedeski/tmux-nerd-font-window-name'

# tmux session manager plugin
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-boot-options 'kitty'

# tmux-yank
set -g @plugin 'tmux-plugins/tmux-yank'

set -s set-clipboard external

# # /!\ do not remove the following line
# EOF
#
# "$@"
# # /!\ do not remove the previous line
# #     do not write below this line

# short waittime after prefix
set-option repeat-time 100

# display pane IDs until you select a pane
bind -T prefix n display-panes -d 0

bind-key x kill-pane
set -g detach-on-destroy off

# sesh + fzf
bind-key "T" run-shell "sesh connect \"$(
  sesh list --icons | fzf-tmux -p 55%,60% \
    --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
    --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
)\""
TMUX_LOCAL

    # Install tmux plugins (TPM handles it on first launch, but install catppuccin manually)
    local plugins_dir="$tmux_dir/plugins"
    mkdir -p "$plugins_dir"

    if [[ ! -d "$plugins_dir/tmux" ]]; then
        info "Installing catppuccin/tmux plugin..."
        git clone --depth 1 --branch v2.1.1 https://github.com/catppuccin/tmux.git "$plugins_dir/tmux"
    fi

    ok "tmux + oh-my-tmux configured"
}

# =============================================================================
# 3. Yazi
# =============================================================================
install_yazi() {
    info "Installing yazi..."
    brew install yazi ffmpegthumbnailer poppler fd ripgrep fzf zoxide glow 2>/dev/null || true
    ok "yazi installed"
}

configure_yazi() {
    info "Configuring yazi..."
    local yazi_dir="$HOME/.config/yazi"
    mkdir -p "$yazi_dir"

    # --- yazi.toml ---
    cat > "$yazi_dir/yazi.toml" << 'YAZI_TOML'
[mgr]
show_hidden = true

[[plugin.prepend_previewers]]
name = "*.md"
run  = 'piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'

[[plugin.prepend_fetchers]]
id   = "git"
name = "*"
run  = "git"

[[plugin.prepend_fetchers]]
id   = "git"
name = "*/"
run  = "git"
YAZI_TOML

    # --- theme.toml ---
    cat > "$yazi_dir/theme.toml" << 'THEME_TOML'
[flavor]
use = "catppuccin-macchiato"
dark = "catppuccin-macchiato"
THEME_TOML

    # --- init.lua ---
    cat > "$yazi_dir/init.lua" << 'INIT_LUA'
require("git"):setup()
INIT_LUA

    # --- package.toml ---
    cat > "$yazi_dir/package.toml" << 'PKG_TOML'
[[plugin.deps]]
use = "yazi-rs/plugins:piper"

[[plugin.deps]]
use = "yazi-rs/plugins:git"

[[flavor.deps]]
use = "yazi-rs/flavors:catppuccin-macchiato"
PKG_TOML

    # Install yazi plugins and flavors
    if command -v ya &>/dev/null; then
        info "Installing yazi packages..."
        ya pack -i 2>/dev/null || true
    fi

    ok "yazi configured"
}

# =============================================================================
# 4. LazyVim (Neovim)
# =============================================================================
install_neovim() {
    info "Installing neovim..."
    brew install neovim 2>/dev/null || true
    ok "neovim installed"
}

configure_lazyvim() {
    info "Configuring LazyVim..."
    local nvim_dir="$HOME/.config/nvim"

    # Backup existing config
    if [[ -d "$nvim_dir" ]] && ! grep -q "LazyVim" "$nvim_dir/init.lua" 2>/dev/null; then
        mv "$nvim_dir" "${nvim_dir}.bak.$(date +%s)"
    fi
    mkdir -p "$nvim_dir/lua/config" "$nvim_dir/lua/plugins"

    # --- init.lua ---
    cat > "$nvim_dir/init.lua" << 'INIT_LUA'
-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
INIT_LUA

    # --- lazyvim.json ---
    cat > "$nvim_dir/lazyvim.json" << 'LAZYVIM_JSON'
{
  "extras": [
    "lazyvim.plugins.extras.lang.go",
    "lazyvim.plugins.extras.lang.java",
    "lazyvim.plugins.extras.lang.json",
    "lazyvim.plugins.extras.lang.markdown",
    "lazyvim.plugins.extras.util.mini-hipatterns"
  ],
  "install_version": 7,
  "news": {},
  "version": 8
}
LAZYVIM_JSON

    # --- lua/config/lazy.lua ---
    cat > "$nvim_dir/lua/config/lazy.lua" << 'LAZY_LUA'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" if not (vim.uv or vim.loop).fs_stat(lazypath) then local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		{ import = "lazyvim.plugins.extras.lang.markdown" },
		{ import = "plugins" },
	},
	defaults = {
		lazy = false,
		version = false,
	},
	install = { colorscheme = { "catppuccin-macchiato" } },
	checker = {
		enabled = true,
		notify = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
LAZY_LUA

    # --- lua/config/options.lua ---
    cat > "$nvim_dir/lua/config/options.lua" << 'OPTIONS_LUA'
-- Options are automatically loaded before lazy.nvim startup
vim.g.autoformat = false
vim.opt.relativenumber = false
vim.opt.spell = false
OPTIONS_LUA

    # --- lua/config/keymaps.lua ---
    cat > "$nvim_dir/lua/config/keymaps.lua" << 'KEYMAPS_LUA'
-- Keymaps are automatically loaded on the VeryLazy event
-- Add any additional keymaps here
KEYMAPS_LUA

    # --- lua/config/autocmds.lua ---
    cat > "$nvim_dir/lua/config/autocmds.lua" << 'AUTOCMDS_LUA'
-- Autocmds are automatically loaded on the VeryLazy event

-- Disable LazyVim's wrap_spell autocmd (Korean triggers false positives)
vim.api.nvim_clear_autocmds({ group = "lazyvim_wrap_spell" })
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("custom_wrap_nospell", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
})
AUTOCMDS_LUA

    # --- lua/plugins/user.lua (theme: catppuccin-macchiato + dracula lualine + transparent) ---
    cat > "$nvim_dir/lua/plugins/user.lua" << 'USER_LUA'
return {
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
      require("transparent").setup({
        groups = {
          "Normal",
          "NormalNC",
          "Comment",
          "Constant",
          "Special",
          "Identifier",
          "Statement",
          "PreProc",
          "Type",
          "Underlined",
          "Todo",
          "String",
          "Function",
          "Conditional",
          "Repeat",
          "Operator",
          "Structure",
          "LineNr",
          "NonText",
          "SignColumn",
          "CursorLine",
          "CursorLineNr",
          "StatusLine",
          "StatusLineNC",
          "EndOfBuffer",
        },
        extra_groups = { "NeoTreeNormal", "NeoTreeNormalNC" },
        exclude_groups = {},
      })
    end,
  },
  -- catppuccin-macchiato colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
  -- lualine: dracula theme
  {
    "nvim-lualine/lualine.nvim",
    opts = function()
      return {
        options = {
          theme = "dracula",
        },
      }
    end,
  },
}
USER_LUA

    ok "LazyVim configured (catppuccin-macchiato + dracula lualine + transparent)"
}

# =============================================================================
# 5. Starship
# =============================================================================
install_starship() {
    info "Installing starship..."
    brew install starship 2>/dev/null || true
    ok "starship installed"
}

configure_starship() {
    info "Configuring starship..."
    local starship_dir="$HOME/.config/starship"
    mkdir -p "$starship_dir"

    cat > "$starship_dir/starship.toml" << 'STARSHIP_TOML'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[](surface1)\
$os\
$username\
$hostname\
[](bg:peach fg:surface1)\
$directory\
[](fg:peach bg:green)\
$git_branch\
$git_status\
[](fg:green bg:teal)\
$c\
$rust\
$golang\
$nodejs\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:teal bg:blue)\
$docker_context\
[](fg:blue bg:purple)\
$time\
[ ](fg:purple)\
$line_break$character"""

palette = 'catppuccin_mocha'

[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo = "#f2cdcd"
pink = "#f5c2e7"
orange = "#cba6f7"
red = "#f38ba8"
maroon = "#eba0ac"
peach = "#fab387"
yellow = "#f9e2af"
green = "#a6e3a1"
teal = "#94e2d5"
sky = "#89dceb"
sapphire = "#74c7ec"
blue = "#89b4fa"
lavender = "#b4befe"
text = "#cdd6f4"
subtext1 = "#bac2de"
subtext0 = "#a6adc8"
overlay2 = "#9399b2"
overlay1 = "#7f849c"
overlay0 = "#6c7086"
surface2 = "#585b70"
surface1 = "#45475a"
surface0 = "#313244"
base = "#1e1e2e"
mantle = "#181825"
crust = "#11111b"

[os]
disabled = false
style = "bg:surface1 fg:text"

[os.symbols]
Windows = "󰍲"
Ubuntu = "󰕈"
SUSE = ""
Raspbian = "󰐿"
Mint = "󰣭"
Macos = ""
Manjaro = ""
Linux = "󰌽"
Gentoo = "󰣨"
Fedora = "󰣛"
Alpine = ""
Amazon = ""
Android = ""
Arch = "󰣇"
Artix = "󰣇"
CentOS = ""
Debian = "󰣚"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"

[username]
show_always = true
style_user = "bg:surface1 fg:text"
style_root = "bg:surface1 fg:text"
format = '[ $user]($style)'

[hostname]
ssh_only = false
style = "bg:surface1 fg:text"
format = '[@$hostname ]($style)'

[directory]
style = "fg:mantle bg:peach"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "

[git_branch]
symbol = ""
style = "bg:teal"
format = '[[ $symbol $branch ](fg:base bg:green)]($style)'

[git_status]
style = "fg:white bg:teal"
format = '[$all_status$ahead_behind]($style)'
ahead = '⇡${count}'
diverged = '⇕⇡${ahead_count}⇣${behind_count}'
behind = '⇣${count}'

[nodejs]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[c]
symbol = " "
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[rust]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[golang]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[php]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[java]
symbol = " "
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[kotlin]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[haskell]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[python]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[docker_context]
symbol = ""
style = "bg:mantle"
format = '[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)'

[time]
disabled = false
time_format = "%I:%M %p"
style = "bg:peach"
format = '[[  $time ](fg:mantle bg:purple)]($style)'

[line_break]
disabled = false

[character]
disabled = false
success_symbol = '[](bold fg:green)'
error_symbol = '[](bold fg:red)'
vimcmd_symbol = '[](bold fg:creen)'
vimcmd_replace_one_symbol = '[](bold fg:purple)'
vimcmd_replace_symbol = '[](bold fg:purple)'
vimcmd_visual_symbol = '[](bold fg:lavender)'
STARSHIP_TOML

    ok "starship configured"
}

# =============================================================================
# 5. Shell RC (auto-add init lines)
# =============================================================================
add_line_if_missing() {
    local file="$1"
    local marker="$2"
    local line="$3"

    if [[ -f "$file" ]] && grep -qF "$marker" "$file"; then
        return 0
    fi
    echo "$line" >> "$file"
}

configure_shell_rc() {
    info "Configuring shell rc files..."

    local shell_rc_files=()

    # Detect which shells are in use
    [[ -f "$HOME/.bashrc" ]] && shell_rc_files+=("$HOME/.bashrc")
    [[ -f "$HOME/.zshrc" ]]  && shell_rc_files+=("$HOME/.zshrc")

    # If neither exists, create for current shell
    if [[ ${#shell_rc_files[@]} -eq 0 ]]; then
        local current_shell
        current_shell="$(basename "$SHELL")"
        case "$current_shell" in
            zsh)  shell_rc_files+=("$HOME/.zshrc") ;;
            bash) shell_rc_files+=("$HOME/.bashrc") ;;
            *)    shell_rc_files+=("$HOME/.bashrc") ;;
        esac
    fi

    for rc_file in "${shell_rc_files[@]}"; do
        local shell_name
        shell_name="$(basename "$rc_file" | sed 's/\.//')"  # bashrc -> bashrc, zshrc -> zshrc

        info "  Updating $rc_file ..."

        # Determine shell-specific fzf source command
        local fzf_cmd
        case "$rc_file" in
            *.zshrc)  fzf_cmd='source <(fzf --zsh)' ;;
            *.bashrc) fzf_cmd='eval "$(fzf --bash)"' ;;
        esac

        # Determine shell-specific shell name for init commands
        local sh_name
        case "$rc_file" in
            *.zshrc)  sh_name="zsh" ;;
            *.bashrc) sh_name="bash" ;;
        esac

        local block="
# --- Added by setup-dev-env.sh ---
export VISUAL=nvim
export EDITOR=nvim
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval \"\$(starship init $sh_name)\"
eval \"\$(zoxide init $sh_name)\"
$fzf_cmd

# yy: yazi wrapper (cd to last dir on exit)
function yy() {
    local tmp
    tmp=\$(mktemp -t \"yazi-cwd.XXXXXX\")
    yazi \"\$@\" --cwd-file=\"\$tmp\"
    if local cwd=\$(cat -- \"\$tmp\") && [ -n \"\$cwd\" ] && [ \"\$cwd\" != \"\$PWD\" ]; then
        cd -- \"\$cwd\"
    fi
    rm -f -- \"\$tmp\"
}
# --- End setup-dev-env.sh ---"

        add_line_if_missing "$rc_file" "# --- Added by setup-dev-env.sh ---" "$block"
    done

    ok "Shell rc files updated"
}

# =============================================================================
# Dependencies (sesh, fzf, eza, fd, ripgrep, zoxide, glow)
# =============================================================================
install_dependencies() {
    info "Installing dependencies (fzf, eza, fd, ripgrep, zoxide, sesh, glow)..."
    brew install fzf eza fd ripgrep zoxide sesh glow 2>/dev/null || true
    ok "Dependencies installed"
}

# =============================================================================
# Main
# =============================================================================
main() {
    echo ""
    echo "======================================"
    echo "  Dev Environment Setup"
    echo "  kitty + tmux + yazi + starship"
    echo "======================================"
    echo ""

    detect_os
    ensure_homebrew
    install_font
    install_dependencies

    # 1. Kitty
    install_kitty
    configure_kitty

    # 2. tmux + oh-my-tmux
    install_tmux
    configure_tmux

    # 3. Yazi
    install_yazi
    configure_yazi

    # 4. LazyVim
    install_neovim
    configure_lazyvim

    # 5. Starship
    install_starship
    configure_starship

    # 5. Shell RC init
    configure_shell_rc

    echo ""
    echo "======================================"
    ok "All done!"
    echo "======================================"
    echo ""
    info "Launch kitty and open tmux to verify everything works."
    echo ""
}

main "$@"
