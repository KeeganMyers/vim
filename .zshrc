# Set up the prompt

export PATH=usr/bin:$PATH
#export ZSH_THEME="muse"
export ZSH_THEME="simple"
export TERM=xterm-256color
plugins=(git colored-man-pages docker command-not-found  debian git-extras git-hubflow themes tmux vi-mode debian)
ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh
setopt histignorealldups sharehistory

# Powerline
if [[ -r /usr/share/powerline/bindings/zsh/powerline.zsh ]]; then
    source /usr/share/powerline/bindings/zsh/powerline.zsh
fi

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
ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

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
export USE_EDITOR=$EDITOR
export VISUAL=$EDITOR
set editing-mode vi
set blink-matching-paren on

# Use modern completion system
autoload -Uz compinit
compinit
#

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias mate-terminal='mate-terminal -e tmux'
    alias checkBreakPoints='grep -rn --exclude-dir=log --exclude-dir=vendor byebug .'
    alias grep='grep  --color=auto'
    alias fgrep='fgrep --color=auto'
    alias update_master='git remote update'
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
    alias updateReports='arc_current;bundle exec rake db:migrate:redo VERSION=20141003182022'
    alias cleanUpDocker='docker rmi -f $(docker images | grep "^<none>" | awk "{print $3}")'
    alias setupTest='rvm use ruby-2.2.1@test;arcCurrent;bundle exec rake parallel:drop;bundle exec rake parallel:create;bundle exec rake parallel:prepare'
    alias logTests="rvm use ruby-2.2.1@test;arcCurrent;time rake parallel:spec[^spec/'[mailers| models | requests]'] > log/rspec.log 2>&1 &"
    alias logFeatures="rvm use ruby-2.2.1@test;arc_current;time rspec spec/features/ > log/rspec_features.log 2>&1 &"
    alias cleanUpAssets='arcCurrent; rm public/assets/*.js; rm public/assets/*.css; rm public/assets/*.js.*; rm public/assets/*.css.*;rm public/assets/manifest-*'
    alias winName='xprop'
    alias kanboardSetup='docker run -d --name kanboard -p 1070:80 -v /$HOME/kanboard:/var/www/html/data -t kanboard/kanboard:master'
    alias kanboardTakeDown='docker stop kanboard; docker rm kanboard'
    alias rabbitSetup='arcClojure; docker run -d -p 15672:15672 -p 15674:15674 -p 5672:5672 --name rabbitmq kmyers/rabbitmq'
    alias rabbitBash='docker exec -it rabbitmq bash'
    alias rabbitTakeDown='docker stop rabbitmq; docker rm rabbitmq'
    alias searchSetup='docker run -d -p 9200:9200 -p 9300:9300 --expose 9200 --expose 9300 -v $HOME/Projects/clojure/arc/search:/usr/share/elasticsearch/data --name elasticsearch docker.elastic.co/elasticsearch/elasticsearch:5.5.0'
    alias searchBash='docker exec -it elasticsearch bash'
    alias searchTakeDown='docker stop elasticsearch; docker rm elasticsearch'
    alias clojureSetup='docker run -d -p 1099:1099 -p 51246:51246 -p 60290:60290 -p 35168:35168 -p 8080:8080 --link mailcatcher --link rabbitmq --link elasticsearch -v $HOME/Projects/clojure/arc:/arc --name clojure-dev kmyers/arc-dev:1'
    alias clojureTakeDown='docker stop clojure-dev && docker rm clojure-dev'
    alias prdSetup='docker run -d -p 1096:1096 -p 51246:51246 -p 60290:60290 -p 35168:35168 -p 8080:8080 --link mailcatcher --link rabbitmq --link elasticsearch --name clojure-prd kmyers/arc-prd:1'
    alias prdTakeDown='docker stop clojure-prd && docker rm clojure-prd'
    alias clojureTest='docker run -d -p 1098:1098  -v $HOME/Projects/clojure/arc:/arc --name clojure-test kmyers/arc-test:1 && docker rm clojure-test'
    alias clojureBuild='docker run -d -p 1097:1097  -v $HOME/Projects/clojure/arc:/arc --name clojure-build kmyers/arc-build:1 && docker rm clojure-build'
    alias mailCatcherSetup='docker run -d -p 1080:1080 -p 1025:1025 --name mailcatcher schickling/mailcatcher'
    alias mailCatcherTakeDown='docker stop mailcatcher; docker rm mailcatcher'
    alias dark='xrandr --output DP-4 --brightness 0.6;xrandr --output DP-1 --brightness 0.6; xrandr --output DP-3 --brightness 0.6'
    alias average='xrandr --output DP-4 --brightness 0.8;xrandr --output DP-1 --brightness 0.8; xrandr --output DP-3 --brightness 0.8'
    alias bright='xrandr --output DP-4 --brightness 1.0;xrandr --output DP-1 --brightness 1.0; xrandr --output DP-3 --brightness 1.0'
    alias boot-updates='boot -d boot-deps ancient'
    alias genPass='date +%s | sha256sum | base64 | head -c 12 ; echo'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias emacs='emacs -nw --no-desktop'
alias arcCurrent='cd /$HOME/Projects/ARC'
alias arcClojure='cd /$HOME/Projects/clojure/arc'

missingTests(){
 diff  <(ls test/server/arcTest/server/generative | sed 's/\.clj//g' | sort) <(ls src/arc/shared/aggregate | sed 's/\.cljc//g' | sort) | grep '>' | sed -e 's/>//g'
}

instanceIP(){
  docker inspect $1 | grep '"IPAddress":' | awk {'print $2'} | tr "," " " | tr "\"" " "
}

filesChanged(){
  git status | grep -E 'modified|deleted|new' | wc -l
}

clear_cache(){
  sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
}

export BOOT_EMIT_TARGET=no
export ELASTICSEARCH_PORT_9200_TCP_ADDR="127.0.0.1"
export ELASTICSEARCH_PORT_9200_TCP_PORT="9200"
export MAILCATCHER_PORT_1025_TCP_ADDR="127.0.0.1"
export MAILCATCHER_PORT_1025_TCP_PORT="1025"
export RABBITMQ_PORT_5672_TCP_ADDR="127.0.0.1"
export RABBITMQ_PORT_5672_TCP_PORT="5672"
export DOCKER_HOST=unix:///var/run/docker.sock
export BOOT_JVM_OPTIONS='-Xmx10g -client -XX:+TieredCompilation
-XX:TieredStopAtLevel=1 -Xverify:none -XX:+UseConcMarkSweepGC
-Djavax.net.ssl.trustStore="/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts"
-Djavax.net.ssl.trustStorePassword="changeit"
-XX:+CMSClassUnloadingEnabled -Xmx512m -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false'

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
