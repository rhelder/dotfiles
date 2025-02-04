# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options to be able to apply configuration changes
  # without restarting zsh
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Prompt style {{{1

  # Define character set
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  # No extra space after icons in monospaced font
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  # Place icons before content on left, after content on right
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=

  # Use two lines
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  # No frame between first and second line
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=
  # No filler between left and right prompt
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_BACKGROUND=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_GAP_BACKGROUND=

  typeset -g POWERLEVEL9K_BACKGROUND=0
  # Angled segment separators
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='%8F\uE0B1'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='%8F\uE0B3'
  # Sharp prompt heads
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0B2'
  # Flat prompt tails
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''

  # No left prompt head if the line has no segments
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  # Segments {{{1

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    dir
    vcs
    newline
    prompt_char
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    command_execution_time
    background_jobs
    context
    vi_mode
    time
    newline
  )

  # os_icon {{{2

  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=#e2e2e2

  # prompt_char {{{2
  # Transparent background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=10
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=9
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  # If only segment, no prompt head or tail
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  # No whitespace before or after segment
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  # dir {{{2
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=6
  # If directory is too long, shorten some of its segments to the shortest
  # possible unique prefix. The shortened directory can be tab-completed to the
  # original.
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  # Replace removed segment suffixes with this symbol.
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  # Color of the shortened directory segments.
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=4
  # Color of the anchor directory segments. Anchor segments are never
  # shortened. The first segment is always an anchor.
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=14
  # Display anchor directory segments in bold.
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  # Don't shorten directories that contain any of these files. They are
  # anchors.
  local anchor_files=(
    .git
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  # If set to "first" ("last"), remove everything before the first (last)
  # subdirectory that contains files matching
  # $POWERLEVEL9K_SHORTEN_FOLDER_MARKER. For example, when the current
  # directory is /foo/bar/git_repo/nested_git_repo/baz, prompt will display
  # git_repo/nested_git_repo/baz (first) or nested_git_repo/baz (last). This
  # assumes that git_repo and nested_git_repo contain markers and other
  # directories don't.

  # Optionally, "first" and "last" can be followed by ":<offset>" where
  # <offset> is an integer. This moves the truncation point to the right
  # (positive offset) or to the left (negative offset) relative to the marker.
  # Plain "first" and "last" are equivalent to "first:0" and "last:0"
  # respectively.
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  # Don't shorten this many last directory segments. They are anchors.
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  # Shorten directory if it's longer than this even if there is space for it.
  # The value can be either absolute (e.g., '80') or a percentage of terminal
  # width (e.g, '50%'). If empty, directory will be shortened only when prompt
  # doesn't fit or when other parameters demand it. If set to `0`, directory
  # will always be shortened to its minimum length.
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80

  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false

  # Enable special styling for non-writable and non-existent directories
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # git_status {{{2

  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '

  # VCS_STATUS_* parameters are set by gitstatus plugin. See reference:
  # https://github.com/romkatv/gitstatus/blob/master/gitstatus.plugin.zsh.
  function my_git_formatter() {
    emulate -L zsh

    if [[ -n $P9K_CONTENT ]]; then
      # If P9K_CONTENT is not empty, use it. It's either "loading" or from
      # vcs_info (not from gitstatus plugin). VCS_STATUS_* parameters are not
      # available in this case.
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi

    if (( $1 )); then
      # Git status is up to date
      local meta='%7F'
      local clean='%10F'
      local modified='%11F'
      local untracked='%14F'
      local conflicted='%9F'
    else
      # Git status is being computed
      local meta='%8F'
      local clean='%8F'
      local modified='%8F'
      local untracked='%8F'
      local conflicted='%8F'
    fi

    local res

    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"  # <-- this line
      res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
    fi

    if [[ -n $VCS_STATUS_TAG ]]; then
      local tag=${(V)VCS_STATUS_TAG}
      (( $#tag > 32 )) && tag[13,-13]="…"  # <-- this line
      res+="${meta}#${clean}${tag//\%/%%}"
    fi

    # Display the current Git commit if there is no branch and no tag
    [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
      res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

    # Show tracking branch name if it differs from local branch
    if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
      res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
    fi

    # Display "wip" if the latest commit's summary contains "wip" or "WIP".
    if [[
      $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*)
    ]]; then
      res+=" ${modified}wip"
    fi

    if (( VCS_STATUS_COMMITS_AHEAD || VCS_STATUS_COMMITS_BEHIND )); then
      # ⇣42 if behind the remote.
      if (( VCS_STATUS_COMMITS_BEHIND )); then
        res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
      fi

      if (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )); then
        res+=" "
      fi

      # ⇡42 if ahead of the remote; no leading space if also behind the remote:
      # ⇣42⇡42.
      if (( VCS_STATUS_COMMITS_AHEAD  )); then
        res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
      fi
    fi

    # ⇠42 if behind the push remote.
    if (( VCS_STATUS_PUSH_COMMITS_BEHIND )); then
      res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
    fi

    if ((
      VCS_STATUS_PUSH_COMMITS_AHEAD
      && !VCS_STATUS_PUSH_COMMITS_BEHIND
    )); then
      res+=" "
    fi

    # ⇢42 if ahead of the push remote; no leading space if also behind: ⇠42⇢42.
    if (( VCS_STATUS_PUSH_COMMITS_AHEAD  )); then
      res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
    fi

    # *42 if have stashes.
    if (( VCS_STATUS_STASHES )); then
      res+=" ${clean}*${VCS_STATUS_STASHES}"
    fi

    # 'merge' if the repo is in an unusual state.
    if [[ -n $VCS_STATUS_ACTION ]]; then
      res+=" ${conflicted}${VCS_STATUS_ACTION}"
    fi

    # ~42 if have merge conflicts.
    if (( VCS_STATUS_NUM_CONFLICTED )); then
      res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    fi

    # +42 if have staged changes.
    if (( VCS_STATUS_NUM_STAGED )); then
      res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    fi

    # !42 if have unstaged changes.
    if (( VCS_STATUS_NUM_UNSTAGED   )); then
      res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    fi

    # ?42 if have untracked files.
    if (( VCS_STATUS_NUM_UNTRACKED )); then
      res+=" ${untracked}?${VCS_STATUS_NUM_UNTRACKED}"
    fi
    # "─" if the number of unstaged files is unknown. This can happen due to
    # POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY (see below) being set to a
    # non-negative number lower than the number of files in the Git index, or
    # due to bash.showDirtyState being set to false in the repository config.
    # The number of staged and untracked files may also be unknown in this
    # case.
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"

    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null

  # Don't count the number of unstaged, untracked and conflicted files in Git
  # repositories with more than this many files in the index. Negative value
  # means infinity.
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1

  # Don't show Git status in prompt for repositories whose workdir matches this
  # pattern.
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN=

  # Disable the default Git status formatting.
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  # Install our own Git status formatter.
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  # Enable counters for staged, unstaged, etc.
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  # Icon color
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=10
  typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=8

  # Show status of repositories of these types
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  # These settings are used for repositories other than Git or when gitstatusd
  # fails and Powerlevel10k has to fall back to using vcs_info.
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=10
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=10
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=11

  # exit_code {{{2

  # Enable OK_PIPE, ERROR_PIPE and ERROR_SIGNAL status states to allow us to
  # enable, disable and style them independently from the regular OK and ERROR
  # state.
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true

  # Status on success. No content, just an icon. No need to show it if
  # prompt_char is enabled as it will signify success by turning green.
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=2
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'

  # Status when it's just an error code (e.g., '1'). No need to show it if
  # prompt_char is enabled as it will signify error by turning red.
  typeset -g POWERLEVEL9K_STATUS_ERROR=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=1
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'

  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=2
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=1
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'

  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=1
  # Use terse signal names
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'

  # command_execution_time {{{2

  # Time in seconds
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  # Show this many fractional digits. Zero means round to seconds.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=7
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # background_jobs {{{2

  # Show the number of background jobs
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true
  # Background jobs color.
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=6

  # vi_mode {{{2

  typeset -g POWERLEVEL9K_VI_COMMAND_MODE_STRING=NORMAL
  typeset -g POWERLEVEL9K_VI_MODE_NORMAL_FOREGROUND=2
  typeset -g POWERLEVEL9K_VI_VISUAL_MODE_STRING=VISUAL
  typeset -g POWERLEVEL9K_VI_MODE_VISUAL_FOREGROUND=4
  typeset -g POWERLEVEL9K_VI_OVERWRITE_MODE_STRING=OVERTYPE
  typeset -g POWERLEVEL9K_VI_MODE_OVERWRITE_FOREGROUND=3
  typeset -g POWERLEVEL9K_VI_INSERT_MODE_STRING=
  typeset -g POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND=6

  # context {{{2

  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=11
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=11
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'
  # Default context (no privileges, no SSH)
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=11
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'

  # Don't show context unless running with privileges or in SSH
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

  # current_time {{{2

  typeset -g POWERLEVEL9K_TIME_FOREGROUND=6
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%I:%M:%S %p}'
  # If set to true, time will update when you hit enter. This way prompts for
  # the past commands will contain the start times of their commands as opposed
  # to the default behavior where they contain the end times of their preceding
  # commands.
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  # }}}2
  # }}}1

  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k
  # has been initialized. Hot reload can slow down prompt by 1-2 milliseconds,
  # so disable.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # If p10k is already loaded, reload configuration.
  # This works even with POWERLEVEL9K_DISABLE_HOT_RELOAD=true.
  (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite
typeset -g POWERLEVEL9K_CONFIG_FILE=$HOME/Development/powerlevel10k/.p10k.zsh

# Reset options
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
