# syntax=docker/dockerfile:1
#
# Wireshark (Qt GUI) on Wayland, software-rendered.
#
# Two ways to build:
#
#   Registry image (amd64 + arm64), pull-only:
#     PUSH=true docker buildx bake --builder multiarch-builder wireshark
#
#   Local EROFS (amd64), for testing without a registry round-trip:
#     docker buildx bake wireshark-erofs    # → wireshark/bin/wireshark.erofs
#
# On the registry path env/user/command come from the OCI image config
# (ENV / USER / CMD). The local EROFS has no OCI config, so the
# /.container-{env,user,entrypoint} files written below supply them instead.

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
# wireshark group (see below) can then capture. EROFS preserves the resulting
# security.capability xattr into the guest.
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

# Environment for the container process (from the OCI image config on pull).
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

# Run as uid 1000 (user), not root, via the image's USER directive.
USER user

# App icon + title. No titlebar label → default "host" (Qt draws no chrome).
LABEL run.sailor.icon=/usr/share/icons/hicolor/256x256/apps/org.wireshark.Wireshark.png \
      org.opencontainers.image.title="Wireshark (Linux)"

# Start a D-Bus session, then launch Wireshark. /mnt/host is the host share —
# pass a .pcap there to open it, e.g. append "/mnt/host/capture.pcap".
CMD ["/usr/bin/dbus-run-session", "/usr/bin/wireshark"]

# ── EROFS rootfs ────────────────────────────────────────────────────────────────
# The local EROFS path has no OCI config, so the env/user/command come from
# /.container-* files instead. These MUST NOT be baked into app-rootfs (the
# registry image): on the pull path /.container-entrypoint is only overwritten
# when the OCI entrypoint is non-empty, so a baked one would survive and get
# concatenated with the injected /.container-cmd — launching the command twice.
# Keep them in this erofs-only stage. Mirrors the ENV / USER / CMD above;
# /.container-env is KEY=VALUE per line.
FROM app-rootfs AS erofs-rootfs

USER root
RUN printf '%s\n' \
      'QT_QPA_PLATFORM=wayland' \
      'QT_WAYLAND_DISABLE_WINDOWDECORATION=1' \
      'LIBGL_ALWAYS_SOFTWARE=1' \
      'LANG=en_US.UTF-8' \
      'LC_ALL=en_US.UTF-8' \
      'HOME=/home/user' \
    > /.container-env \
 && echo 'user' > /.container-user \
 && printf '%s\n' \
      /usr/bin/dbus-run-session \
      /usr/bin/wireshark \
    > /.container-entrypoint

# ── Build EROFS ───────────────────────────────────────────────────────────────
FROM --platform=linux/amd64 debian:${BASE_DEBIAN_DISTRO}-slim AS erofs-builder

RUN apt-get update && apt-get install -y --no-install-recommends erofs-utils \
 && rm -rf /var/lib/apt/lists/*

COPY --from=erofs-rootfs / /rootfs/

RUN mkfs.erofs -z lz4 /wireshark.erofs /rootfs/

# ── Export ────────────────────────────────────────────────────────────────────
FROM scratch AS wireshark-erofs
COPY --from=erofs-builder /wireshark.erofs /wireshark.erofs
