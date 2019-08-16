#!/bin/bash
#22 22 * * * /postgresBackupScript.sh
#Destination info: (nfs) nfs-server.domain.com 192.168.1.66
echo "start"

NFS DATA
#NFSFSDAT="192.168.1.66:/mnt/backup/proj/name:/backups:auto,nofail,noatime,nolock,intr,tcp,actimeo=1800:0:0"
#  NFSSVR=`echo $NFSFSDAT | cut -d: -f1`
#  EXPFS=`echo $NFSFSDAT | cut -d: -f2`
#  MNTPT=`echo $NFSFSDAT | cut -d: -f3`
#  MNTOPTS=`echo $NFSFSDAT | cut -d: -f4`
  NFSSVR='192.168.1.66'
  EXPFS='/mnt/backup/proj/name'
  MNTPT='/backups'
  MNTOPTS='auto,nofail,noatime,nolock,intr,tcp,actimeo=1800:0:0'

function nfs_check(){
  # Test to see if the NFS filesystem is not mounted. If so, we proceed.
  # If it is we drop through to the bottom of the loop.
  if [ -z "`mount | grep nfs | grep ${NFSSVR}:${EXPFS}`" ] ; then
    # Ping $NFSSVR and test if alive
    if ping -c 3 $NFSSVR -q > /dev/null; then
      if [ -n "`showmount -e $NFSSVR | grep $EXPFS`" ] ; then
        # NFS server is up so perform mount
        echo "Mounting ${NFSSVR}:${EXPFS}..."
        mount -t nfs -o ${MNTOPTS} ${NFSSVR}:${EXPFS} ${MNTPT} && { echo "Successfully mounted"; return 0; }
      else
        echo "NFS server ${NFSSVR} is not exporting ${EXPFS}. Not mounted."
        return 1
      fi #showmount
    else
      echo "NFS server not reachable. Not mounting ${NFSSVR}:${EXPFS}."
      return 1
    fi #ping
  else #-z mount
    echo "${NFSSVR}:${EXPFS} is already mounted"
    return 0
  fi
  echo "NFS mount failed"
  return 1 
}

if ! nfs_check; then
  exit 1
fi

#Postgres Backup Command
#docker exec -t postgres_postgres_1 pg_dumpall -c -U postgres | gzip > /backups/dump_`date +%d-%m-%Y"_"%H_%M_%S`.gz
#KEEP THE LAST 3 DUMP and delete the older ones
#find /backups/dump_* -mtime +3 -exec rm {} \;
