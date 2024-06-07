# RetDec-Docker

Docker image that has RetDec executables installed.

Pull the latest docker image by running

```bash
docker pull ghcr.io/photonicgluon/retdec-docker:latest
```

For example, you can run `retdec-decompiler` using the command

```bash
docker run --rm -v `pwd`:/samples ghcr.io/photonicgluon/retdec-docker retdec-decompiler FILE_TO_ANALYSE
```
