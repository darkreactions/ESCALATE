# pull official base image
FROM python:3.7-alpine

RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev
RUN apk add g++ libstdc++ bash git openssl-dev libffi-dev 

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

#Setup code
RUN mkdir /code
WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt
COPY . /code/

COPY boot.sh boot.sh
RUN chmod +x boot.sh

EXPOSE 8000
EXPOSE 5432
ENTRYPOINT ["./boot.sh"]