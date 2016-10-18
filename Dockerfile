FROM ubuntu:16.04

MAINTAINER Frankie GU <frankiegu@hotmail.com>
ENV DEBIAN_FRONTEND noninteractive
ENV USER root
ENV LANG C.UTF-8
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV SCALA_HOME /usr/local/share/scala
ENV SCALA_VERSION 2.11.8
ENV SBT_VERSION 0.13.8
ENV SBT_HOME /usr/local/share/sbt
ENV HOME /root
ENV GOPATH /usr/local/share/go
ENV PATH $PATH:${GOPATH}/bin:${SCALA_HOME}/bin:${MAVEN_HOME}/bin:${SBT_HOME}/bin


RUN echo "deb http://mirrors.163.com/ubuntu/ xenial main restricted universe multiverse" > /etc/apt/sources.list
RUN echo "deb http://mirrors.163.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.163.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.163.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.163.com/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.163.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.163.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.163.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get clean && apt-get update && \
    apt-get install -y --no-install-recommends wget curl vim ubuntu-desktop && \
    apt-get install -y gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal && \
    apt-get install -y tightvncserver && \
    mkdir /root/.vnc

ARG java_download_url=http://download.oracle.com/otn-pub/java/jdk/8u101-b13/jdk-8u101-linux-x64.tar.gz
ARG download_folder=/tmp
ARG java_archive="/tmp/jdk-8u101-linux-x64.tar.gz"
ARG java_name=/opt/jdk1.8.0_101"
RUN echo 'Downloading and installing JDK'
# remove -q for logging
RUN wget -q -O ${java_archive} --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "${java_download_url}"
RUN tar -zxf ${java_archive} -C /opt
RUN chown root:root ${java_name}
RUN update-alternatives --install /usr/bin/java java ${java_name}/bin/java 0
RUN rm ${java_archive}

RUN echo 'Downloading Go 1.6.3' && \
    wget https://storage.googleapis.com/golang/go1.6.3.linux-amd64.tar.gz -O /tmp/go.tar.gz -q && \
    echo 'Installing Go 1.6.3' && \
    tar -zxf /tmp/go.tar.gz -C $GOPATH && \
    rm -f /tmp/go.tar.gz


RUN echo 'Installing Scala' && \
    wget --quiet http://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz && \
    tar -xf scala-$SCALA_VERSION.tgz && \
    rm scala-$SCALA_VERSION.tgz && \
    mv scala-$SCALA_VERSION $SCALA_HOME

RUN curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C $SBT_HOME && \
    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built

ADD xstartup /root/.vnc/xstartup
ADD passwd /root/.vnc/passwd

RUN chmod 600 /root/.vnc/passwd

CMD /usr/bin/vncserver :1 -geometry 1280x800 -depth 24 && tail -f /root/.vnc/*:1.log

EXPOSE 5901
