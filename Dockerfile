# Development environment container for server developers.
FROM fedora

LABEL maintainer "alexey@slaykovsky.com"
LABEL description "Complete development environment for MD server."
LABEL version "1.0"

RUN dnf update -yq
RUN dnf install -yq wget cmake make gcc gcc-c++ boost-devel \
	tar qt5-devel mariadb-devel clang git mariadb-libs mariadb

ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++
ENV CFLAGS "-Os -pipe -m64"
ENV CXXFLAGS "-Os -pipe -m64"
ENV WT_VERSION 3.3.6
ENV DOCKERIZE_VERSION v0.3.0

WORKDIR /tmp
RUN curl -o $WT_VERSION.tar.gz https://codeload.github.com/emweb/wt/tar.gz/$WT_VERSION
RUN tar xf $WT_VERSION.tar.gz
RUN sed -i "s:storage_engine:default_storage_engine:g" \
	/tmp/wt-$WT_VERSION/src/Wt/Dbo/backend/MySQL.C

RUN mkdir wt-build
WORKDIR wt-build
RUN cmake -DMYSQL_LIBRARY=mysqlclient \
	/tmp/wt-$WT_VERSION
RUN make -j$(nproc) install

WORKDIR /tmp
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
	&& tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
	&& rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

WORKDIR /

RUN rm -rf /usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}
RUN rm -rf /usr/share/{man,doc,info,gnome/help}
RUN rm -rf /usr/share/cracklib
RUN rm -rf /usr/share/i18n
RUN rm -rf /var/cache/*
RUN rm -rf /sbin/sln
RUN rm -rf /var/tmp/*
RUN rm -rf /tmp/*

RUN mkdir -p --mode=0755 /var/cache/ldconfig
RUN mkdir -p --mode=0755 /var/cache/dnf
