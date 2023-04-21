#!bin/bash

######################
## Network settings ##
######################
USERAGENTS=(
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15"
)

SC_HOST="stockcharts.com"
SC_URL="https://${SC_HOST}"
SC_DOC_URL="${SC_URL}/h-sc/ui"
SC_IMG_URL="${SC_URL}/c-sc/sc"

SC_DOC_ACCEPT="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
SC_IMG_ACCEPT="image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8"

######################
### Files settings ###
######################
DATE_YEAR=$(date +%Y)
DATE_MONTH=$(date +%m)
DATE_DAY=$(date +%d)
DATE_TIME=$(date +%H_%M_%S)
TIMESTAMP=$(($(date +%s%N)/1000000))

SAVE_DIR="./images/$DATE_YEAR/$DATE_MONTH/$DATE_DAY"

COOKIE_FILE="./cookie/cook_${GRAPH}.txt"
COOKIE_LIFETIME=60 # minutes

######################
##### Functions ######
######################
function getMyIP (
  curl -s https://api.ipify.org
)

function getRandomUseragent (
  random_index=$(($RANDOM % ${#USERAGENTS[@]}))
  echo ${USERAGENTS[$random_index]}
)

function createImageDir (
  mkdir -p $SAVE_DIR
)

function updateCookies (
  if [ ! -f ${COOKIE_FILE} ] || [ $(find ${COOKIE_FILE} -type f -mmin +${COOKIE_LIFETIME}) ]; then
    echo "Update cookie file... ${SC_DOC_URL}"
    #echo "POST_DATA: ${POST_STR}"
    curl -X POST \
      --cookie-jar ${COOKIE_FILE} \
      --silent \
      --output /dev/null \
      -H "authority: ${SC_HOST}" \
      -H "accept: ${SC_DOC_ACCEPT}" \
      -H 'accept-language: en-US,en;q=0.9,ru;q=0.8,fr;q=0.7' \
      -H 'cache-control: max-age=0' \
      -H 'content-type: application/x-www-form-urlencoded' \
      -H "origin: ${SC_URL}" \
      -H "referer: ${SC_DOC_URL}" \
      -H 'sec-ch-ua: "Chromium";v="112", "Google Chrome";v="112", "Not:A-Brand";v="99"' \
      -H 'sec-ch-ua-mobile: ?0' \
      -H 'sec-ch-ua-platform: "Linux"' \
      -H 'sec-fetch-dest: document' \
      -H 'sec-fetch-mode: navigate' \
      -H 'sec-fetch-site: same-origin' \
      -H 'sec-fetch-user: ?1' \
      -H 'upgrade-insecure-requests: 1' \
      -H "user-agent: ${USERAGENT}" \
      --data-raw "${POST_STR}" \
      --compressed \
      ${SC_DOC_URL}
  fi
)

function getSession (
  COOKIE=$(awk '!/^#/ {print $NF}' ${COOKIE_FILE})
  echo $(echo ${COOKIE} | sed 's/ //g')
)

function buildImgURL (
  if [ -n "${CHART_START}" ]
  then
    params_length="st=${CHART_START}"
  else
    params_length="yr=${CHART_YEARS}&mn=${CHART_MONTHS}&dy=${CHART_DAYS}"
  fi

  echo "${SC_IMG_URL}?s=${SYMBOL}&p=${CHART_PERIOD}&${params_length}&i=${SESSION}&r=${TIMESTAMP}"
)

function buildPOSTData (
  res=""
  post_array=("${POST_BASE[@]}" "${POST_DATA[@]}")
#  post_array=("${POST_DATA[@]}")
  array_length=${#post_array[@]}
  echo "Post data length: $array_length"
  for (( i=0; i<$array_length; i++ ))
  do
    if [ $i -eq $(($array_length-1)) ]
    then
      res+="${post_array[$i]}"
    else
      res+="${post_array[$i]}&"
    fi
  done
  echo "$res"
)

function getGraphImage (
  curl -X GET \
    -H "authority: ${SC_HOST}" \
    -H "accept: ${SC_IMG_ACCEPT}" \
    -H 'accept-language: en-US,en;q=0.9,ru;q=0.8,fr;q=0.7' \
    -H "cookie: freeunlock=true%7C5; fs.bot.check=true; ChartXmlId=${SESSION}" \
    -H "origin: ${SC_URL}" \
    -H "referer: ${SC_DOC_URL}" \
    -H 'sec-ch-ua: "Chromium";v="112", "Google Chrome";v="112", "Not:A-Brand";v="99"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Linux"' \
    -H 'sec-fetch-dest: image' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H "user-agent: $USERAGENT" \
    -o "${SAVE_DIR}/${DATE_TIME}_${GRAPH}_${CHART_PERIOD}_${CHART_TYPE}.png" \
    -s \
    $IMG_URL
)
