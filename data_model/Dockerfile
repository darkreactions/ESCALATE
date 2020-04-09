FROM postgres:12.1-alpine

RUN apk update && apk add postgresql-dev gcc musl-dev
RUN apk update && apk add g++ libstdc++ bash git openssl-dev libffi-dev tar

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
#ENV PGDATA /var/lib/postgresql/data

#VOLUME /var/lib/postgresql/data

# COPY docker-entrypoint.sh /

# ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]