su root

mkdir -p /var/www

cat << EOF > /etc/systemd/system/our-node-app.service
  [Service]
  WorkingDirectory=/var/www
  ExecStart=/usr/bin/nodejs boot.js
  ExecReload=/bin/kill -HUP $MAINPID
  Restart=always
  StandardOutput=syslog
  StandardError=syslog
  SyslogIdentifier=some-identifier-here-typically-matching-workingdirectory
  User=web
  Group=web
  Environment='NODE_ENV=production'

  [Install]
  WantedBy=multi-user.target
EOF

# service our-node-app start
# service --status-all | grep 'node'
# initctl list

# systemctl enable our-node-app
# systemctl start our-node-app
# systemctl status our-node-app
# journalctl -u node-sample # logs

# The following line carries out a zero-downtime restart
# See ExecReload in above service config
# systemctl reload our-node-app

# Try killing the Node process by its pid and see if it starts back up!
# e.g. kill -hup {pid}
