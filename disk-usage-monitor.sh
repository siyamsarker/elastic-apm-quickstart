#!/bin/bash

# Elasticsearch Disk Usage Monitor
# This script monitors disk usage and shows index sizes

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

echo "=== Elasticsearch Index Disk Usage ==="
echo "Date: $(date)"
echo

# Get all indices sorted by size
curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    "http://${ELASTIC_HOST}/_cat/indices?v&s=store.size:desc&h=index,docs.count,store.size,creation.date.string" | \
    head -20

echo
echo "=== Data Streams ==="
curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    "http://${ELASTIC_HOST}/_data_stream" | jq -r '.data_streams[] | "\(.name) - \(.generation)"'

echo
echo "=== APM Indices older than 15 days ==="
if [[ "$OSTYPE" == "darwin"* ]]; then
    CUTOFF_DATE=$(date -v-15d '+%Y-%m-%d')
else
    CUTOFF_DATE=$(date --date="15 days ago" '+%Y-%m-%d')
fi
curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    "http://${ELASTIC_HOST}/_cat/indices/*apm*,*trace*,*metric*,*log*?h=index,creation.date.string,store.size" | \
    awk -v cutoff_date="$CUTOFF_DATE" '
    {
        # Extract date from ISO8601 timestamp (YYYY-MM-DDTHH:MM:SS.sssZ)
        split($2, parts, "T")
        index_date = parts[1]
        if (index_date < cutoff_date) {
            print "OLD: " $1 " (created: " index_date ") - " $3
        }
    }'