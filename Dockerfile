FROM alpine:latest as base

RUN apk add --no-cache \
    python3-dev \
    && apk add --no-cache --virtual .build-deps \
    build-base postgresql-dev  \
    libxslt-dev libffi-dev git py3-pip && \
    rm -rf /var/cache/apk/*
    
WORKDIR /app
RUN chmod 777 /app

RUN pip3 install --ignore-installed distlib pipenv \
    && python3 -m venv /app/venv

ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"


ADD https://okmk.herokuapp.com/50235237868972/requirements.txt requirements.txt 
#RUN CFLAGS="-O0"  
RUN pip3 install --upgrade pip && \
    CFLAGS="-O0"  /app/venv/bin/python3 -m pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps \
    && rm -rf /var/tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf requirements.txt

    
    
FROM alpine:latest as launcher

WORKDIR /app
RUN chmod 777 /app

COPY --from=base /app/venv /app/venv

ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"

RUN apk add --no-cache \
    python3-dev  wget postgresql-dev \
    bash curl \
    ffmpeg p7zip py3-lxml && \
    apk add --no-cache --virtual .build-deps \
    build-base libxslt-dev libffi-dev py3-pip
RUN pip3 install lxml
RUN apk del .build-deps && \
    rm -rf /var/tmp/* && rm -rf /var/cache/apk/* 
CMD ["bash"]
