FROM alpine:latest AS build
ARG SPARK_VERSION
COPY spark-${SPARK_VERSION}-bin-hadoop3.tgz /opt

RUN tar zxf spark-${SPARK_VERSION}-bin-hadoop3.tgz -C /opt



