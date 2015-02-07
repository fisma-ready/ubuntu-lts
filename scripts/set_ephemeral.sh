set -e
chown root:root /etc/init.d/ephemeral
chmod 755 /etc/init.d/ephemeral
update-rc.d ephemeral defaults 00
