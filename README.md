# Ubuntu Desktop Dockerfile

Docker container for Ubuntu 16.04 including ubuntu-desktop and vncserver.

# How to run

Build yourself
```
git clone https://github.com/frankiegu/docker-ubuntu-desktop.git
docker build --rm -t frankie/ubuntu-desktop docker-ubuntu-desktop
```

To run with customized settings

```
docker run -P --name postgres -p 5901:5901 -e USER=frankie -e PASSWORD=mars -e SCHEMA=mars -e ENCODING=UTF8 frankie/ubuntu-desktop
```

This will create a new container with the username and schema of mars encoded in UTF-8 and a password of mars

`vnc://<host>:5901` via VNC client.


##Container Linking##
Here are some examples of linking containers to postgresql

First we create a container, here I am using a random password generated from openssl

```
frankie@ubuntu:~$ docker run -P --name postgres -e PASSWORD=`openssl rand -hex 10` -e USER=frankie -e SCHEMA=test frankie/ubuntu-desktop

Waiting for PostgreSQL to start
Below are your configured options.
================
USER: frankie
PASSWORD: 5387fc737962925e2c70
SCHEMA: test
POSTGIS: false
ENCODING: SQL_ASCII
================
2014-04-21 21:07:24 UTC LOG:  database system was shut down at 2014-04-21 04:34:43 UTC
2014-04-21 21:07:24 UTC LOG:  autovacuum launcher started
2014-04-21 21:07:24 UTC LOG:  database system is ready to accept connections
CREATE USER
With the postgres container up and running, lets create a new container and link it with an alias of db.
```

```
frankie@ubuntu:~$ docker run -i -t --link postgres:db ubuntu /bin/bash
```

Now from inside the container ensure you have a postgresql client installed.

```
root@47b16d7d1e13:/# apt-get install postgresql-client
```

You can now connect to the database in a variety of ways. lets first inspect the environment. The variables of interest here are all prefixed with DB_

```
root@47b16d7d1e13:/# env
HOSTNAME=47b16d7d1e13
DB_NAME=/cocky_babbage/db
TERM=xterm
DB_PORT_5432_TCP_ADDR=172.17.0.2
DB_ENV_SCHEMA=test
DB_PORT=tcp://172.17.0.2:5432
DB_PORT_5432_TCP=tcp://172.17.0.2:5432
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PWD=/
DB_ENV_PASSWORD=5387fc737962925e2c70
DB_PORT_5432_TCP_PORT=5432
SHLVL=1
HOME=/
DB_ENV_USER=frankie
DB_PORT_5432_TCP_PROTO=tcp
_=/usr/bin/env
```

Connect manually.


```
root@47b16d7d1e13:/# psql -h 172.17.0.2 -U frankie test
Password for user frankie:
psql (9.1.13, server 9.3.4)
WARNING: psql version 9.1, server version 9.3.
     Some psql features might not work.
SSL connection (cipher: DHE-RSA-AES256-SHA, bits: 256)
Type "help" for help.
test=#
```

Connect using ENV variables.

```
root@47b16d7d1e13:/# PGPASSWORD=$DB_ENV_PASSWORD psql -h $DB_PORT_5432_TCP_ADDR -U $DB_ENV_USER $DB_ENV_SCHEMA
psql (9.1.13, server 9.3.4)
WARNING: psql version 9.1, server version 9.3.
     Some psql features might not work.
SSL connection (cipher: DHE-RSA-AES256-SHA, bits: 256)
Type "help" for help.
test=#
```

Create an application friendly URI.

```
root@47b16d7d1e13:/# export DB_URI=postgres://$DB_ENV_USER:$DB_ENV_PASSWORD@$DB_PORT_5432_TCP_ADDR:$DB_PORT_5432_TCP_PORT/$DB_ENV_SCHEMA
root@47b16d7d1e13:/# echo $DB_URI
postgres://frankie:5387fc737962925e2c70@172.17.0.2:5432/test
```

##Data Volumes##
The following directories are setup as volumes and can be accessed from other containers.

```
/etc/postgresql
/var/lib/postgresql
/var/log/postgresql
```

Example of connecting the volumes to a container.

```
frankie@ubuntu:~$ docker run --volumes-from postgres -i -t ubuntu bash
root@6c3e9e61530f:/# mount |grep postgresql
/dev/disk/by-uuid/cb08824e-c579-4fbc-8fea-668fafa212cc on /etc/postgresql type ext4 (rw,relatime,errors=remount-ro,data=ordered)
/dev/disk/by-uuid/cb08824e-c579-4fbc-8fea-668fafa212cc on /var/lib/postgresql type ext4 (rw,relatime,errors=remount-ro,data=ordered)
/dev/disk/by-uuid/cb08824e-c579-4fbc-8fea-668fafa212cc on /var/log/postgresql type ext4 (rw,relatime,errors=remount-ro,data=ordered)
```

##Environment Variables##

This is a list of the available environment variables which can be set at runtime using -e KEY=value.
For example, to change the default password you can issue docker run -P --name postgresql -e PASSWORD=mysecretpassword frankie/ubuntu-desktop

USER: A superuser role. default: postgres
PASSWORD: The password for the user. default: postgres
SCHEMA: Name of schema to create. default: postgres
ENCODING: Encoding of the schema we are about to create. default: SQL_ASCII
POSTGIS: Enable PostGIS extensions on the schema.

##Backups##
Be sure to run regular backups of any production databases. This can be handled in many different ways and I will not go into details here about how you should handle your backups. For additional information on backing up databases refer to the PostgreSQL 9.4 Documentation on Backups