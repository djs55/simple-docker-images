# simple-docker-images

A set of simple Docker images containing utilities, published under
[`djs55`](https://hub.docker.com/u/djs55) on Docker Hub.

## Images

| Image | Base | Arch | Description |
|-------|------|------|-------------|
| [`djs55/wireshark`](wireshark/Dockerfile) | debian | amd64, arm64 | Wireshark Qt GUI on Wayland, software-rendered |
| [`djs55/tcpdump`](tcpdump/Dockerfile) | alpine | amd64, arm64 | `tcpdump` packet capture |
| [`djs55/erofs-utils`](erofs/Dockerfile) | alpine | amd64, arm64 | EROFS filesystem tools |
| [`djs55/bpftool`](bpftool/Dockerfile) | debian | amd64, arm64 | `bpftool` for inspecting BPF programs |
| [`djs55/fio`](fio/Dockerfile) | alpine | amd64, arm64 | `fio` flexible I/O tester (built from source) |
| [`djs55/hwloc`](hwloc/Dockerfile) | alpine | amd64, arm64 | `hwloc` hardware locality tools |
| [`djs55/opam`](opam/Dockerfile) | alpine | amd64, arm64 | OCaml `opam` package manager |
| [`djs55/netperf`](netperf/Dockerfile) | centos | amd64 | `netperf` network benchmark (see [netperf/README.md](netperf/README.md)) |

## Building & pushing

Multiarch builds are driven by [`docker-bake.hcl`](docker-bake.hcl) using
[`docker buildx`](https://docs.docker.com/build/bake/).

Build and push every image (amd64 + arm64) to Docker Hub:

```
docker buildx bake --push
```

Build and push a single image:

```
docker buildx bake --push wireshark
```

Build one image for your host architecture and load it into the local Docker
(a multiarch manifest can't be `--load`ed, so pin the platform):

```
docker buildx bake wireshark --set wireshark.platform=linux/amd64 --load
```

Override the registry or tag:

```
REGISTRY=ghcr.io/djs55 TAG=v1 docker buildx bake --push wireshark
```

