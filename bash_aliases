alias src='source ~/.bash_aliases'

alias cls='clear'
alias v='nvim'
alias vi='nvim'
alias nv='nvim'

alias cpy='xclip -sel c < '

alias grep='rg --color=auto'

alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'   # show long listing of all except ".."
alias la='ls -a --ignore=..'   # show listing of all except ".."
alias l='ls -a --ignore=..'

alias tm="tmux -2 attach-session || tmux -2 new-session"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias st='git status'
alias co='git checkout -b'
