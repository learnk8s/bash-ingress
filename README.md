# An ingress controller written in bash

## Building the container

```bash
docker buildx build --platform linux/arm64/v8,linux/amd64 -t learnk8s/bash-ingress:1 .
```