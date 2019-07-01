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

###LibreNMS Docker
https://github.com/jarischaefer/docker-librenms
https://docs.librenms.org/Installation/Installation-Ubuntu-1604-Nginx/

NOTE: APP URL MUST BE THE LAN IP OF YOUR DOCKER HOST WITH PORT NUMBER. OTHERWISE PAGES WILL BE BROKEN.

1. docker run --rm jarischaefer/docker-librenms generate_key
KEY: base64:[key-is-generated-here-in-this-format]


2. create mariadb container
docker run --name librenms-mariadb \
--net=librenms-net --ip=[set-static-mariadb-container-ip] \
--restart unless-stopped \
--volume /media/data/container-data/librenms/db:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=[mysql-password] \
-d -P mariadb:latest

3. create librenms table

CREATE DATABASE librenms CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER 'librenms'@'localhost' IDENTIFIED BY 'librenms';
GRANT ALL PRIVILEGES ON librenms.*
TO 'librenms'@'localhost'
IDENTIFIED BY 'librenms'
;
GRANT ALL PRIVILEGES ON librenms.*
TO 'librenms'@'[librenms-container-ip]'
IDENTIFIED BY 'librenms'
;
FLUSH PRIVILEGES;
exit

3a. Install nano, edit /etc/mysql/mariadb.conf.d/50-server.cnf
apt update
apt install nano
nano /etc/mysql/mariadb.conf.d/50-server.cnf
add the following
innodb_file_per_table=1
lower_case_table_names=0

restart mysql container

4. run the librenms container
docker run \
--net=librenms-net --ip=[set-static-container-ip] \
-d \
-h librenms-8080 \
-p 8080:80 \
-e APP_KEY=base64:[app-key-previosly-generated]= \
-e DB_HOST=[db-container-ip] \
-e DB_NAME=[librenms] \
-e DB_USER=librenms \
-e DB_PASS=librenms \
-e BASE_URL=http://docker-host-ip:8080 \
-v /container-data/librenms/data/logs:/opt/librenms/logs \
-v /container-data/librenms/data/rrd:/opt/librenms/rrd \
--name librenms \
jarischaefer/docker-librenms


docker exec librenms setup_database
docker exec librenms create_admin
(admin / admin)


NOTE: HAVING SOME ISSUES WITH localhost vs IP address - graphics not showing up, links going back to localhost, might need to be on port 80 only...
https://github.com/jarischaefer/docker-librenms#running-the-container
- may need to run a separate Docker VM with LibreNMS as the only container

https://docs.librenms.org/Support/FAQ/#how-do-i-move-my-librenms-install-to-another-server


================================


### Gogs Git Server ### WIP ### NEED MORE INFORMATION TO GET IT RUNNING ###
docker run --name=gogs -p 10022:22 -p 10080:3000 -v /media/data/container-data/gogs:/data gogs/gogs
docker run --name=gogs --net=librenms-net --ip=[set-static-gogs-container-ip] --restart always -p 10022:22 -p 10080:3000 -v /media/data/container-data/gogs/data:/data gogs/gogs
### may need additional information on creating the repo


================================

### Oxidized Docker Setup
## from here... https://hub.docker.com/r/oxidized/oxidized/#running-with-docker
## removed the --rm tag so it doesn't exit cleanly?
docker run -v /media/data/container-data/oxidized:/root/.config/oxidized -p 8888:8888/tcp --privileged --restart always --name oxidized -t oxidized/oxidized:latest oxidized

### create router.db
cd /media/data/container-data/oxidized/
touch router.db
### add an IP or hostname and save the file

### set the config file, follow this template
### WARNING: IF YOU RESTART THE CONTAINER, YOU NEED TO STOP THE CONTAINER, REMOVE THE PID FILE FROM THE OXIDIZED FOLDER (rm pid) and START THE CONTAINER AGAIN BEFORE IT WILL WORK AGAIN
### REMOTE REPO IS FOR GIT BACKUP...SEE GOGS DOCKER CONFIG...UNCOMMENT THOSE LINES WHEN READY AND FOLLOW RESTART PROCEDURE
---
username: [username]
password: [password]
model: ios
interval: 3600
use_syslog: false
debug: false
threads: 30
timeout: 20
retries: 3
prompt: !ruby/regexp /^([\w.@-]+[#>]\s?)$/
rest: 0.0.0.0:8888
next_adds_job: false
vars:
  enable: [enable-password]
groups: {}
models: {}
pid: "/root/.config/oxidized/pid"
log: "/root/.config/oxidized/log"
input:
  default: ssh,telnet
  debug: true
  ssh:
    secure: false
output:
  default: git
  debug: true
  git:
    user: Oxidized
    email: o@example.com
    repo: "/root/.config/oxidized/devices.git"
source:
  default: csv
  csv:
    file: "/root/.config/oxidized/router.db"
    delimiter: !ruby/regexp /:/
    map:
      name: 0
      model: 1
      username: 2
      password: 3
    vars_map:
      enable: 4
model_map:
  cisco: ios
  asa: asa
  hp: procurve
hooks:
  push_to_remote:
    type: githubrepo
    events: [post_store]
    remote_repo: http://container-ip:3000/gogs/oxidized-backup.git
    username: [gogs-username]
    password: [gogs-password]


#####
PUT AUTO BACKUP FROM DOCKER TO EXTERNAL STORAGE INFO BELOW...NEED SAMBA/CIFS/CRON/FSTAB
