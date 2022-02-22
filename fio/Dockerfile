FROM alpine:latest AS build

RUN apk add alpine-sdk coreutils fuse git libaio libaio-dev linux-headers ioping inotify-tools make zlib-dev

RUN git clone https://github.com/axboe/fio
WORKDIR fio

RUN ./configure
RUN make -j`nproc`
RUN make install

FROM alpine:latest
RUN apk add --no-cache libaio
COPY --from=build /usr/local/bin/fio /fio

ENTRYPOINT ["/fio"]
CMD []
