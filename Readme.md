aws-get-credentials.sh

aws ecr get-login-password --region eu-west-1 --profile admin \
| docker login --username AWS --password-stdin 862080470745.dkr.ecr.eu-west-1.amazonaws.com

docker tag log4j:latest 862080470745.dkr.ecr.eu-west-1.amazonaws.com/log4j:latest
docker push 862080470745.dkr.ecr.eu-west-1.amazonaws.com/log4j:latest


aws ecr get-login-password --region eu-west-1 --profile gael.soude.test \
| docker login --username AWS --password-stdin 458054901517.dkr.ecr.eu-west-1.amazonaws.com
docker tag log4j:latest 458054901517.dkr.ecr.eu-west-1.amazonaws.com/log4j:latest
docker push 458054901517.dkr.ecr.eu-west-1.amazonaws.com/log4j:latest