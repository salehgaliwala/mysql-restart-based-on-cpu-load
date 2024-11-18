#!/bin/bash

# Log file location
LOG_FILE="/var/log/cpu_monitor.log"

# Function to check CPU load and restart MySQL service
check_and_restart_mysql() {
    # Fetch the 1-minute load average
    CPU_LOAD=$(uptime | awk -F'[a-z]:' '{ print $2 }' | cut -d, -f1 | xargs)

    # Convert load average to an integer for comparison
    CPU_LOAD_INT=$(echo $CPU_LOAD | awk -F. '{print $1}')

    # Threshold load average
    THRESHOLD=6

    # Log current CPU load
    echo "$(date): Current CPU load: $CPU_LOAD" >> "$LOG_FILE"

    if (( CPU_LOAD_INT > THRESHOLD )); then
        echo "$(date): High CPU load detected: $CPU_LOAD. Restarting MySQL service..." >> "$LOG_FILE"
        sudo systemctl stop mysql
        sleep 10  # Wait for 5 seconds to ensure MySQL is fully stopped
        sudo systemctl start mysql
        echo "$(date): MySQL service restarted." >> "$LOG_FILE"
    else
        echo "$(date): CPU load is normal: $CPU_LOAD. No action required." >> "$LOG_FILE"
    fi
}

# Ensure the log file exists and is writable
if [ ! -f "$LOG_FILE" ]; then
    sudo touch "$LOG_FILE"
    sudo chmod 644 "$LOG_FILE"
fi

# Main script loop to continuously monitor
while true; do
    check_and_restart_mysql
    sleep 60  # Check every 60 seconds
done
