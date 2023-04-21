#!/bin/bash

function getMyIP (
  curl -s https://api.ipify.org
)

MYIP=$(getMyIP)
echo "My IP: ${MYIP}"

source .env_base
source .env_$1
source utils.sh

USERAGENT=$(getRandomUseragent)
echo "Useragent: ${USERAGENT}"

POST_STR=$(buildPOSTData)

updateCookies

SESSION=$(getSession)
echo "Session value: ${SESSION}"

IMG_URL=$(buildImgURL)
echo "Graph image URL: ${IMG_URL}"

sleep 1

createImageDir
getGraphImage
