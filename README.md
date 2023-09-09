# fastreid_docker

```bash
docker build --network host -t=lxy_dev:v0.4 dockerfile

docker run --privileged --name lxy_dev -d -v /mnt:/mnt -v /data:/data --gpus all --user root --ipc host --net host -it lxy_dev:v0.4
```
