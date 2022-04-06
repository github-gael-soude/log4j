#!/bin/bash


error(){
  echo "[ERROR] $1" >&2
  exit 1
}

info()
{
  echo "[INFO] $1" >&2
}

check_result(){
    if [ -z "$1" ]; then
        error "Failed to get result..."
    fi
}

usage() {
	echo "usage: $(basename "$0") [-t] [-h]"
	echo "-h : display help"
	echo "-t : install Defender if tag on EC2"
    echo ""
	exit 2
}

# Global variables
aws_check_tag=0
aws_secret_id="infosec/prisma_defender"
aws_region_secrets="eu-west-1"
aws_tag_name="prismaEnvVar"
prisma_api_domain="europe-west3.cloud.twistlock.com"
prisma_api_url="https://$prisma_api_domain/eu-2-143567931"


# check script arguments
while getopts 't?h?' ARGS; do
	case $ARGS in
	    t) aws_check_tag=1 ;;
	    h|?) usage ;; 
    esac
done


aws_prisma_credentials="{\"username\": \"782a4e9b-f05d-4b45-867c-45fce38d3956\", \"password\": \"UNKg3P2h7UG35AUQ99Q43wa3Qis=\"}"


# FETCH PRISMA TOKEN
prisma_token=$(curl -sSLk -d "$aws_prisma_credentials" -H 'content-type: application/json' \
"$prisma_api_url/api/v1/authenticate" | jq -r '.token')
check_result $prisma_token

# DOWNLOAD AND RUN DEFENDER INSTALL SCRIPT
rm -f /tmp/defender.sh||:
http_code=$(curl --write-out '%{http_code}' -sSLk -H "authorization: Bearer $prisma_token" \
-X POST "$prisma_api_url/api/v1/scripts/defender.sh"  -o /tmp/defender.sh)
if [ $http_code -eq "200" ]; then
    info "Installing Defender..."
    chmod 755 /tmp/defender.sh
    /tmp/defender.sh -c "$prisma_api_domain" -d "none"
else
    error "Failed to download installation script..."
fi
