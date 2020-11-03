FROM alpine:latest as base

RUN apk --update add --no-cache \
    python3-dev py3-pip git \
    && apk add --no-cache --virtual .build-deps \
    build-base postgresql-dev  \
    libxslt-dev libffi-dev

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

RUN pip3 install --ignore-installed distlib pipenv \
    && python3 -m venv /app/venv && \
    /app/venv/bin/python3 -m pip install --upgrade pip && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"



ADD https://raw.githubusercontent.com/SVR666/LoaderX-Bot/master/requirements.txt requirements.txt
#RUN CFLAGS="-O0"  
RUN /app/venv/bin/python3 -m pip install --no-cache -r requirements.txt && \
    apk del .build-deps 
#    && rm -rf /var/tmp/* && \
#    rm -r /var/cache/apk/APKINDEX.* && rm -rf /var/cache/apk/* && \
#    rm -rf requirements.txt
    
FROM alpine:latest as run

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"

RUN apk add --no-cache \
    python3 \
    bash curl wget \
    ffmpeg p7zip && \
    rm -rf /var/cache/apk/*

COPY --from=base /app/venv venv
