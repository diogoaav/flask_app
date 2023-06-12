#!/bin/bash

APP_DIRECTORY="/root/app"
HOST="0.0.0.0"
PORT="5000"
USER="root"

# Create a systemd service unit file
SERVICE_FILE="/etc/systemd/system/flaskapp.service"

cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Flask Application
After=network.target

[Service]
User=$USER
WorkingDirectory=$APP_DIRECTORY
Environment="PATH=/usr/local/bin"
ExecStart=/usr/local/bin/gunicorn -b $HOST:$PORT app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new unit file
systemctl daemon-reload

# Enable and start the Flask application service
systemctl enable flaskapp
systemctl start flaskapp

echo "Flask application service created and started on $HOST:$PORT."
