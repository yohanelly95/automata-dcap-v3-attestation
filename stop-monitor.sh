#!/bin/bash

# Check for running anvil processes
PIDS=$(pgrep -f anvil)

# Check if PIDS is not empty
if [ -n "$PIDS" ]; then
  echo "Stopping anvil with PIDs: $PIDS"
  for PID in $PIDS; do
    echo "Killing PID $PID"
    kill $PID
    # If the process does not stop, force kill it
    sleep 2
    if ps -p $PID > /dev/null; then
      echo "Force killing PID $PID"
      kill -9 $PID
    fi
  done
else
  echo "anvil is not running."
fi
