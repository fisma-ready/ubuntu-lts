set -e
echo "/dev/xvdl   /var   ext4   defaults,rw,nodev,nosuid,nobootwait   0   0" >> /etc/fstab
echo "/dev/xvdm   /var/log/audit   ext4   defaults,rw,nodev,nosuid,noexec,nobootwait   0   0" >> /etc/fstab
echo "/dev/xvdn   /home   ext4   defaults,rw,nodev,nosuid,noexec,nobootwait   0   0" >> /etc/fstab
echo "none   /run/shm   tmpfs   defaults,nodev,noexec,nosuid   0   0" >> /etc/fstab
