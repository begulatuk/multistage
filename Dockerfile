FROM alpine:latest as base

RUN apk add --no-cache \
    python3-dev py3-pip git \
    && apk add --no-cache --virtual .build-deps \
    build-base postgresql-dev  \
    libxslt-dev libffi-dev

#WORKDIR /app
#RUN chmod 777 /app

RUN pip3 install --ignore-installed distlib pipenv \
    && python3 -m venv usr/src/app/venv && \
    usr/src/app/venv/bin/python3 -m pip install --upgrade pip

ENV PATH="usr/src/app/venv/bin:$PATH" VIRTUAL_ENV="usr/src/app/venv"



ADD https://raw.githubusercontent.com/SVR666/LoaderX-Bot/master/requirements.txt requirements.txt
#RUN CFLAGS="-O0"  
RUN /usr/src/app/venv/bin/python3 -m pip install --no-cache -r requirements.txt \
    && apk del .build-deps \
    && rm -rf /var/tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf requirements.txt
    
COPY . .
    
FROM alpine:latest as run

COPY --from=base /usr/src/app/venv /app/venv

#WORKDIR /app
#RUN chmod 777 /app

ENV PATH="usr/src/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"

RUN apk add --no-cache \
    python3 \
    bash curl wget \
    ffmpeg p7zip && \
    rm -rf /var/cache/apk/*

CMD ["bash"]
