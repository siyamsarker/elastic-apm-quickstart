#!/bin/bash
#
# Force Elasticsearch to merge segments and free disk space after deletion
#

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

ELASTIC_USER=${ELASTIC_USER:-elastic}
ELASTIC_HOST=${ELASTIC_HOST:-localhost:9200}

echo "🔄 Forcing Elasticsearch to optimize disk usage..."
echo ""

# Force merge all indices to reclaim disk space
curl -X POST -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    "http://${ELASTIC_HOST}/*/_forcemerge?max_num_segments=1" \
    -H "Content-Type: application/json"

echo ""
echo ""
echo "✅ Force merge completed. Disk space should be reclaimed shortly."
echo "💡 Run 'df -hT' to check disk usage in a few minutes."
