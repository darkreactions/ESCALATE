docker build -t escalate-server .
version=$(python VERSION.py)
docker tag escalate-server vshekar/escalate-server:$version
docker push vshekar/escalate-server:$version
