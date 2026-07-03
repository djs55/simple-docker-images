# syntax=docker/dockerfile:1
#
# Wireshark (Qt GUI) on Wayland, software-rendered.
#
# Multiarch (amd64 + arm64) registry image. Build + push with:
#   docker buildx build --platform linux/amd64,linux/arm64 \
#     -t djs55/wireshark:latest --push wireshark
# Run with:
#   sailor run --display --memory 2G djs55/wireshark:latest
#
# Pure OCI config (ENV / USER / CMD); sailor derives the guest env/user/command
# from the image config on pull. compositor-guest is linked into container-init
# and activated by the display.vsock_port kernel cmdline parameter.

ARG BASE_DEBIAN_DISTRO=bookworm

FROM debian:${BASE_DEBIAN_DISTRO}-slim AS app-rootfs

ENV DEBIAN_FRONTEND=noninteractive

# Locale: prevents Qt/font rendering warnings.
RUN apt-get update \
 && apt-get install -y --no-install-recommends locales \
 && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && locale-gen \
 && rm -rf /var/lib/apt/lists/*

# Install Wireshark's Qt GUI plus the Wayland + software-render runtime.
#   wireshark           the Qt GUI (pulls libwireshark, dumpcap, etc.)
#   qtwayland5          Qt's Wayland platform plugin (QT_QPA_PLATFORM=wayland)
#   libgl1-mesa-dri     Mesa's software rasterizer (llvmpipe) for LIBGL_ALWAYS_SOFTWARE
#   libcap2-bin         setcap — lets the wireshark-common postinst grant dumpcap
#                       CAP_NET_RAW,CAP_NET_ADMIN file caps (a Recommends, so it
#                       must be named explicitly under --no-install-recommends)
#   dbus                Wireshark/Qt expect a session bus
#   libxkbcommon0       keyboard handling under Wayland
#   fonts-dejavu        rendering
#   ca-certificates     TLS
# debconf preseed: make dumpcap capture-capable for non-root users. With
# install-setuid=true and libcap2-bin present, the postinst sets dumpcap to
# root:wireshark 0750 and applies cap_net_raw,cap_net_admin=ep — members of the
# wireshark group (see below) can then capture.
RUN echo "wireshark-common wireshark-common/install-setuid boolean true" \
      | debconf-set-selections \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      wireshark \
      qtwayland5 \
      libgl1-mesa-dri \
      libcap2-bin \
      dbus \
      libxkbcommon0 \
      xkb-data \
      fonts-dejavu \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Non-root user — Qt stores config under HOME. Add it to the `wireshark` group
# (created by wireshark-common above) so the capability-granted dumpcap can be
# executed for live capture.
RUN useradd -m -u 1000 -s /bin/bash user \
 && usermod -aG wireshark user

# Environment for the container process. sailor reads these from the OCI image
# config on pull — no manual /.container-env file.
#   QT_QPA_PLATFORM                force the Qt Wayland backend
#   QT_WAYLAND_DISABLE_WINDOWDECORATION  let the compositor draw decorations
#   LIBGL_ALWAYS_SOFTWARE          route GL through Mesa llvmpipe (only host path)
#   LANG / LC_ALL                  quiet locale warnings
ENV QT_QPA_PLATFORM=wayland \
    QT_WAYLAND_DISABLE_WINDOWDECORATION=1 \
    LIBGL_ALWAYS_SOFTWARE=1 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    HOME=/home/user

RUN mkdir -p /proc /sys /dev /mnt/host /run /home/user/.config \
 && chown -R user:user /home/user

# Run as uid 1000 (user), not root: sailor honours the image's USER directive.
USER user

# Start a D-Bus session, then launch Wireshark. sailor derives the container
# command from CMD. /mnt/host is the virtiofs host share — pass a .pcap there
# to open it, e.g. append "/mnt/host/capture.pcap".
CMD ["/usr/bin/dbus-run-session", "/usr/bin/wireshark"]
