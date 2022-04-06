FROM debian:jessie-slim


USER root

RUN apt-get update
RUN mkdir -p /usr/share/man/man1
RUN mkdir -p /usr/share/tomcat8/logs/
RUN mkdir -p /usr/share/tomcat8/conf/
RUN mkdir -p /usr/share/tomcat8/temp/

RUN apt-get -y install nano \
    && apt-get -y install sudo \
    && apt-get -y install curl \
    && apt-get -y install jq \
    && apt-get -y install openssh-server \
    && apt-get -y install default-jre-headless \
    && apt-get -y install supervisor

RUN apt-get -y install tomcat8

RUN useradd docker --shell /bin/bash \
    && passwd -d docker \
    && mkdir /home/docker \
    && chown docker:docker /home/docker \
    && addgroup docker staff \
    && addgroup docker sudo \
    && true
RUN echo 'docker:Unicorn0666!' | chpasswd && adduser docker sudo
RUN sed -i 's/.*PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config

COPY target/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY target/prisma-defender.sh /tmp/prisma-defender.sh

RUN rm -rf /usr/local/tomcat/webapps/*
ADD target/log4shell-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
EXPOSE 22

RUN service ssh start

CMD ["/usr/bin/supervisord"]
