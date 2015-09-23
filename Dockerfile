FROM docker.io/angstroms/pg_audit_log:base
MAINTAINER Wattana Inthaphong <wattaint@gmail.com>

COPY src/package.json /
RUN npm install

WORKDIR /src