# Set up the prompt

export PATH=usr/bin:$PATH
#export ZSH_THEME="muse"
export ZSH_THEME="simple"
export TERM=xterm-256color
plugins=(git colored-man-pages docker command-not-found  debian git-extras git-hubflow themes tmux vi-mode)
ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh
setopt histignorealldups sharehistory

export ZSH_THEME="agnoster"

# on login
if [ ! -f /tmp/login ]; then
  touch /tmp/login
  eval $(ssh-agent)
  ssh-add -l >/dev/null || alias ssh='ssh-add -l >/dev/null || ssh-add && unalias ssh; ssh'
fi

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Customize to your needs...
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/usr/local/git/bin:/opt/local/bin
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="$fg[red]+"
ZSH_THEME_GIT_PROMPT_CLEAN="$fg[green]"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"

setopt RM_STAR_WAIT
setopt interactivecomments
setopt CORRECT
bindkey -v
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

precmd() { RPROMPT="" }
function zle-line-init zle-keymap-select {
   VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
   RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
   zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1
export KEYTIMEOUT=1
set -o vi
umask 022 
setopt APPEND_HISTORY 
setopt SHARE_HISTORY 
setopt NOTIFY 
setopt NOHUP 
setopt MAILWARN
export EDITOR="vim"
export clojureDir=$HOME/Projects/clojure/arc
export currentDir=$HOME/Projects/ARC
export VISUAL=$EDITOR
export TERMINAL='alacritty'
set editing-mode vi
set keymap vi-command

set blink-matching-paren on

# Use modern completion system
autoload -Uz compinit
compinit
#

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='exa'
    alias mate-terminal='alacritty -e tmux'
    alias checkBreakPoints='grep -rn --exclude-dir=log --exclude-dir=vendor byebug .'
    alias grep='rg'
    alias clip='xclip -selection c'
    alias cleanUpDocker='docker rmi -f $(docker images | grep "^<none>" | awk "{print $3}")'
    alias winName='xprop'
    alias dark='xrandr --output DP-2 --brightness 0.6;xrandr --output DP-1 --brightness 0.6; xrandr --output DP-5 --brightness 0.6'
    alias average='xrandr --output DP-2 --brightness 0.8;xrandr --output DP-1 --brightness 0.8; xrandr --output DP-5 --brightness 0.8'
    alias bright='xrandr --output DP-2 --brightness 1.0;xrandr --output DP-1 --brightness 1.0; xrandr --output DP-5 --brightness 1.0'
    alias genPass='date +%s | sha256sum | base64 | head -c 12 ; echo'
    alias rust-repl='evcxr'
fi

alias emacs='emacs -nw --no-desktop'

function stagingRepl() {
  ssh -o StrictHostKeyChecking=no -i $HOME/.minikube/machines/minikube/id_rsa docker@$(minikube ip) -p 22 -t 'docker exec -it $(docker ps | grep arc-staging | head -n 1 | awk {'\''print $1'\''}) /usr/local/bin/boot repl -c -H localhost -p 9001'
}

function internal_ip() {
  ip route get 8.8.8.8 | awk '{print $NF; exit}'
}

function instanceIP() {
  docker inspect $1 | grep '"IPAddress":' | awk {'print $2'} | tr "," " " | tr "\"" " "
}

function filesChanged() {
  git status | grep -E 'modified|deleted|new' | wc -l
}

function clear_cache() {
  sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
}

function gitPush() {
  git push origin $(git branch | grep '*' | awk {'print $2'})
}

function convert_msg() {
  msgconvert *.msg
}

function git_prompt_info() {
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    ref="$(command echo ${ref#refs/heads/})"
    length=${#ref}

    maxLength=$(command git config --get oh-my-zsh.max-branch-length 2>/dev/null)
    if [[ -z ${maxLength} ]]; then
      maxLength=20
    fi


    if [[ ${length} -gt ${maxLength} ]]; then
      regex=$(command git config --get oh-my-zsh.prefix-regex 2>/dev/null)
      if [[ -n ${regex} ]]; then
        ref=$(command echo ${ref} | sed "s/${regex}//1" ) #${regex})
      fi

      prefixLength=$(command git config --get oh-my-zsh.prefix-length 2>/dev/null)
      if [[ -z ${prefixLength} ]]; then
        prefixLength=0
      fi
      if [[ ${prefixLength} -gt 0 ]]; then
        prefix=$(command echo ${ref} | cut -c ${prefixLength})
        ref=$(command echo ${ref} | cut -c `expr ${prefixLength} + 1`-)
        length=${#ref}
      fi
    fi
    if [[ ${length} -gt ${maxLength} ]]; then
      suffixLength=$(command git config --get oh-my-zsh.suffix-length 2>/dev/null)
      if [[ -z ${suffixLength} ]]; then
        suffixLength=0
      fi

      length=${#ref}
      suffixStart=`expr ${length} - ${suffixLength} + 1`
      separatorLength=3 #3 dots...
      nameEnd=`expr ${maxLength} - ${suffixLength} - ${separatorLength}`
      ref="$(command echo ${ref} | cut -c 1-${nameEnd})...$(command echo ${ref} | cut -c ${suffixStart}-)"
    fi

    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

export DOCKER_HOST=unix:///var/run/docker.sock
export PATH="$PATH:/usr/local/go/bin:$HOME/.rvm/bin:$HOME/.cargo/bin" # Add RVM to PATH for scripting
