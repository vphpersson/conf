################################################################################
# Modules
################################################################################

zmodload zsh/complist

################################################################################
# Widgets
################################################################################

# Enable editing of command in $EDITOR.
autoload -U edit-command-line
zle -N edit-command-line

# TODO: Is this behavior what I want?
# Implements functions like history-beginning-search-{back,for}ward, but takes
# the cursor to the end of the line after moving in the history, like
# history-search-{back,for}ward.
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

autoload -U compinit
compinit

autoload -U colors
colors

################################################################################
# Options
################################################################################

# Changing Directories

# Make cd push the old directory onto the directory stack.
setopt auto_pushd
# Don’t push multiple copies of the same directory onto the directory stack.
setopt pushd_ignore_dups
# Exchanges the meanings of ‘+’ and ‘-’ when used with a number to specify a
# directory in the stack.
setopt pushd_minus

# Completion

setopt auto_name_dirs
# Automatically use menu completion after the second consecutive request for
# completion, for example by pressing the tab key repeatedly.
setopt auto_menu

# History

# Save each command’s beginning timestamp and the duration to the history file.
setopt extended_history
# If the internal history needs to be trimmed to add the current command line,
# setting this option will cause the oldest history event that has a duplicate
# to be lost before losing a unique event from the list.
setopt hist_expire_dups_first
# Do not enter command lines into the history list if they are duplicates of
# the previous event.
setopt hist_ignore_dups
# Remove command lines from the history list when the first character on the
# line is a space, or when one of the expanded aliases contains a leading space.
setopt hist_ignore_space
# Whenever the user enters a line with history expansion, don’t execute the line
# directly; instead, perform history expansion and reload the line into the
# editing buffer.
setopt hist_verify
# Both imports new commands from the history file, and also causes your typed
# commands to be appended to the history file.
setopt share_history

# Input/Output

# Output flow control via start/stop characters (usually assigned to ^S/^Q) is
# disabled in the shell’s editor.
unsetopt flowcontrol
# Use the Dvorak keyboard instead of the standard qwerty keyboard as a basis
# for examining spelling mistakes for the CORRECT and CORRECT_ALL options and
# the spell-word editor command.
setopt dvorak

# Job Control

# Print job notifications in the long format by default.
setopt long_list_jobs

# Prompting

# Parameter expansion, command substitution and arithmetic expansion are
# performed in prompts. Necessary in order to invoke a function on every
# prompt redrawing.
setopt prompt_subst

################################################################################
# Function parameters
################################################################################

GIT_PROMPT_PREFIX="("
GIT_PROMPT_SUFFIX=")"
GIT_PROMPT_SEPARATOR="|"
GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
GIT_PROMPT_STAGED="%{$fg[red]%}%{●%G%}"
GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{✖%G%}"
GIT_PROMPT_CHANGED="%{$fg[blue]%}%{✚%G%}"
GIT_PROMPT_BEHIND="%{↓%G%}"
GIT_PROMPT_AHEAD="%{↑%G%}"
GIT_PROMPT_UNTRACKED="%{…%G%}"
GIT_PROMPT_CLEAN="%{$fg_bold[green]%}%{✔%G%}"

################################################################################
# Functions
################################################################################

function pdf() {
  nohup zathura $1 >/dev/null 2>&1 &
}

function mpv() {
  nohup mpv $1 >/dev/null 2>&1 &
}

function bk() {
  cp -i $1{,.bk}
}

function pyhelp() {
  python3 <<-EOF | less
	help('$1')
	EOF
}

function publicip() {
  dig +short 'myip.opendns.com' @resolver1.opendns.com
}

function _git_status() {
	gitprompt_line="$(gitprompt)"
	[ -z "$gitprompt_line" ] && return
	IFS=' ' read -r branch_name num_ahead num_behind num_staged num_conflicts num_changed num_untracked <<< "$gitprompt_line"

	first_part=''
	[ "$num_behind" -ne "0" ] && first_part+="${GIT_PROMPT_BEHIND}${num_behind}%{${reset_color}%}"
	[ "$num_ahead" -ne "0" ] && first_part+="${GIT_PROMPT_AHEAD}${num_ahead}%{${reset_color}%}"

	second_part=''
	if [ "$num_staged" -eq "0" ] && [ "$num_conflicts" -eq "0" ] && [ "$num_changed" -eq "0" ] && [ "$num_untracked" -eq "0" ]; then
			second_part="$GIT_PROMPT_CLEAN%{${reset_color}%}"
	else
		[ "$num_staged" -ne "0" ] && second_part+="${GIT_PROMPT_STAGED}${num_staged}%{${reset_color}%}"
		[ "$num_conflicts" -ne "0" ] && second_part+="${GIT_PROMPT_CONFLICTS}${num_conflicts}%{${reset_color}%}"
		[ "$num_changed" -ne "0" ] && second_part+="${GIT_PROMPT_CHANGED}${num_changed}%{${reset_color}%}"
		[ "$num_untracked" -ne "0" ] && second_part+="${GIT_PROMPT_UNTRACKED}%{${reset_color}%}"
	fi

	printf '%s\n' "${GIT_PROMPT_PREFIX}${GIT_PROMPT_BRANCH}${branch_name}%{${reset_color}%}${first_part}${GIT_PROMPT_SEPARATOR}${second_part}${GIT_PROMPT_SUFFIX} "
}

function _make_prompt() {
  # Time part; color coded by last return code.
  time="%(?.%{$fg[green]%}.%{$fg[red]%})%*%{$reset_color%}"
  # User part; color coded by privileges.
  user="%(!.%{$fg[blue]%}.%{$fg[blue]%})%n%{$reset_color%}"
  # Compacted $PWD
  pwd="%{$fg[blue]%}%c%{$reset_color%}"

  printf '%s\n' "${time} ${user}@$(hostname) ${pwd} $(_git_status)"
}

################################################################################
# ZSH parameters
################################################################################

# The file to save the history in when an interactive shell exits*.
HISTFILE=$HOME/.zsh_history
# The maximum number of events stored in the internal history list.
HISTSIZE=12000
# Same as "PS1" -> The primary prompt string, printed before a command is read.
PROMPT='$(_make_prompt)'
# The maximum number of history events to save in the history file.
SAVEHIST=10000
# A list of non-alphanumeric characters considered part of a word by the line
# editor.
WORDCHARS=''

# An array (colon separated list) of directories specifying the search path for
# function definitions.
fpath=(~/.zsh.d/custom_completions $fpath)
# An array (colon-separated list) of directories specifying the search path
# for the cd command.
cdpath=(.)

################################################################################
# Key bindings
################################################################################

bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
bindkey "^u" backward-kill-line
bindkey '^w' backward-kill-word

bindkey '^[[Z' reverse-menu-complete

# Search command history with "ctrl+j" and "ctrl+k"
bindkey  "^t" history-beginning-search-backward-end
bindkey "^h" history-beginning-search-forward-end

# Insert the last argument of the last command.
bindkey "^p" insert-last-word

# Open the current command line in an editor.
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# Do history expansion on space.
bindkey ' ' magic-space

# Search history.
bindkey '^r' history-incremental-search-backward
bindkey '^n' history-incremental-search-forward

# Correct oddities...

# Make forward/backward navigation work with shift+arrow keys.
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Make backward delete work, even in special situations.
bindkey '^?' backward-delete-char
bindkey "^[[3~" delete-char
bindkey "^[3;5~" delete-char
bindkey "\e[3~" delete-char

################################################################################
# Aliases
################################################################################

alias rm='rm -ir'
alias mv='mv -i'
alias cp='cp -ir'
alias mk='mkdir -p'
alias df='df -h'

alias startx='ssh-agent startx'
alias objdump='objdump -M intel'
alias gdb='gdb -q'

alias ..='cd ..'
alias ...='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'
alias cd/='cd /'

alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias rd='rmdir'
alias l='exa --long --group-directories-first'
alias c='cd'
alias s='sudo'
alias v='vim'
alias d='docker'
alias ff='detox'
alias h='history'

################################################################################
# Completion system
################################################################################

zstyle ':completion:*' menu select=2
zstyle ':completion:*' menu select=long
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' group-name ''

zstyle ':completion:*:processes' command "ps -u $(whoami) -o pid,user,comm -w -w"
# zstyle ':completion:*' users command 'awk -F : '($7 != "/usr/bin/nologin"){ print $1 }' /etc/passwd'

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# TODO: Where to put?
# C-x will not "disable" the shell
stty -ixon
