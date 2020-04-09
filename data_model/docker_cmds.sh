docker volume create postgres_volume
docker run \
    -e POSTGRES_DB=escalate \
    -e POSTGRES_USER=escalate \
    -e POSTGRES_PASSWORD=SD21sAwes0me3 \
    --mount type=volume,src=postgres_volume,dst=/var/lib/postgresql/data \
    -p 5432:5432 \
    -d \
    --name escalate-postgres \
    postgres