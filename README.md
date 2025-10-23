# fastreid_docker

```bash
export PROXY=http://127.0.0.1:37890
export NO_PROXY=localhost,127.0.0.1,::1

docker build \
  --network=host \
  --build-arg HTTP_PROXY=$PROXY \
  --build-arg HTTPS_PROXY=$PROXY \
  --build-arg NO_PROXY=$NO_PROXY \
  --build-arg http_proxy=$PROXY \
  --build-arg https_proxy=$PROXY \
  --build-arg no_proxy=$NO_PROXY \
  -t l1aoxingyu/lxy_dev:ubuntu22_cu128 .

docker run --privileged --name lxy_dev -d -v /mnt:/mnt -v /data:/data --gpus all --user root --ipc host --net host -it lxy_dev:v0.4
```
