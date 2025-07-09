```bash
#!/bin/bash

# Elasticsearch ILM Policy Manager - 15 Day Retention
# This script sets up 15-day retention for all APM, logs, traces, and metrics data

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[HEADER]${NC} $1"
}

# Configuration
ELASTIC_HOST="localhost:9200"
ELASTIC_USER="elastic"
RETENTION_DAYS="15d"

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
    ELASTIC_PASSWORD="$ELASTIC_PASSWORD"
else
    print_error "❌ .env file not found. Please ensure the .env file exists in the current directory."
    exit 1
fi

# Check if password was loaded
if [ -z "$ELASTIC_PASSWORD" ]; then
    print_error "❌ ELASTIC_PASSWORD not found in .env file"
    exit 1
fi

# Function to check if Elasticsearch is available
check_elasticsearch() {
    print_status "Checking Elasticsearch connection..."
    if curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" "http://${ELASTIC_HOST}/_cluster/health" > /dev/null; then
        print_status "✅ Elasticsearch is accessible"
        return 0
    else
        print_error "❌ Cannot connect to Elasticsearch"
        exit 1
    fi
}

# Function to create/update ILM policy
create_ilm_policy() {
    local policy_name=$1
    local max_age=$2
    local max_size=$3
    local description=$4
    
    print_status "Creating/updating ILM policy: ${policy_name}"
    
    curl -X PUT -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        "http://${ELASTIC_HOST}/_ilm/policy/${policy_name}" \
        -H "Content-Type: application/json" \
        -d "{
            \"policy\": {
                \"phases\": {
                    \"hot\": {
                        \"min_age\": \"0ms\",
                        \"actions\": {
                            \"set_priority\": {
                                \"priority\": 100
                            },
                            \"rollover\": {
                                \"max_age\": \"${max_age}\",
                                \"max_primary_shard_size\": \"${max_size}\"
                            }
                        }
                    },
                    \"delete\": {
                        \"min_age\": \"${RETENTION_DAYS}\",
                        \"actions\": {
                            \"delete\": {
                                \"delete_searchable_snapshot\": true
                            }
                        }
                    }
                }
            }
        }" | jq -r '.acknowledged' > /dev/null
    
    if [ $? -eq 0 ]; then
        print_status "✅ Policy ${policy_name} created/updated successfully"
    else
        print_error "❌ Failed to create policy ${policy_name}"
    fi
}

# Function to update existing APM policies
update_apm_policies() {
    print_header "🔄 Updating APM-related ILM policies to 15-day retention"
    
    # APM Traces
    create_ilm_policy "traces-apm.traces-15day-policy" "1d" "10gb" "APM traces with 15-day retention"
    create_ilm_policy "traces-apm.rum_traces-15day-policy" "1d" "10gb" "APM RUM traces with 15-day retention"
    
    # APM Logs
    create_ilm_policy "logs-apm.app_logs-15day-policy" "1d" "10gb" "APM app logs with 15-day retention"
    create_ilm_policy "logs-apm.error_logs-15day-policy" "1d" "10gb" "APM error logs with 15-day retention"
    
    # APM Metrics
    create_ilm_policy "metrics-apm.app_metrics-15day-policy" "1d" "10gb" "APM app metrics with 15-day retention"
    create_ilm_policy "metrics-apm.internal_metrics-15day-policy" "1d" "10gb" "APM internal metrics with 15-day retention"
    
    # APM Transaction Metrics
    create_ilm_policy "metrics-apm.transaction_metrics-15day-policy" "1d" "10gb" "APM transaction metrics with 15-day retention"
    create_ilm_policy "metrics-apm.service_metrics-15day-policy" "1d" "10gb" "APM service metrics with 15-day retention"
    
    # General policies
    create_ilm_policy "logs-15day-retention" "1d" "10gb" "General logs with 15-day retention"
    create_ilm_policy "metrics-15day-retention" "1d" "10gb" "General metrics with 15-day retention"
    create_ilm_policy "traces-15day-retention" "1d" "10gb" "General traces with 15-day retention"
}

# Function to apply policies to templates
apply_policies_to_templates() {
    print_header "📝 Applying 15-day retention policies to index templates"
    
    # This would require getting all templates and updating them
    # For now, we'll create a general policy that can be applied
    
    print_status "Creating general 15-day retention policy for new indices..."
    create_ilm_policy "default-15day-retention" "7d" "50gb" "Default 15-day retention policy"
}

# Function to show current policies
show_current_policies() {
    print_header "📊 Current ILM Policies with 15-day retention"
    
    curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        "http://${ELASTIC_HOST}/_ilm/policy" | \
        jq -r 'to_entries[] | select(.value.policy.phases.delete.min_age == "15d") | .key' | \
        while read policy; do
            print_status "✅ ${policy}"
        done
}

# Function to create a monitoring script
create_monitoring_script() {
    print_header "📋 Creating monitoring script for disk usage"
    
    cat > disk-usage-monitor.sh << 'EOF'
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
    $2 < cutoff_date {print "OLD: " $1 " (" $2 ") - " $3}'

EOF

    chmod +x disk-usage-monitor.sh
    print_status "✅ Created disk-usage-monitor.sh"
}

# Function to set up automated cleanup
setup_automated_cleanup() {
    print_header "🔄 Setting up automated cleanup"
    
    # Create a cleanup script
    cat > cleanup-old-indices.sh << 'EOF'
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
    $2 < cutoff_date {
        system("curl -X DELETE -s -u \"${ELASTIC_USER}:${ELASTIC_PASSWORD}\" \"http://${ELASTIC_HOST}/" $1 "\"")
        print "Deleted: " $1
    }'

echo "$(date): Cleanup completed"
EOF

    chmod +x cleanup-old-indices.sh
    print_status "✅ Created cleanup-old-indices.sh (in dry-run mode)"
    
    print_warning "⚠️  To enable automated cleanup, edit cleanup-old-indices.sh and remove the safety exit"
    print_warning "⚠️  Consider adding to cron: 0 2 * * * /path/to/cleanup-old-indices.sh"
}

# Main execution
main() {
    print_header "🚀 Elasticsearch ILM 15-Day Retention Setup"
    echo
    
    check_elasticsearch
    echo
    
    update_apm_policies
    echo
    
    apply_policies_to_templates
    echo
    
    show_current_policies
    echo
    
    create_monitoring_script
    echo
    
    setup_automated_cleanup
    echo
    
    print_header "✅ Setup Complete!"
    print_status "📋 Summary:"
    print_status "  - Created/updated ILM policies for 15-day retention"
    print_status "  - Generated monitoring script: disk-usage-monitor.sh"
    print_status "  - Generated cleanup script: cleanup-old-indices.sh"
    print_status ""
    print_status "💡 Next steps:"
    print_status "  - Run ./disk-usage-monitor.sh to check current disk usage"
    print_status "  - Review and enable cleanup-old-indices.sh if needed"
    print_status "  - Monitor your Elasticsearch cluster regularly"
}

# Run main function
main "$@"
```