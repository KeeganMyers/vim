# Set up the prompt

export PATH=usr/bin:$PATH
#export ZSH_THEME="muse"
export ZSH_THEME="simple"
plugins=(git colored-man-pages docker command-not-found  debian git-extras git-hubflow themes tmux vi-mode debian)
ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh
setopt histignorealldups sharehistory
. /usr/local/lib/python2.7/dist-packages/powerline/bindings/zsh/powerline.zsh

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
    alias clojureBash='docker exec -it clojure bash'
    alias rethinkBash='docker exec -it rethinkdb bash'
    alias kanboardSetup='docker run -d --name kanboard -p 1070:80 -v /home/kmyers/kanboard:/var/www/html/data -t kanboard/kanboard:master'
    alias kanboardTakeDown='docker stop kanboard; docker rm kanboard'
    alias clojureSetup='rethinkSetup; docker run -d -p 4000:3448 -P --link rethinkdb:rdb -it --name clojure -v /home/kmyers/Projects/clojure:/home/projects -v /home/kmyers/.vim:/home/.vim clojure'
    alias clojureTakeDown='docker stop clojure; docker rm clojure'
    alias rethinkSetup='docker run -d -p 1090:8080 -p 28015:28015 -v /home/kmyers/Projects/clojure/arc/data:/data --name rethinkdb  rethinkdb'
    alias rethinkTakeDown='docker stop rethinkdb; docker rm rethinkdb'
    alias rabbitSetup='arcClojure; docker run -d -p 15672:15672  -p 5672:5672 --name rabbitmq rabbitmqv3.6'
    alias rabbitBash='docker exec -it rabbitmq bash'
    alias rabbitTakeDown='docker stop rabbitmq; docker rm rabbitmq'
    alias searchSetup='docker run -d -p 9200:9200 -p 9300:9300 --name elasticsearch elasticsearch:latest -Des.node.name="Node01" -Des.cluster.name="elasticsearch"'
    alias searchBash='docker exec -it elasticsearch bash'
    alias searchTakeDown='docker stop elasticsearch; docker rm elasticsearch'
    alias dockerMailcatcher='mailcatcher --smtp-ip 192.168.2.69 &'
    alias dark='xrandr --output DP-4 --brightness 0.6;xrandr --output DP-1 --brightness 0.6; xrandr --output DP-3 --brightness 0.6'
    alias average='xrandr --output DP-4 --brightness 0.8;xrandr --output DP-1 --brightness 0.8; xrandr --output DP-3 --brightness 0.8'
    alias bright='xrandr --output DP-4 --brightness 1.0;xrandr --output DP-1 --brightness 1.0; xrandr --output DP-3 --brightness 1.0'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias arcCurrent='cd /home/kmyers/Projects/ARC'
alias arcClojure='cd /home/kmyers/Projects/clojure/arc'


instanceIP(){
  docker inspect $1 | grep '"IPAddress":' | awk {'print $2'} | tr "," " " | tr "\"" " "
}

clear_cache(){
  sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
}

export BOOT_EMIT_TARGET=no
export DOCKER_HOST=unix:///var/run/docker.sock
export BOOT_JVM_OPTIONS='-Xmx4g -client -XX:+TieredCompilation
-XX:TieredStopAtLevel=1 -Xverify:none -XX:+UseConcMarkSweepGC
-XX:+CMSClassUnloadingEnabled -Xmx512m -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=43210'
