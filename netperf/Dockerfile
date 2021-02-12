FROM centos:latest

RUN curl https://distrib-coffee.ipsl.jussieu.fr/pub/linux/Mageia/distrib/cauldron/aarch64/media/core/release/netperf-2.7.0-6.mga8.aarch64.rpm --output netperf-2.7.0-6.mga8.aarch64.rpm && rpm -Uvh netperf-2.7.0-6.mga8.aarch64.rpm

ENTRYPOINT [ "/usr/bin/netperf" ]
