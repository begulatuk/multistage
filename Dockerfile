FROM alpine:latest as base
WORKDIR /usr/src/app

RUN apk --update add --no-cache && \
    apk add python3-dev py3-pip git \
    && apk add --no-cache --virtual .build-deps \
    build-base postgresql-dev  \
    libxslt-dev libffi-dev

RUN pip3 install --ignore-installed distlib pipenv \
    && python3 -m venv /app/venv && \
    /app/venv/bin/python3 -m pip install --upgrade pip

ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"



ADD https://raw.githubusercontent.com/SVR666/LoaderX-Bot/master/requirements.txt requirements.txt
RUN CFLAGS="-O0"  /app/venv/bin/python3 -m pip install -r requirements.txt && \
    apk del .build-deps && rm -rf /var/tmp/* && \
    rm -r /var/cache/apk/APKINDEX.* && rm -rf /var/cache/apk/* && \
    rm -rf requirements.txt
    
FROM alpine:latest as run

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"

RUN apk add --no-cache \
    python3 \
    bash curl wget \
    ffmpeg p7zip libffi  && \
    rm -rf /var/cache/apk/*

COPY --from=base /app/venv venv
