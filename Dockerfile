FROM alpine:3.10.3
MAINTAINER twright <spartas@gmail.com>
RUN apk update && apk upgrade && apk add python3 chromium chromium-chromedriver && rm -rf /var/cache/*

RUN pip3 install --upgrade pip
RUN pip3 install selenium bs4 requests

COPY ./bin /root/bin 
WORKDIR /root/bin
CMD ./example.py
