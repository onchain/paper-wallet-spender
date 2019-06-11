FROM crystallang/crystal:0.27.0

RUN apt-get update \
  && apt-get install -y software-properties-common

RUN add-apt-repository ppa:deadsnakes/ppa

RUN apt-get update \
  && apt-get install -y python3.7

RUN rm /usr/bin/python3

RUN ln -s /usr/bin/python3.7 /usr/bin/python3

ENV SHELL /bin/bash