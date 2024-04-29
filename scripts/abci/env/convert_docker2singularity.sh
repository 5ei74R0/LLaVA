docker run \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $(pwd)/demo:/output \
--privileged -t --rm \
quay.io/singularity/docker2singularity:v3.11.5 \
local/llava:latest
