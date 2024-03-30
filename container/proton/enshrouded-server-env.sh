export SERVER_NAME='Enshrouded Server'
export SERVER_SLOTS=4
export SERVER_PASSWORD=xxx
export GAME_PORT=15636
export QUERY_PORT=15637
# optional: noip.org group user for updating the dyndns entry
export NOIP_USER=xxx
# optional: noip.org group password for updating the dyndns entry
export NOIP_PWD=xxx
# optional: mega.nz user for backup
export MEGA_USER=xxx
# optional: mega.nz user for backup
export MEGA_PWD=xxx
# optional: name of the remote mega.nz backup directory
export BACKUP_REMOTE_DIR=xxx
# the server will shutdown, when there are no players online for the given time 
# you can completely disable this by removing "bash idlekiller.sh $$ $MAX_IDLE_MINUTES &" from the entrypoint.sh script 
export MAX_IDLE_MINUTES=30