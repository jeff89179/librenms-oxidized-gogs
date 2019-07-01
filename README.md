# librenms-oxidized-gogs
Docker containers for LibreNMS, Oxidized, Gogs (L.O.G) and Portainer.

DOCKER LIBRENMS/OXIDIZED/GOGS (L.O.G) STACK ... with Portainer for management

###
CONFIGURE ALL CONTAINERS TO BE ON THE librenms-net Docker network
MAKE SURE ALL CONTAINERS HAVE A RESTART POLICY OF UNLESS STOPPED (PORTAINER SHOULD BE ALWAYS RESTART)

###
## My environment is set up with separated paths and VHDs for docker containers. If you see this kind of path or similar - feel free to modify and change it to your needs ##
/media/data/container-data/
###

### See individual setup files in repo.

### Order of operations
1. PORTAINER
2. LibreNMS
3. OXIDIZED
4. GOGS
5. (Optional) Rsync to backup Gogs/Oxidized git repos to remote location via FSTAB

#####
PENDING: PUT AUTO BACKUP FROM DOCKER TO EXTERNAL STORAGE INFO BELOW...NEED SAMBA/CIFS/CRON/FSTAB
