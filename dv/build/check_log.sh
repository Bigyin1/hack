#!/bin/sh

# Check input argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 logfile"
    exit 1
fi

LOGFILE=$1

# Check log file
if [ ! -f "$LOGFILE" ]; then
    echo "Error: File $LOGFILE not found"
    exit 1
fi

# Check UVM_ERROR :    0
if ! grep -q "UVM_ERROR :    0" "$LOGFILE"; then
    printf "FAILED\n"
    exit 0
fi

# Check UVM_FATAL :    0
if ! grep -q "UVM_FATAL :    0" "$LOGFILE"; then
    printf "FAILED\n"
    exit 0
fi

# Check ** Error
if grep -q "\*\* Error" "$LOGFILE"; then
    printf "FAILED\n"
    exit 0
fi

# Check ** Fatal
if grep -q "\*\* Fatal" "$LOGFILE"; then
    printf "FAILED\n"
    exit 0
fi

# If all checks passed
printf "PASSED\n"
