FROM alpine:latest as base
WORKDIR /usr/src/app

RUN apk --update add --no-cache && \
    apk add python3-dev py3-pip \
    && apk add --no-cache --virtual .build-deps \
    build-base postgresql-dev  \
    libxslt-dev libffi-dev git py3-pip

RUN pip3 install --upgrade pip && \
    pip3 install --ignore-installed distlib pipenv \
    && python3 -m venv /app/venv
#     /app/venv/bin/python3 -m pip install --upgrade pip

ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"

COPY requirements.txt .
#RUN /app/venv/bin/python3 -m pip install --no-cache-dir -r requirements.txt && \
#RUN CFLAGS="-O0"  pip3 install -r requirements.txt && \
RUN pip3 install --no-cache-dir -r requirements.txt && \
    rm -r /var/cache/apk/APKINDEX.* && rm -rf /var/cache/apk/* && \
    apk del .build-deps && rm -rf /var/tmp/* && \
    rm -rf requirements.txt 


FROM alpine:latest as run

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"

RUN apk add --no-cache \
    python3-dev \
    bash curl wget \
    ffmpeg p7zip libmagic && \
    rm -rf /var/cache/apk/*

COPY --from=base /app/venv venv
COPY extract /usr/local/bin
RUN chmod +x /usr/local/bin/extract
COPY . .
COPY netrc /root/.netrc
RUN chmod +x aria.sh
CMD ["bash", "start.sh"]
