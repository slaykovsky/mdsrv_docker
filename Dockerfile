# Development environment container for server developers.
FROM fedora

MAINTAINER Alexey Slaykovsky <alexey@slaykovsky.com>

RUN dnf update -yq
RUN dnf install -yq wget cmake make mysql++-devel gcc \
	gcc-c++ boost-devel tar qt5-devel community-mysql \
	clang iputils

ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++

ENV CFLAGS "-Wall -O2 -pipe -msse -m64"
ENV CXXFLAGS "-Wall -O2 -pipe -msse -m64"

ENV WT_VERSION 3.3.6
WORKDIR /tmp
RUN curl -o $WT_VERSION.tar.gz https://codeload.github.com/emweb/wt/tar.gz/$WT_VERSION
RUN tar xf $WT_VERSION.tar.gz
RUN sed -i "s:storage_engine:default_storage_engine:g" \
	/tmp/wt-$WT_VERSION/src/Wt/Dbo/backend/MySQL.C
RUN mkdir wt-build
WORKDIR wt-build
RUN cmake /tmp/wt-$WT_VERSION
RUN make -j$(nproc) install

ENV DOCKERIZE_VERSION v0.3.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
	&& tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
	&& rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN rm -rf /var/cache/*
RUN rm -rf /var/tmp/*
RUN rm -rf /tmp/*
