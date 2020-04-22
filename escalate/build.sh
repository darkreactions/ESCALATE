docker-compose build
version=$(python VERSION.py)
docker tag escalate_web:latest vshekar/escalate-server:$version
docker push vshekar/escalate-server:$version
