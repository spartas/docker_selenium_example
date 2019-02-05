FROM alpine:3.9
MAINTAINER twright <spartas@gmail.com>
RUN apk update && apk upgrade

RUN apk add python3 chromium chromium-chromedriver

RUN pip3 install --upgrade pip
RUN pip3 install selenium bs4 requests

RUN rm -rf /var/cache/*

COPY ./bin /root/bin 

CMD ~/bin/example.py
