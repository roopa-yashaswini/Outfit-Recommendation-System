#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please provide access key for Weatherstack API"
    exit 1
fi


# Set environment variables
YOUR_ACCESS_KEY=$1
export YOUR_ACCESS_KEY

# Run R scripts
#Rscript web_scraping.R
#Rscript weatherstack_api.R
#Rscript etl_and_data_storage.R
Rscript run_ootd_api.R &

# Wait for API to start
sleep 10

# Call the /ootd endpoint
curl "http://localhost:8000/ootd" --output ootd_plot.png
echo "Outfit of the Day plot saved as ootd_plot.png"

sleep 5
curl "http://localhost:8000/shutdown"
echo "API closed"