su root

mkdir -p /var/www

# Following systemd installation details taken from:
# https://wiki.ubuntu.com/systemd

# systemd and related packages are available on PPA (Personal Package Archive)
add-apt-repository ppa:pitti/systemd
apt-get update

# install systemd alongside upstart
apt-get install systemd libpam-systemd systemd-ui

# machine will still boot under the upstart service
# to boot under systemd the following argument must be specified on the kernel command line
init=/lib/systemd/systemd

# Note that the systemd binary resides now in /lib/systemd/
# and /bin/systemd is just a symlink to it
# to boot under systemd by default, edit /etc/default/grub like so:
sed s/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash init=/lib/systemd/systemd"/ /etc/default/grub

# Make the change to grub take effect
update-grub

# systemd prints a warning on boot:
# /etc/mtab is not a symlink or not pointing to /proc/self/mounts
# It is not only mount that will behave incorrectly otherwise,
# but also df and probably most other commands that look at the
# list of mounted filesystems. Fix it with the following line:
ln -fs /proc/self/mounts /etc/mtab

cat << 'EOF' > /etc/systemd/system/our-node-app.service
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

systemctl list-units
systemctl enable our-node-app
systemctl start our-node-app
systemctl status our-node-app
journalctl -u our-node-app # logs

# The following line carries out a zero-downtime restart
# See ExecReload in above service config
# systemctl reload our-node-app

# Try killing the Node process by its pid and see if it starts back up!
# e.g. kill -hup {pid}
