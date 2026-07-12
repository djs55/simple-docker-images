# syntax=docker/dockerfile:1
#
# GIMP 3 (GTK3 GUI) on Wayland, software-rendered.
#
# Multiarch (amd64 + arm64) registry image. Build + push (OCI media types keep
# the run.sailor.* labels):
#   PUSH=true docker buildx bake --builder multiarch-builder gimp
#
# env/user/command come from the OCI image config (ENV / USER / CMD).

# GIMP 3 is GTK3 and speaks Wayland natively; GIMP 2.10 (bookworm) is GTK2 and
# would need XWayland, so this image tracks trixie (gimp 3.0).
ARG BASE_DEBIAN_DISTRO=trixie

FROM debian:${BASE_DEBIAN_DISTRO}-slim AS app-rootfs

ENV DEBIAN_FRONTEND=noninteractive

# Locale: prevents GTK/font rendering warnings.
RUN apt-get update \
 && apt-get install -y --no-install-recommends locales \
 && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && locale-gen \
 && rm -rf /var/lib/apt/lists/*

# GIMP 3 (GTK3) plus the Wayland + software-render runtime.
#   gimp                the GTK3 image editor (pulls the GTK3 + GEGL/babl runtime)
#   libgl1-mesa-dri     Mesa's software rasterizer (llvmpipe) for LIBGL_ALWAYS_SOFTWARE
#   adwaita-icon-theme  GTK stock icons (a Recommends; UI loses icons without it)
#   dbus                GIMP's GApplication registers on the session bus
#   libxkbcommon0       keyboard handling under Wayland
#   fonts-dejavu        text tool + rendering
#   ca-certificates     TLS
# No X server / XWayland is installed; GDK_BACKEND=wayland (below) forces the
# native Wayland backend.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      gimp \
      libgl1-mesa-dri \
      adwaita-icon-theme \
      dbus \
      libxkbcommon0 \
      xkb-data \
      fonts-dejavu \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Non-root user — GTK/GIMP store config + data under HOME.
RUN useradd -m -u 1000 -s /bin/bash user

# Environment for the container process (from the OCI image config on pull).
#   GDK_BACKEND=wayland       force the native Wayland backend (no XWayland)
#   LIBGL_ALWAYS_SOFTWARE=1   route GL through Mesa llvmpipe (no GPU in the guest)
#   GALLIUM_DRIVER=llvmpipe   ditto, belt-and-suspenders
#   LANG / LC_ALL             quiet locale warnings
ENV GDK_BACKEND=wayland \
    LIBGL_ALWAYS_SOFTWARE=1 \
    GALLIUM_DRIVER=llvmpipe \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    HOME=/home/user

RUN mkdir -p /proc /sys /dev /mnt/host /run /home/user/.config \
 && chown -R user:user /home/user

# Run as uid 1000 (user), not root, via the image's USER directive.
USER user

# App icon + title. titlebar=guest → borderless (GTK draws its own chrome).
LABEL run.sailor.icon=/usr/share/icons/hicolor/256x256/apps/gimp.png \
      run.sailor.titlebar=guest \
      org.opencontainers.image.title="GIMP (Linux)"

# Start a D-Bus session, then launch GIMP. /mnt/host is the host share — pass an
# image there to open it, e.g. append "/mnt/host/picture.png".
CMD ["/usr/bin/dbus-run-session", "/usr/bin/gimp"]
