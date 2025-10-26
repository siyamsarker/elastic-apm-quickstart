#!/bin/bash

set -e

# Function to display help
show_help() {
    echo "Elastic Stack 9.2.0 Setup Script"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -c, --clean    Clean up existing containers and volumes before setup"
    echo "  -s, --status   Show status of services"
    echo "  --stop         Stop all services"
    echo ""
    echo "Examples:"
    echo "  $0               # Normal setup"
    echo "  $0 --clean      # Clean setup (removes all data)"
    echo "  $0 --status     # Check service status"
    echo "  $0 --stop       # Stop all services"
}

# Function to show service status
show_status() {
    # Detect container runtime for status check
    local runtime_cmd=""
    if command -v docker &> /dev/null; then
        runtime_cmd="docker"
    elif command -v podman &> /dev/null; then
        runtime_cmd="podman"
    else
        echo "❌ No container runtime available for status check"
        return 1
    fi
    
    echo "🔍 Elastic Stack Status:"
    echo ""
    
    if ${runtime_cmd} ps --filter "name=elasticsearch" --format "{{.Names}}" | grep -q "elasticsearch"; then
        echo "  ✅ Elasticsearch: Running"
        curl -s -u elastic:${ELASTIC_PASSWORD} http://localhost:9200/_cluster/health 2>/dev/null | jq '.status' 2>/dev/null || echo "     Health: Unknown"
    else
        echo "  ❌ Elasticsearch: Not running"
    fi
    
    if ${runtime_cmd} ps --filter "name=kibana" --format "{{.Names}}" | grep -q "kibana"; then
        echo "  ✅ Kibana: Running"
    else
        echo "  ❌ Kibana: Not running"
    fi
    
    if ${runtime_cmd} ps --filter "name=apm-server" --format "{{.Names}}" | grep -q "apm-server"; then
        echo "  ✅ APM Server: Running"
    else
        echo "  ❌ APM Server: Not running"
    fi
    
    echo ""
    echo "Service URLs:"
    echo "  - Elasticsearch: http://localhost:9200"
    echo "  - Kibana: http://localhost:5601"
    echo "  - APM Server: http://localhost:8200"
}

# Function to stop all services
stop_all_services() {
    echo "🛑 Stopping all Elastic Stack services..."
    # Detect compose command for stopping
    local compose_cmd=""
    if command -v docker &> /dev/null && command -v docker compose &> /dev/null; then
        compose_cmd="docker compose"
    elif command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
        compose_cmd="docker-compose"
    elif command -v podman &> /dev/null && command -v podman-compose &> /dev/null; then
        compose_cmd="podman-compose"
    else
        echo "❌ No compose command available"
        return 1
    fi
    
    ${compose_cmd} down
    echo "✅ All services stopped!"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--clean)
            CLEAN_SETUP=true
            shift
            ;;
        -s|--status)
            # Load environment variables for status check
            if [ -f .env ]; then
                source .env
            fi
            show_status
            exit 0
            ;;
        --stop)
            stop_all_services
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

echo "🚀 Setting up Elastic Stack 9.2.0..."

# Detect container runtime and compose tool
CONTAINER_RUNTIME=""
COMPOSE_CMD=""

if command -v docker &> /dev/null && docker compose version &> /dev/null; then
    CONTAINER_RUNTIME="docker"
    COMPOSE_CMD="docker compose"
    echo "✅ Docker and Docker Compose detected"
elif command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    CONTAINER_RUNTIME="docker"
    COMPOSE_CMD="docker-compose"
    echo "✅ Docker and docker-compose detected"
elif command -v podman &> /dev/null && command -v podman-compose &> /dev/null; then
    CONTAINER_RUNTIME="podman"
    COMPOSE_CMD="podman-compose"
    echo "✅ Podman and podman-compose detected"
else
    echo "❌ No compatible container runtime found!"
    echo ""
    echo "Please install one of the following:"
    echo "  • Docker with Docker Compose:"
    echo "    - macOS: Download Docker Desktop from https://docker.com"
    echo "    - Linux: Follow instructions at https://docs.docker.com/engine/install/"
    echo "  • Podman with podman-compose:"
    echo "    - macOS: brew install podman podman-compose"
    echo "    - Linux: Install podman and 'pip install podman-compose'"
    exit 1
fi

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please ensure the .env file exists."
    exit 1
fi
source .env

# Function to check if a container is running
check_container_running() {
    local container_name=$1
    if ${CONTAINER_RUNTIME} ps --filter "name=${container_name}" --format "{{.Names}}" | grep -q "${container_name}"; then
        return 0
    else
        return 1
    fi
}

# Function to wait for service health
wait_for_elasticsearch() {
    echo "⏳ Waiting for Elasticsearch to be ready..."
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s -u elastic:${ELASTIC_PASSWORD} http://localhost:9200/_cluster/health 2>/dev/null | grep -q '"status":"green\|yellow"'; then
            echo "✅ Elasticsearch is ready!"
            return 0
        fi
        echo "Waiting for Elasticsearch... (attempt $((attempt+1))/$max_attempts)"
        sleep 10
        attempt=$((attempt+1))
    done
    
    echo "❌ Elasticsearch failed to start within expected time"
    return 1
}

# Function to stop all services
stop_services() {
    echo "🛑 Stopping existing services..."
    ${COMPOSE_CMD} down
}

# Handle clean setup
if [ "$CLEAN_SETUP" = "true" ]; then
    echo "🧹 Cleaning up existing containers and volumes..."
    ${COMPOSE_CMD} down --volumes
    echo "✅ Cleanup completed!"
    echo ""
fi

# Stop any existing containers to avoid conflicts
echo "🧹 Stopping any existing containers..."
${COMPOSE_CMD} down 2>/dev/null || true

# Start Elasticsearch first
echo "📦 Starting Elasticsearch..."
${COMPOSE_CMD} up -d elasticsearch

# Wait for Elasticsearch to be ready
wait_for_elasticsearch

# Set up kibana_system user password
echo "🔐 Setting up Kibana system user password..."
response=$(curl -s -X POST -u elastic:${ELASTIC_PASSWORD} \
  -H "Content-Type: application/json" \
  http://localhost:9200/_security/user/kibana_system/_password \
  -d "{\"password\":\"${KIBANA_PASSWORD}\"}" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✅ Kibana system user password set!"
else
    echo "⚠️  Warning: Failed to set Kibana system user password. It may already be set."
fi

# Start Kibana next
echo "📦 Starting Kibana..."
${COMPOSE_CMD} up -d --no-deps kibana

# Wait for Kibana to be ready
echo "⏳ Waiting for Kibana..."
max_attempts=60
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:5601/api/status 2>/dev/null | grep -q '"level":"available"'; then
        echo "✅ Kibana is ready!"
        break
    fi
    echo "Waiting for Kibana... (attempt $((attempt+1))/$max_attempts)"
    sleep 10
    attempt=$((attempt+1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "⚠️  Warning: Kibana may not be fully ready yet, but continuing..."
fi

# Finally start APM Server
echo "📦 Starting APM Server..."
${COMPOSE_CMD} up -d --no-deps apm-server

echo ""
echo "⏳ Waiting for APM Server to be ready..."
echo "This may take a few minutes..."

# Wait for APM Server to be ready
echo "⏳ Waiting for APM Server..."
attempt=0
max_attempts=30

while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:8200 2>/dev/null | grep -q 'version'; then
        echo "✅ APM Server is ready!"
        break
    fi
    echo "Waiting for APM Server... (attempt $((attempt+1))/$max_attempts)"
    sleep 5
    attempt=$((attempt+1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "⚠️  Warning: APM Server may not be fully ready yet, but continuing..."
fi

# Final status check
echo ""
echo "🔍 Final status check:"
echo "  - Elasticsearch: $(curl -s -u elastic:${ELASTIC_PASSWORD} http://localhost:9200 2>/dev/null > /dev/null && echo '✅ Running' || echo '❌ Not accessible')"
echo "  - Kibana: $(curl -s http://localhost:5601 2>/dev/null > /dev/null && echo '✅ Running' || echo '❌ Not accessible')"
echo "  - APM Server: $(curl -s http://localhost:8200 2>/dev/null > /dev/null && echo '✅ Running' || echo '❌ Not accessible')"

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Service URLs:"
echo "  - Elasticsearch: http://localhost:9200"
echo "  - Kibana: http://localhost:5601"
echo "  - APM Server: http://localhost:8200"
echo ""
echo "🔐 Credentials:"
echo "  - Username: elastic"
echo "  - Password: ${ELASTIC_PASSWORD}"
echo ""
echo "🔧 APM Configuration:"
echo "  - APM Server URL: http://localhost:8200"
echo "  - Secret Token: ${APM_SECRET_TOKEN}"
echo ""
echo "✨ You can now configure your applications to send APM data to http://localhost:8200"
echo ""
echo "💡 Useful commands:"
echo "  - Stop all services: ${COMPOSE_CMD} down"
echo "  - View logs: ${COMPOSE_CMD} logs -f [service-name]"
echo "  - Restart setup: $0 --clean"
echo "  - Check container status: ${CONTAINER_RUNTIME} ps"
