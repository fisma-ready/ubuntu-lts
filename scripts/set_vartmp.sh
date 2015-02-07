set -e
echo "mount -o bind,noexec,nodev,nosuid /tmp /var/tmp" >> /etc/init.d/vartmp
chown root:root /etc/init.d/vartmp
chmod 755 /etc/init.d/vartmp
update-rc.d vartmp defaults 01
