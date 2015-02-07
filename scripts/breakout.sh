###
# break out path
###

# Exit immediately if anything breaks.
set -e

# Defaults.
MOUNT=/mnt

function help {
    echo "Usage: breakout.sh [OPTION]"
    echo "Move bits of the root filesystem to a new device."
    echo " "
    echo "-d            device"
    echo "-s            source path"
    echo "-m            mount base path"
}

# Simple command line argument handling.
while getopts 'd:s:t:m:' flag
    
do
    case $flag in
        d) DEVICE=$OPTARG;;
        s) SOURCE_PATH=$OPTARG;;
	m) MOUNT=$OPTARG;;
        h) help; exit 0;;
        \?) help; exit 2;;
    esac
done

echo "Breaking out: $SOURCE_PATH onto ${DEVICE}..."

# Make a file filesystem.
mkfs -t ext4 /dev/$DEVICE

# Mount the volume we're creating.
mkdir $MOUNT/$DEVICE
mount /dev/$DEVICE $MOUNT/$DEVICE

# Sync to the new volume then dismount.
rsync -aXS $SOURCE_PATH/* $MOUNT/$DEVICE/
umount $MOUNT/$DEVICE

# Get the old path out of the way and make a new mount point.
mv $SOURCE_PATH ${SOURCE_PATH}.old
mkdir $SOURCE_PATH
mount /dev/$DEVICE $SOURCE_PATH

# Clean up.
rmdir $MOUNT/$DEVICE
