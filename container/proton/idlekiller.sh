pid=$1
max_idle_minutes=$2
idle_count=0

timestamp () {
  date +"%Y-%m-%d %H:%M:%S,%3N"
}

while [[ true ]]
do
    sleep 60
    playercount=$(node playercount/playercount.js)

    if [[ $playercount == 0 ]]; then
        ((idle_count++))
    else
        idle_count=0
    fi

    echo "$(timestamp) INFO: player count: $playercount / idle count: $idle_count"

    if [[ $idle_count == $max_idle_minutes ]]; then
        echo "$(timestamp) WARN: Stopping server because it was idle for too long..." 
        kill -s TERM $pid
        exit 0
    fi
done