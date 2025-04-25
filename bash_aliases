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

alias bb='wait_for_ssh bigbox' 

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cdb='cd ~/Boqueria'
alias rt='cd ~/Boqueria/src/runtime'
alias ker='cd ~/Boqueria/src/runtime/driver/kernel'
alias wos='cd /server/dropbox/speedai-bringup/latest'
alias dockrc='vim ~/Boqueria/docker/user_env/bashrc'
alias dockbash='cp ~/docker_bash ~/Boqueria/docker/user_env/bashrc'

alias st='git status'
alias co='git checkout -b'
alias subup='git submodule update --recursive'

bq () {
    wait_for_ssh bq-station$1  
}

boot () {
    ipmitool -H bq-station$1-ipmi -U admin -P 'admin123!' power on
    sleep 10
    bq $1
}

shut () {
    ipmitool -H bq-station$1-ipmi -U admin -P 'admin123!' power off
}


ipmi () {
    ipmitool -H bq-station$1-ipmi -U admin -P 'admin123!' power cycle
    sleep 10
    bq $1
}

wait_for_ssh() {
    SERVER=$1
    PORT=22
    TIMEOUT=1
    REPORT_INTERVAL=5  # Report progress every 0.5 seconds
    last_report_time=$(date +%s.%N)  # Track when the last report was printed

    echo "Waiting for SSH on $SERVER..."

    while true; do
        nc -z -w $TIMEOUT $SERVER $PORT
        if [ $? -eq 0 ]; then
            echo "Server $SERVER is reachable on port $PORT. Attempting SSH..."
            ssh -i ~/.ssh/server -t georgep@$SERVER "cd Boqueria ; bash --login" 
            return 0  # SSH successful, exit function
        else
            current_time=$(date +%s.%N)
            elapsed_time=$(echo "$current_time - $last_report_time" | bc)

            if (( $(echo "$elapsed_time >= $REPORT_INTERVAL" | bc -l) )); then
                echo "Server $SERVER is not reachable on port $PORT. Retrying..."
                last_report_time=$current_time  # Update the last report time
            fi
        fi
    done
}

dock () {
    cd ~/Boqueria
    ./untether_dev.sh -t bringup connect
}

dockb () {
    cd ~/Boqueria
    ./untether_dev.sh -t bringup down
    ./untether_dev.sh -t bringup build
    ./untether_dev.sh -t bringup up
    ./untether_dev.sh -t bringup connect
}

purge () {
    cd ~/Boqueria
    ./untether_dev.sh -t bringup down
    ./untether_dev.sh -t bringup purge
}


stats() {
    git log --author="$1" --numstat --pretty="%H" | awk 'NF==3 {add+=$1; del+=$2} END {print "Author:", "'"$1"'", "Added:", add, "Removed:", del}';
}
