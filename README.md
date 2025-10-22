# fastreid_docker

```bash
docker build --network host -t=lxy_dev:v0.4 dockerfile

docker build \
  --build-arg HTTP_PROXY=http://127.0.0.1:37890 \
  --build-arg HTTPS_PROXY=http://127.0.0.1:37890 \
  --build-arg NO_PROXY=localhost,127.0.0.1 \
  -t l1aoxingyu/lxy_dev:ubuntu22_cu128 .

docker run --privileged --name lxy_dev -d -v /mnt:/mnt -v /data:/data --gpus all --user root --ipc host --net host -it lxy_dev:v0.4
```
