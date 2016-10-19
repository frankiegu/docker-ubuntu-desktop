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
    apt-get install -y inotify-tools \
    supervisor \
    tightvncserver && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /root/.vnc

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-9.4 \
    postgresql-contrib-9.4 \
    postgresql-client-9.4

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
    wget https://storage.googleapis.com/golang/go1.6.3.linux-amd64.tar.gz -O go.tar.gz -q && \
    echo 'Installing Go 1.6.3' && \
    tar -zxf go.tar.gz && \
    mv go $GOPATH && \
    rm -f go.tar.gz

RUN echo 'Installing Scala' && \
    wget --quiet http://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz && \
    tar -xf scala-$SCALA_VERSION.tgz && \
    rm scala-$SCALA_VERSION.tgz && \
    mv scala-$SCALA_VERSION $SCALA_HOME

RUN curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local/share && \
    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built

ADD xstartup /root/.vnc/xstartup
ADD passwd /root/.vnc/passwd

RUN chmod 600 /root/.vnc/passwd

RUN mkdir -p /var/run/supervisor \
  && chown -R postgres:postgres /var/run/supervisor

ADD docker-assets/ /

RUN chown postgres:postgres /usr/local/bin/postgres.sh /usr/local/etc/pg_backup.config \
  && chmod +x /usr/local/bin/postgres.sh \
  && chmod +x /usr/local/bin/pg_backup.sh \
  && chmod +x /usr/local/bin/log_watch.sh \
  && chown -R postgres:postgres /var/run/postgresql /var/backups /usr/local/etc

# Initial default user/pass and schema
ENV USER postgres
ENV PASSWORD postgres
ENV SCHEMA postgres
ENV POSTGIS false
ENV ENCODING SQL_ASCII

# Database backup settings
ENV BACKUP_ENABLED false
ENV BACKUP_FREQUENCY daily

# TODO implement these
ENV BACKUP_RETENTION 7
ENV BACKUP_EMAIL postgres
ENV ENVIRONMENT development

RUN echo "listen_addresses='*'" >> /etc/postgresql/9.4/main/postgresql.conf \
  && echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.4/main/pg_hba.conf

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql", "/var/backups"]

RUN touch /var/lib/postgresql/firstrun

EXPOSE 5432

CMD /usr/bin/vncserver :1 -geometry 1280x800 -depth 24 && tail -f /root/.vnc/*:1.log
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE 5901
