# Set up the prompt

export PATH=usr/bin:$PATH
#export ZSH_THEME="muse"
export ZSH_THEME="simple"
export TERM=xterm-256color
plugins=(git colored-man-pages docker command-not-found  debian git-extras git-hubflow themes tmux vi-mode debian)
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
    alias ls='ls --color=auto'
    alias mate-terminal='alacritty -e tmux'
    alias checkBreakPoints='grep -rn --exclude-dir=log --exclude-dir=vendor byebug .'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias git='lab'
    alias cljsDev='shadow-cljs watch app'
    alias cljsBuild='shadow-cljs release app'
    alias cljsReport='npx shadow-cljs run shadow.cljs.build-report app report.html'
    alias cljsTest='shadow-cljs compile test && node out/node-tests.js'
    alias stop_workers='bundle exec rake environment RAILS_ENV=development resque:stop_workers'
    alias start_workers='bundle exec rake environment RAILS_ENV=development resque:start_workers'
    alias restart_workers='stop_workers; start_workers'
    alias stop_scheduler='bundle exec rake environment RAILS_ENV=development resque:stop_scheduler'
    alias start_scheduler='bundle exec rake environment RAILS_ENV=development resque:start_scheduler'
    alias restart_scheduler='stop_scheduler; start_scheduler'
    alias restart_background_services='stop_workers;stop_scheduler;start_workers;start_scheduler'
    alias start_redis='sudo /etc/init.d/redis-server start'
    alias stop_redis='sudo /etc/init.d/redis-server stop'
    alias recompile_assets='RAILS_ENV=staging bundle exec rake assets:precompile'
    alias rake='bundle exec rake -X'
    alias clip='xclip -selection c'
    alias updateReports='bundle exec rake db:migrate:redo VERSION=20141003182022'
    alias cleanUpDocker='docker rmi -f $(docker images | grep "^<none>" | awk "{print $3}")'
    alias setupTest='rvm use ruby-2.2.1@test;arcCurrent;bundle exec rake parallel:drop;bundle exec rake parallel:create;bundle exec rake parallel:prepare'
    alias logTests="rvm use ruby-2.2.1@test;arcCurrent;time rake parallel:spec[^spec/'[mailers| models | requests]'] > log/rspec.log 2>&1 &"
    alias logFeatures="rvm use ruby-2.2.1@test;arcCurrent;time rspec spec/features/ > log/rspec_features.log 2>&1 &"
    alias cleanUpAssets='arcCurrent; rm public/assets/*.js; rm public/assets/*.css; rm public/assets/*.js.*; rm public/assets/*.css.*;rm public/assets/manifest-*'
    alias winName='xprop'
    alias dark='xrandr --output DP-2 --brightness 0.6;xrandr --output DP-1 --brightness 0.6; xrandr --output DP-5 --brightness 0.6'
    alias average='xrandr --output DP-2 --brightness 0.8;xrandr --output DP-1 --brightness 0.8; xrandr --output DP-5 --brightness 0.8'
    alias bright='xrandr --output DP-2 --brightness 1.0;xrandr --output DP-1 --brightness 1.0; xrandr --output DP-5 --brightness 1.0'
    alias boot-updates='boot -d boot-deps ancient'
    alias genPass='date +%s | sha256sum | base64 | head -c 12 ; echo'
    alias devRepl='boot repl -c -H localhost -p 35168'
    alias rust-repl='evcxr'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias emacs='emacs -nw --no-desktop'
alias arcCurrent='cd $currentDir'
alias arcClojure='cd $clojureDir'

function devKube() {
 cd $clojureDir;
  ./restart_minikube.sh "dev" > log/minikube_startup 2&>1 &
}

function stagingKube() {
 cd $clojureDir;
 ./restart_minikube.sh  > log/minikube_startup 2&>1 &
}

function missingTests() {
 cd $clojureDir;
 diff  <(ls test/server/arcTest/server/generative | sed 's/\.clj//g' | sort) <(ls src/arc/shared/aggregate | sed 's/\.cljc//g' | sort) | grep '>' | sed -e 's/>//g'
}

function stagingRepl() {
  ssh -o StrictHostKeyChecking=no -i $HOME/.minikube/machines/minikube/id_rsa docker@$(minikube ip) -p 22 -t 'docker exec -it $(docker ps | grep arc-staging | head -n 1 | awk {'\''print $1'\''}) /usr/local/bin/boot repl -c -H localhost -p 9001'
}

function internal_ip() {
  ip route get 8.8.8.8 | awk '{print $NF; exit}'
}

function production() {
  ssh production -Yt 'cd /usr/local/www/arc/current;tmux new-session -A -s 0'
}

function APS165() {
  ssh APS165 -Yt 'tmux new-session -A -s 0'
}

function support() {
  ssh support -Yt 'tmux new-session -A -s 0'
}

function importLogs() {
  boot mass-import -e "dev" > log/import-results 2>&1 &
}

function APS164() {
  ssh APS164 -Yt 'tmux new-session -A -s 0'
}

function instanceIP() {
  docker inspect $1 | grep '"IPAddress":' | awk {'print $2'} | tr "," " " | tr "\"" " "
}

function filesChanged() {
  git status | grep -E 'modified|deleted|new' | wc -l
}

function removeKubeJobs() {
 nohup kubectl delete job $(kubectl get jobs | awk '{print $1}') &
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

function natsSubs() {
 http://127.0.0.1:30012/subsz | grep "num_subscriptions"
}

function streamLogs() {
 kubectl logs -f $(kubectl get pods | grep $1 | awk {'print $1'}) $2
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

export BOOT_EMIT_TARGET=no
export STORE_PORT_5432_TCP_ADDR="127.0.0.1"
export STORE_PORT_5432_TCP_PORT="30021"
export ELASTICSEARCH_PORT_9200_TCP_ADDR="127.0.0.1"
export ELASTICSEARCH_PORT_9200_TCP_PORT="30004"
export MINIO_PORT_9000_TCP_ADDR="127.0.0.1"
export MINIO_PORT_9000_TCP_PORT="30005"
export MAILCATCHER_PORT_1025_TCP_ADDR="127.0.0.1"
export MAILCATCHER_PORT_1025_TCP_PORT="30011"
export MB_TCP_ADDR="127.0.0.1"
export MB_PORT_4222_TCP_PORT="30002"
export KUBERNETES_SERVICE_HOST="127.0.0.1"
export KUBERNETES_SERVICE_PORT="8443"
export DOCKER_HOST=unix:///var/run/docker.sock
export BOOT_JVM_OPTIONS='-Xmx3g -server \
                      -XX:-TieredCompilation \
                      -XX:TieredStopAtLevel=1 -Xverify:none \
                      -XX:+CMSParallelRemarkEnabled \
                      -XX:+CMSClassUnloadingEnabled \
                      -Xmx512m -Dcom.sun.management.jmxremote \
                      -Dcom.sun.management.jmxremote.ssl=false \
                      -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 \
                      -XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false'

export PATH="$PATH:/usr/local/go/bin:$HOME/.rvm/bin:$HOME/.cargo/bin" # Add RVM to PATH for scripting
