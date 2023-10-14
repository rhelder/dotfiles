# `.zprofile` is to be used for setting the path, because:
#
# * It is sourced after `/etc/zprofile`, in which macOS's `path_helper` is
#   invoked (if the path were set in e.g. `~/.zshenv`, on the other hand,
#   results may not be as desired, because `path_helper` would subsequently
#   prepend a bunch of stuff to whatever was set in `~/.zshenv`
# * `.zprofile` is only sourced at login, whereas e.g. `.zshrc` might be
#   sourced multiple times during a shell session (either directly, by the
#   user, or if the user starts a new shell from within the interactive shell.
#   Thus, if items were prepended to `PATH` in `.zshrc`, that might result in
#   the same items being added to the path multiple times. This can be avoided
#   by testing for whether or not the items are already in the path before
#   prepending them, but that seems like a cumbersome solution compared to just
#   setting the path in `.zprofile`.


# Prepend Python 3.11 directory to path
PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:${PATH}"

# Set Homebrew environment variables and prepend Homebrew directories to `PATH`,
# `MANPATH`, and `INFOPATH`
eval "$(/opt/homebrew/bin/brew shellenv)"
