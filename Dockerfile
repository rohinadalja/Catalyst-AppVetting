FROM ubuntu:18.04

WORKDIR /usr/src

RUN apt-get update
RUN apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg curl

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git \
      awscli 

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org

RUN mkdir Catalyst-AppVetting && \
    mkdir db && mkdir db_backups && \
    mkdir logs

WORKDIR /usr/src/Catalyst-AppVetting

COPY package.json package.json
COPY package-lock.json package-lock.json

RUN npm install -g

COPY ./controllers/createInitialUsers.js ./controllers/createInitialUsers.js
COPY ./models/userPackage.js ./models/userPackage.js
COPY ./mongoose/connection.js ./mongoose/connection.js
COPY .env createServiceUsers.sh createAdminUser.js config.js ./

ARG AVT_ENVIRONMENT=${AVT_ENVIRONMENT}
ARG AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ARG AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ARG AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
ARG AWS_REGION=${AWS_REGION}
ARG CATALYST_USER_EMAIL=${CATALYST_USER_EMAIL}
ARG CATALYST_USER_PASSWORD=${CATALYST_USER_PASSWORD}
ARG CATALYST_USER_FIRST_N=${CATALYST_USER_FIRST_N}
ARG CATALYST_USER_LAST_N=${CATALYST_USER_LAST_N}
ARG DB_USERNAME=${DB_USERNAME}
ARG DB_PASSWORD=${DB_PASSWORD}

RUN ./createServiceUsers.sh

COPY . .

# RUN aws configure

# RUN restoreFromBackup or set a new backup bucket



EXPOSE 8000
CMD ./script/docker-start.sh