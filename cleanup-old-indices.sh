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

# Portable date calculation function that works on ALL systems
get_date_n_days_ago() {
    local days_ago=$1
    local result_date=""
    
    # Try GNU date (Linux standard)
    if result_date=$(date --date="${days_ago} days ago" '+%Y-%m-%d' 2>/dev/null); then
        echo "$result_date"
        return 0
    fi
    
    # Try BSD date (macOS)
    if result_date=$(date -v-${days_ago}d '+%Y-%m-%d' 2>/dev/null); then
        echo "$result_date"
        return 0
    fi
    
    # Fallback using Python 3
    if command -v python3 &> /dev/null; then
        result_date=$(python3 -c "from datetime import datetime, timedelta; print((datetime.now() - timedelta(days=${days_ago})).strftime('%Y-%m-%d'))" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$result_date" ]; then
            echo "$result_date"
            return 0
        fi
    fi
    
    # Fallback using Python 2
    if command -v python &> /dev/null; then
        result_date=$(python -c "from datetime import datetime, timedelta; print((datetime.now() - timedelta(days=${days_ago})).strftime('%Y-%m-%d'))" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$result_date" ]; then
            echo "$result_date"
            return 0
        fi
    fi
    
    # Fallback using Perl
    if command -v perl &> /dev/null; then
        result_date=$(perl -MTime::Piece -E "say Time::Piece->new(time - ${days_ago}*86400)->strftime('%Y-%m-%d')" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$result_date" ]; then
            echo "$result_date"
            return 0
        fi
    fi
    
    echo "ERROR: Unable to calculate date. Please install one of: GNU coreutils, Python, or Perl" >&2
    return 1
}

# Get indices older than 15 days
CUTOFF_DATE=$(get_date_n_days_ago 15)
if [ $? -ne 0 ]; then
    echo "❌ Failed to calculate cutoff date"
    exit 1
fi

echo "$(date): Starting cleanup of indices older than ${CUTOFF_DATE}"
echo "⚠️  WARNING: This will permanently delete indices older than ${CUTOFF_DATE}"
echo ""

# Delete indices older than 15 days
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

echo ""
echo "$(date): Cleanup completed"