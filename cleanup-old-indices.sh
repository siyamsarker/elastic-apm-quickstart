#!/bin/bash

# Automated cleanup script for indices older than 15 days
# This script should be run via cron

ELASTIC_HOST="localhost:9200"
ELASTIC_USER="elastic"

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
    if [ -z "$ELASTIC_PASSWORD" ]; then
        echo "❌ ELASTIC_PASSWORD not found in .env file"
        exit 1
    fi
else
    echo "❌ .env file not found. Please ensure the .env file exists in the current directory."
    exit 1
fi

# Get indices older than 15 days
if [[ "$OSTYPE" == "darwin"* ]]; then
    CUTOFF_DATE=$(date -v-15d '+%Y-%m-%d')
else
    CUTOFF_DATE=$(date --date="15 days ago" '+%Y-%m-%d')
fi

echo "$(date): Starting cleanup of indices older than ${CUTOFF_DATE}"

# This is a safety check - comment out the exit line below to enable actual deletion
echo "SAFETY: This script is in dry-run mode. Edit the script to enable actual deletion."
exit 0

# Uncomment the lines below to enable actual deletion
curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    "http://${ELASTIC_HOST}/_cat/indices/*apm*,*trace*,*metric*,*log*?h=index,creation.date.string" | \
    awk -v cutoff_date="$CUTOFF_DATE" '
    {
        # Extract date from ISO8601 timestamp (YYYY-MM-DDTHH:MM:SS.sssZ)
        split($2, parts, "T")
        index_date = parts[1]
        if (index_date < cutoff_date) {
            system("curl -X DELETE -s -u \"${ELASTIC_USER}:${ELASTIC_PASSWORD}\" \"http://${ELASTIC_HOST}/" $1 "\"")
            print "Deleted: " $1 " (created: " index_date ")"
        }
    }'

echo "$(date): Cleanup completed"