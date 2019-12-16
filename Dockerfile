FROM python:3.8-buster AS build_env
MAINTAINER twright

COPY ./bin /root/bin
WORKDIR /root/bin

RUN pip3 install --upgrade pip
RUN pip install -r ./requirements.txt

FROM gcr.io/distroless/python3

COPY --from=build_env /root/bin /root/bin
COPY --from=build_env /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages

WORKDIR /root/bin
ENV PYTHONPATH=/usr/local/lib/python3.8/site-packages

CMD ["./example.py"]

