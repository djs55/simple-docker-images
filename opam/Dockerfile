FROM alpine:edge

RUN apk update && apk add opam alpine-sdk make m4 git shadow
# from https://hub.docker.com/r/ocaml/opam
RUN echo 'opam ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/opam
RUN chmod 440 /etc/sudoers.d/opam
RUN chown root:root /etc/sudoers.d/opam
RUN sed -i.bak 's/^Defaults.*requiretty//g' /etc/sudoers
RUN useradd -d /home/opam -m -s /bin/bash opam
RUN passwd -l opam
RUN chown -R opam:opam /home/opam
USER opam
ENV HOME /home/opam
WORKDIR /home/opam

RUN opam init --disable-sandbox --bare --no-setup
RUN opam switch create default 4.07.1
ENTRYPOINT ["opam","exec"]
LABEL maintainer="dave@recoil.org"
