# Ubuntu Desktop Dockerfile

Docker container for Ubuntu 16.04 including ubuntu-desktop and vncserver.

# How to run

Build yourself
```
git clone https://github.com/frankiegu/docker-ubuntu-desktop.git
docker build --rm -t frankie/ubuntu-desktop docker-ubuntu-desktop
```

and then connect to:
```
docker run -p 5901:5901 -it frankie/ubuntu-desktop /bin/bash
```

`vnc://<host>:5901` via VNC client.
