FROM postgres:12.1-alpine

RUN apk update && apk add postgresql-dev gcc musl-dev
RUN apk update && apk add g++ libstdc++ bash git openssl-dev libffi-dev tar

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
#ESCALATE default DB
ADD ./backups/escalate_dev_create_backup.sql /docker-entrypoint-initdb.d
EXPOSE 5432
CMD ["postgres"]
