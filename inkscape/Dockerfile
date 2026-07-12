# syntax=docker/dockerfile:1
#
# Inkscape (GTK3 GUI) on Wayland, software-rendered.
#
# Multiarch (amd64 + arm64) registry image. Build + push (OCI media types keep
# the run.sailor.* labels):
#   PUSH=true docker buildx bake --builder multiarch-builder inkscape
#
# env/user/command come from the OCI image config (ENV / USER / CMD).

# Inkscape 1.x is GTK3 and speaks Wayland natively (no XWayland). trixie ships
# inkscape 1.4.
ARG BASE_DEBIAN_DISTRO=trixie

FROM debian:${BASE_DEBIAN_DISTRO}-slim AS app-rootfs

ENV DEBIAN_FRONTEND=noninteractive

# Locale: prevents GTK/font rendering warnings.
RUN apt-get update \
 && apt-get install -y --no-install-recommends locales \
 && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && locale-gen \
 && rm -rf /var/lib/apt/lists/*

# Inkscape (GTK3) plus the Wayland + software-render runtime.
#   inkscape            the GTK3 vector editor
#   libgl1-mesa-dri     Mesa's software rasterizer (llvmpipe) for LIBGL_ALWAYS_SOFTWARE
#   adwaita-icon-theme  GTK stock icons (a Recommends; UI loses icons without it)
#   dbus                Inkscape's GApplication registers on the session bus
#   libxkbcommon0       keyboard handling under Wayland
#   fonts-dejavu        text tool + rendering
#   ca-certificates     TLS
# No X server / XWayland is installed; GDK_BACKEND=wayland (below) forces the
# native Wayland backend.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      inkscape \
      libgl1-mesa-dri \
      adwaita-icon-theme \
      dbus \
      libxkbcommon0 \
      xkb-data \
      fonts-dejavu \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Non-root user — GTK/Inkscape store config under HOME.
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
LABEL run.sailor.icon=/usr/share/icons/hicolor/256x256/apps/org.inkscape.Inkscape.png \
      run.sailor.titlebar=guest \
      org.opencontainers.image.title="Inkscape (Linux)"

# Start a D-Bus session, then launch Inkscape. /mnt/host is the host share —
# pass an SVG there to open it, e.g. append "/mnt/host/drawing.svg".
CMD ["/usr/bin/dbus-run-session", "/usr/bin/inkscape"]
