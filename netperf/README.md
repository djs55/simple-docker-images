To run netperf:

```
brew install netperf
netserver -D
```

and then
```
docker run djs55/netperf -H host.docker.internal
```

