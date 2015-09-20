FROM java:7
MAINTAINER John Paul Alcala jp@jpalcala.com

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && apt-get update && apt-get install -y curl rsync && rm -rf /var/lib/apt/lists/* \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

ENV MINECRAFT_HOME /opt/minecraft
ENV MINECRAFT_OPTS -server -Xmx1024m -XX:MaxPermSize=256m -XX:+UseParNewGC -XX:+UseConcMarkSweepGC
ENV WORLD_DIR /var/lib/minecraft

RUN groupadd -g 1000 minecraft && \
    useradd -g minecraft -u 1000 -r -M minecraft && \
    touch /run/first_time && \
    mkdir -p $MINECRAFT_HOME/world $WORLD_DIR

COPY spigot /usr/local/bin/
ONBUILD COPY . /etc/minecraft

EXPOSE 25565

VOLUME ["/opt/minecraft", "/var/lib/minecraft"]

ENTRYPOINT ["/usr/local/bin/spigot"]
CMD ["run"]
