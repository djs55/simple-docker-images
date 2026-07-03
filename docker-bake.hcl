# Multiarch build/push definitions for the images in this repo.
#
# Build + push every image (amd64 + arm64) to Docker Hub:
#   docker buildx bake --push
#
# Build + push a single image:
#   docker buildx bake --push wireshark
#
# Build one image for your host arch and load it locally (multiarch can't
# --load, so override the platform):
#   docker buildx bake wireshark --set wireshark.platform=linux/amd64 --load
#
# Point at a different registry / tag:
#   docker buildx bake --push --set *.args.unused=x REGISTRY=ghcr.io/djs55 TAG=v1

variable "REGISTRY" {
  default = "djs55"
}

variable "TAG" {
  default = "latest"
}

variable "PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

function "tag" {
  params = [name]
  result = ["${REGISTRY}/${name}:${TAG}"]
}

group "default" {
  targets = ["wireshark", "tcpdump", "erofs", "bpftool", "fio", "hwloc", "opam"]
}

target "wireshark" {
  context    = "wireshark"
  dockerfile = "Dockerfile"
  platforms  = PLATFORMS
  tags       = tag("wireshark")
}

target "tcpdump" {
  context   = "tcpdump"
  platforms = PLATFORMS
  tags      = tag("tcpdump")
}

target "erofs" {
  context   = "erofs"
  platforms = PLATFORMS
  tags      = tag("erofs-utils")
}

target "bpftool" {
  context   = "bpftool"
  platforms = PLATFORMS
  tags      = tag("bpftool")
}

target "fio" {
  context   = "fio"
  platforms = PLATFORMS
  tags      = tag("fio")
}

target "hwloc" {
  context   = "hwloc"
  platforms = PLATFORMS
  tags      = tag("hwloc")
}

target "opam" {
  context   = "opam"
  platforms = PLATFORMS
  tags      = tag("opam")
}

# netperf installs a Mageia RPM that only ships for x86_64, so it is amd64-only
# and excluded from the default group. (Its Dockerfile also COPYs patterns/*,
# which is not present in the build context — build will fail until that is
# fixed; left as-is here per "don't rewrite the old Dockerfiles".)
target "netperf" {
  context   = "netperf"
  platforms = ["linux/amd64"]
  tags      = tag("netperf")
}
