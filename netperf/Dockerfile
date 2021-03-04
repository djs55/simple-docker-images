FROM centos:latest

RUN curl https://distrib-coffee.ipsl.jussieu.fr/pub/linux/Mageia/distrib/cauldron/$(arch)/media/core/release/netperf-2.7.0-6.mga8.$(arch).rpm --output netperf-2.7.0-6.mga8.$(arch).rpm && rpm -Uvh netperf-2.7.0-6.mga8.$(arch).rpm

ENTRYPOINT [ "/usr/bin/netperf" ]
