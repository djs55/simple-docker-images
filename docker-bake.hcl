# Multiarch build/push definitions for the images in this repo.
#
# Push is gated behind PUSH=true and uses OCI media types, which preserve the
# per-arch config labels (run.sailor.*). A plain `--push` uses Docker schema2
# and drops them, so prefer PUSH=true over the --push flag here.
#
# Build + push every image (amd64 + arm64) to Docker Hub:
#   PUSH=true docker buildx bake --builder multiarch-builder
#
# Build + push a single image:
#   PUSH=true docker buildx bake --builder multiarch-builder wireshark
#
# Build one image for your host arch and load it locally (multiarch can't
# --load, so override the platform):
#   docker buildx bake wireshark --set wireshark.platform=linux/amd64 --load
#
# Point at a different registry / tag:
#   PUSH=true REGISTRY=ghcr.io/djs55 TAG=v1 docker buildx bake --builder multiarch-builder

variable "REGISTRY" {
  default = "djs55"
}

variable "TAG" {
  default = "latest"
}

variable "PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

# Push only when PUSH=true. OCI media types preserve the run.sailor.* labels.
variable "PUSH" {
  default = false
}

function "image_output" {
  params = []
  result = ["type=image,oci-mediatypes=true,push=${PUSH}"]
}

function "tag" {
  params = [name]
  result = ["${REGISTRY}/${name}:${TAG}"]
}

group "default" {
  targets = ["wireshark", "gimp", "inkscape", "tcpdump", "erofs", "bpftool", "fio", "hwloc", "opam"]
}

target "wireshark" {
  context    = "wireshark"
  dockerfile = "Dockerfile"
  target     = "app-rootfs"
  platforms  = PLATFORMS
  tags       = tag("wireshark")
  output     = image_output()
}

target "gimp" {
  context    = "gimp"
  dockerfile = "Dockerfile"
  target     = "app-rootfs"
  platforms  = PLATFORMS
  tags       = tag("gimp")
  output     = image_output()
}

target "inkscape" {
  context    = "inkscape"
  dockerfile = "Dockerfile"
  target     = "app-rootfs"
  platforms  = PLATFORMS
  tags       = tag("inkscape")
  output     = image_output()
}

target "tcpdump" {
  context   = "tcpdump"
  platforms = PLATFORMS
  tags      = tag("tcpdump")
  output    = image_output()
}

target "erofs" {
  context   = "erofs"
  platforms = PLATFORMS
  tags      = tag("erofs-utils")
  output    = image_output()
}

target "bpftool" {
  context   = "bpftool"
  platforms = PLATFORMS
  tags      = tag("bpftool")
  output    = image_output()
}

target "fio" {
  context   = "fio"
  platforms = PLATFORMS
  tags      = tag("fio")
  output    = image_output()
}

target "hwloc" {
  context   = "hwloc"
  platforms = PLATFORMS
  tags      = tag("hwloc")
  output    = image_output()
}

target "opam" {
  context   = "opam"
  platforms = PLATFORMS
  tags      = tag("opam")
  output    = image_output()
}

# netperf installs a Mageia RPM that only ships for x86_64, so it is amd64-only
# and excluded from the default group. (Its Dockerfile also COPYs patterns/*,
# which is not present in the build context — build will fail until that is
# fixed; left as-is here per "don't rewrite the old Dockerfiles".)
target "netperf" {
  context   = "netperf"
  platforms = ["linux/amd64"]
  tags      = tag("netperf")
  output    = image_output()
}
