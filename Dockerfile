FROM alpine:latest as base

RUN apk add --no-cache \
    python3-dev py3-pip \
    && apk add --no-cache --virtual .build-deps \
    build-base postgresql-dev git \
    libxslt-dev libffi-dev && \
    rm -rf /var/tmp/* && \
    rm -rf /var/cache/apk/*
WORKDIR /app

RUN pip3 install --ignore-installed distlib pipenv \
    && python3 -m venv venv

ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/venv"


ADD https://raw.githubusercontent.com/SVR666/LoaderX-Bot/master/requirements.txt requirements.txt 
#RUN CFLAGS="-O0"  
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt \
    && apk del .build-deps \
    && rm -rf /var/tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf requirements.txt

    
    
FROM alpine:latest as launcher

WORKDIR /home/launcher

COPY --from=base /app/venv /home/launcher/venv

ENV PATH="/home/launcher/venv/bin:$PATH" VIRTUAL_ENV="/venv"

RUN apk add --no-cache \
#    python3 \
    bash curl wget \
    ffmpeg p7zip && \
    rm -rf /var/cache/apk/*

CMD ["bash"]
