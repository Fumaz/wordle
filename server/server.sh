#!/bin/bash

# Set the port
PORT=5000

# Stop any program currently running on the set port
# switch directories
cd /usr/src/app/build/web/

# Start the server
echo 'Server starting on port' $PORT '...'
python3 -m http.server $PORT