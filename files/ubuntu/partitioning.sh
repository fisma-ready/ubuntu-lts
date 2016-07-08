###
# Script Environment
###

# Kill the script if anything fails.
set -e


###
# Partitioning Variables.
###

PARTITION_COUNT=4
PARTITION_TYPE=8300
PHYSICAL_DISK=/dev/xvdk
BLANK_TEST="Number"


###
## Partitioning Functions
###

# Grab the end of the largest available extent on disk.
free_end() 
{
  echo $(sgdisk $PHYSICAL_DISK -E);
}

# Grab the start of the largest available extent on disk.
free_start()
{
  echo $(sgdisk $PHYSICAL_DISK -F);
}

# How much space to we actually have to work with.
free_size() 
{
  echo  $(($(free_end) - $(free_start)));
}

# Simple check for existing partitions.
is_clean()
{
  echo $(sgdisk -p $PHYSICAL_DISK | tail -n1 | cut -f1 -d ' ');
}


###
# Partitioning Prep
###

# Make sure the disk is clean before we start carving things up.
if [[ $(is_clean) != $BLANK_TEST ]]
  then
    echo "The disk ${PHYSICAL_DISK} contains partitions." 
    echo "Found Layout:"
    echo $(sgdisk -p $PHYSICAL_DISK);
    echo " Exiting."
    exit 1;
  else
    sgdisk -og $PHYSICAL_DISK
fi

# Come up with a partition size, assuming equal size partitions.
part_size() 
{
  echo $(((($(free_end) - $(free_start))) / $PARTITION_COUNT));
}

PARTITION_SIZE=$(((($(free_end) - $(free_start))) / $PARTITION_COUNT));

# Determine where the new partition will end.
part_extent() 
{
  echo $(($(free_start) + $PARTITION_SIZE));
}


### 
# Partitioning Actions
###

# Carve up the disk. 
for PARTITION_NUM in `seq 1 $PARTITION_COUNT`;
do
  echo "Trying with:" $PARTITION_NUM
  if [[ $PARTITION_NUM == $PARTITION_COUNT ]]
    then
      sgdisk -n $PARTITION_NUM:$(free_start):$(free_end) -t $i:$PARTITION_TYPE $PHYSICAL_DISK
  else
    sgdisk -n $PARTITION_NUM:$(free_start):$(part_extent) -t $i:$PARTITION_TYPE $PHYSICAL_DISK
fi
done

# Show the resulting layout.
sgdisk -p $PHYSICAL_DISK


###
# LVM Actions
### 

# Create LVM physical volumes.
for PARTITION_NUM in `seq 1 $PARTITION_COUNT`;
do
  pvcreate /dev/xvdk${PARTITION_NUM}
done


###
# Backup Create
###

# Backup the paths we'll be remounting later on.
mkdir /homeBackup
mkdir /varBackup
rsync -aXS /home/* /homeBackup
rsync -aXS /var/* /varBackup

# Create a new LVM volume group from each of our physical volumes.
vgcreate securefolders /dev/xvdk1 /dev/xvdk2 /dev/xvdk3 /dev/xvdk4

# Creating LVM logical volumes using relative sizes here to avoid problems with extent counts that don't quite line up.
lvcreate --name temp -l 25%VG  securefolders
lvcreate --name variables -l 25%VG securefolders
lvcreate --name audits -l 25%VG securefolders
lvcreate --name house -l 100%FREE securefolders


###
# Filesystem Actions
### 

# Create file systems on each new 
echo "Creating file systems..."
mkfs.ext4 /dev/securefolders/temp
mkfs.ext4 /dev/securefolders/variables
mkfs.ext4 /dev/securefolders/audits
mkfs.ext4 /dev/securefolders/house


###
# Persistent Mount Configuration
###

# Set things up to remount on boot.
echo "Updating /etc/fstab..."
echo "/dev/securefolders/temp   /tmp   ext4   defaults,rw,nodev,nosuid,noexec   0   2" >> /etc/fstab
echo "/dev/securefolders/variables   /var   ext4   defaults,rw,nodev,nosuid,nobootwait   0   0" >> /etc/fstab
echo "/dev/securefolders/audits   /var/log/audit   ext4   defaults,rw,nodev,nosuid,noexec,nobootwait   0   0" >> /etc/fstab
echo "/dev/securefolders/house   /home   ext4   defaults,rw,nodev,nosuid,noexec,nobootwait   0   0" >> /etc/fstab
echo "/tmp /var/tmp none bind 0 0" >> /etc/fstab
echo "none   /run/shm   tmpfs   defaults,nodev,noexec,nosuid   0   0" >> /etc/fstab


###
# Mount Actions
###

echo "Mounting securefolders..."
mount /dev/securefolders/temp /tmp
mount /dev/securefolders/variables /var
mount /dev/securefolders/house /home

# Use a bind mount to remount our new /tmp in a second location.
mkdir /var/tmp
mount --bind /tmp /var/tmp

mkdir -p /var/log/audit
mount /dev/securefolders/audits /var/log/audit

# Secure shared memory.
mount -o remount,noexec,nosuid,nodev /run/shm


###
# Backup Restore
###
echo "Restoring /var..."
rsync -aXS /homeBackup/* /home

echo "Restoring /home..."
rsync -aXS /varBackup/* /var

echo "Cleaning up backups..."
rm -rf /homeBackup
rm -rf /varBackup


###
# APT Configuration
###

# Something to handle noexec on /tmp with breaking common adminstration.
echo 'DPkg::Pre-Install-Pkgs {"mount -o remount,exec /tmp";};' >> /etc/apt/apt.conf.d/50remount
echo 'DPkg::Post-Invoke {"mount -o remount /tmp";};' >> /etc/apt/apt.conf.d/50remount