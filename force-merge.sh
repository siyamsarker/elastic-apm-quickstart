#!/bin/bash
#
# Optional: Force merge Elasticsearch indices to immediately reclaim disk space
# WARNING: This can take a long time (minutes to hours) depending on data size
# Only run this if you need immediate disk space reclaim
#

ELASTIC_HOST="localhost:9200"
ELASTIC_USER="elastic"

# Load environment variables
if [ -f .env ]; then
    source .env
    if [ -z "$ELASTIC_PASSWORD" ]; then
        echo "❌ ELASTIC_PASSWORD not found in .env file"
        exit 1
    fi
else
    echo "❌ .env file not found"
    exit 1
fi

echo "⚠️  WARNING: Force merge can take a LONG time (minutes to hours)"
echo "⚠️  This will use significant CPU and I/O resources"
echo ""
read -p "Do you want to continue? (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "❌ Cancelled"
    exit 0
fi

echo "$(date): Starting force merge..."
echo "🔄 Merging all indices (this will take time)..."
echo ""

# Get list of all indices
INDICES=$(curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    "http://${ELASTIC_HOST}/_cat/indices?h=index" | grep -v "^\." | sort)

TOTAL=$(echo "$INDICES" | wc -l | tr -d ' ')
CURRENT=0

echo "📊 Found ${TOTAL} indices to merge"
echo ""

# Force merge each index individually to show progress
for index in $INDICES; do
    CURRENT=$((CURRENT + 1))
    echo "[${CURRENT}/${TOTAL}] Merging: ${index}..."
    
    curl -X POST -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        "http://${ELASTIC_HOST}/${index}/_forcemerge?max_num_segments=1" \
        -H "Content-Type: application/json" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo "    ✅ Completed"
    else
        echo "    ⚠️  Failed or skipped"
    fi
done

echo ""
echo "✅ Force merge completed"
echo "💡 Run 'df -hT' to verify disk space reclaim"
echo "$(date): Process completed"
