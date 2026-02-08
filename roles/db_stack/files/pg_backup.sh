#!/bin/sh

LOG_FILE="$BACKUP_DIR/backup.log"

[ -z "$BACKUP_RETENTION_DAYS" ] && BACKUP_RETENTION_DAYS=7

while true
do
    BACKUP_FILE="$BACKUP_DIR/backup_$(date +%F_%H-%M).sql.gz"
    echo "[INFO] Starting backup at $(date)" >> "$LOG_FILE"

    /usr/bin/pg_dump -U "$POSTGRES_USER" -h postgres -d "$POSTGRES_DB" 2>>"$LOG_FILE" | gzip > "$BACKUP_FILE"
    if [ $? -eq 0 ]; then
        echo "[INFO] Backup created: $BACKUP_FILE at $(date)" | tee -a "$LOG_FILE"
    else
        echo "[ERROR] Backup failed at $(date)" | tee -a "$LOG_FILE"
    fi

    for f in $(find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +"$BACKUP_RETENTION_DAYS"); do
        rm -f "$f"
        echo "[INFO] Deleted old backup: $f at $(date)" | tee -a "$LOG_FILE"
    done

    sleep 86400
done