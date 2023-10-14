# Explicitly declare XDG defaults
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache

# Place zsh configuration files in XDG-compliant location
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

# Disable Apple's session-based history mechanism
export SHELL_SESSIONS_DISABLE=1
