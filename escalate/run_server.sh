docker run --name escalate -it --rm \
    -e TZ=`ls -la /etc/localtime | cut -d/ -f8-9` \
    -v /Users/vshekar/escalate_data:/data \
    -e ESCALATE_PERSISTENT_DATA_PATH=/data \
    --link escalate-postgres \
    -p 8000:8000 --rm \
    escalate-server:latest