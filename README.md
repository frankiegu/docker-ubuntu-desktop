# Ubuntu Desktop Dockerfile

Docker container for Ubuntu 16.04 including ubuntu-desktop and vncserver.

# How to run

Build yourself
```
git clone https://github.com/fcwu/docker-ubuntu-vnc-desktop.git
docker build --rm -t frankie/ubuntu-desktop docker-ubuntu-desktop
```

and then connect to:

`vnc://<host>:5901` via VNC client.
