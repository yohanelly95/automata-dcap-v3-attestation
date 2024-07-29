#!/bin/bash

# Find the PID of monitor.sh
PID=$(ps aux | grep 'monitor.sh' | awk '{print $2}')
echo "PID=$PID"
# Check if PID is not empty
if [ -n "$PID" ]; then
  echo "Stopping monitor.sh with PID $PID"
  kill $PID
  # If the process does not stop, force kill it
  sleep 2
  if ps -p $PID > /dev/null; then
    echo "Force killing monitor.sh with PID $PID"
    kill -9 $PID
  fi
else
  echo "monitor.sh is not running."
fi
