# stockcharts-bash

## How to use:
* Go to stockcharts.com and select graph you want to work with. Setup desired look and feel, periods, time ranges and theme.
* Open Network tab in Dev console, select `ui` POST request and switch to Payload section, click on `view URL-encoded`.
* Create new `.env_[symbol]` file based on any existing `.env` file (except `.env_base`)
* Set values of CHART_XXX variables according to POST request Payload section (symbol, time periods, etc.). Save file.
* Run `./graph.sh [symbol]`
* Check graph image in `/images` folder
* Setup `crontabs` to get images periodically
