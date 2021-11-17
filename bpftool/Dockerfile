FROM debian:bullseye
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install bpftool -y
ENTRYPOINT ["/usr/sbin/bpftool"]
