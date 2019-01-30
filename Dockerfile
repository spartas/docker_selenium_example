# Chromium seems to be busted on the latest alpine, so I'll use alpine 3.8
FROM alpine:3.8
MAINTAINER twright <spartas@gmail.com>
RUN apk update && apk upgrade

RUN apk add python3 curl mesa-gles chromium mesa-egl zlib-dev xvfb xorg-server dbus ttf-freefont udev chromium-chromedriver

RUN pip3 install --upgrade pip
RUN pip3 install selenium bs4 requests

# Bug Chrome 64
RUN mkdir /usr/lib/chromium/swiftshader/ \
    && cp /usr/lib/libGLESv2.so.2 /usr/lib/chromium/swiftshader/libGLESv2.so \
    && cp /usr/lib/libEGL.so.1 /usr/lib/chromium/swiftshader/libEGL.so
RUN rm -rf /var/cache/*

COPY ./bin /root/bin 

CMD ~/bin/example.py
