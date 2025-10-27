# 🚀 Elastic Stack 9.2.0 - Complete APM Setup

> **Production-ready Elasticsearch, Kibana, and APM Server deployment with automated setup**

[![Elastic Stack](https://img.shields.io/badge/Elastic%20Stack-9.2.0-005571)](https://www.elastic.co/)
[![Docker](https://img.shields.io/badge/Docker-supported-2496ED)](https://www.docker.com/)
[![Podman](https://img.shields.io/badge/Podman-supported-892CA0)](https://podman.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📖 Overview

This repository provides a **complete, production-ready Elastic Stack 9.2.0** setup with:

- 🔍 **Elasticsearch** - Distributed search and analytics engine
- 📊 **Kibana** - Data visualization and management
- 📈 **APM Server** - Application Performance Monitoring
- 🐳 **Container-based** - Works with Docker or Podman
- 🔐 **Security enabled** - Built-in authentication and authorization
- 🚀 **Automated setup** - One-command deployment

## ⚡ Quick Start

```bash
# Clone and navigate to the project
git clone https://github.com/siyamsarker/elastic-apm-quickstart.git
cd "elastic-apm-quickstart"

# Make setup script executable
chmod +x setup.sh

# Run automated setup (detects Docker/Podman automatically)
./setup.sh
```

**That's it!** 🎉 Your Elastic Stack will be ready in minutes.

## 📋 Prerequisites

### System Requirements

- **Memory**: Minimum 4GB RAM available for containers
- **Ports**: 9200, 5601, and 8200 must be available
- **OS**: macOS, Linux, or Windows with WSL2

### Required Tools

The maintenance scripts (`cleanup-old-indices.sh`, `disk-usage-monitor.sh`, `ilm-15-day-retention.sh`) require the following tools:

- **jq**: JSON processor for parsing Elasticsearch responses
- **curl**: Command-line tool for HTTP requests
- **awk**: Text processing tool for filtering indices

**Installation Instructions**:

| Tool | macOS | Linux (Debian/Ubuntu) | Linux (CentOS/RHEL) | Windows (WSL2) |
|------|-------|-----------------------|---------------------|----------------|
| **jq** | `brew install jq` | `sudo apt update && sudo apt install jq` | `sudo yum install epel-release && sudo yum install jq` | Follow Linux instructions for your WSL2 distro |
| **curl** | Pre-installed (or `brew install curl`) | Pre-installed (or `sudo apt install curl`) | Pre-installed (or `sudo yum install curl`) | Pre-installed in most WSL2 distros |
| **awk** | Pre-installed (BSD awk) | Pre-installed (GNU awk) | Pre-installed (GNU awk) | Pre-installed in most WSL2 distros |

**Notes**:
- On macOS, install Homebrew (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`) if not already present.
- On Linux, ensure you have `sudo` privileges for package installation.
- On Windows, use WSL2 with a Linux distribution (e.g., Ubuntu) and follow the corresponding Linux instructions.
- Verify installation with `jq --version`, `curl --version`, and `awk --version`.

### Container Runtime (Choose One)

#### Option A: Docker (Recommended)
- ✅ **macOS**: [Docker Desktop](https://docker.com/products/docker-desktop)
- ✅ **Linux**: [Docker Engine](https://docs.docker.com/engine/install/)
- ✅ **Windows**: [Docker Desktop with WSL2](https://docs.docker.com/desktop/windows/wsl/)

#### Option B: Podman
- 🍺 **macOS**: `brew install podman podman-compose`
- 📦 **Linux**: Install podman + `pip install podman-compose`
- 🪟 **Windows**: [Podman Desktop](https://podman-desktop.io/)

## 🎮 Setup Commands

### 🤖 Automated Setup (Recommended)

The intelligent `setup.sh` script automatically detects your container runtime and handles all configuration:

```bash
# 🚀 Normal setup
./setup.sh

# 🧹 Clean installation (removes existing data)
./setup.sh --clean

# 📊 Check service status
./setup.sh --status

# 🛑 Stop all services
./setup.sh --stop

# ❓ Show help
./setup.sh --help
```

### ✨ What the Script Does

- 🔍 **Auto-detects** Docker or Podman
- 🔐 **Configures security** (passwords, tokens)
- ⏳ **Waits for services** to be ready
- 🧪 **Health checks** all components
- 📋 **Displays** service URLs and credentials

### 📂 Index Lifecycle Management (ILM) and Maintenance Scripts

This setup includes scripts to manage Elasticsearch indices with a 15-day retention policy and monitor disk usage. Below is an overview of how to configure the ILM policy, when to use the provided scripts, and how to schedule automated cleanup.

#### Configuring ILM Policy

The `ilm-15-day-retention.sh` script configures Index Lifecycle Management (ILM) policies to automatically manage and delete indices older than 15 days for APM, logs, traces, and metrics data. It creates policies with the following characteristics:

- **Hot Phase**: Indices are set to high priority (100) with a rollover after 1 day or when the primary shard reaches 10GB.
- **Delete Phase**: Indices are deleted after 15 days.
- **Applicable Data**: Covers APM traces, logs, metrics, and general logs/traces.

Before running the scripts, ensure they have executable permissions:

```bash
# Set executable permissions for maintenance scripts
chmod +x ilm-15-day-retention.sh cleanup-old-indices.sh disk-usage-monitor.sh
```

**To configure the ILM policy:**

```bash
# Run the ILM setup script
./ilm-15-day-retention.sh
```

**What it does:**
- Verifies Elasticsearch connectivity.
- Creates or updates ILM policies for various data types (e.g., `traces-apm.traces-15day-policy`, `logs-15day-retention`).
- Applies a default 15-day retention policy for new indices.
- Generates `disk-usage-monitor.sh` and `cleanup-old-indices.sh` for monitoring and cleanup tasks.

**Note**: Ensure the `.env` file contains the `ELASTIC_PASSWORD` before running the script. The script will exit with an error if the `.env` file or password is missing.

#### Using Maintenance Scripts

The following scripts help manage and monitor your Elasticsearch indices:

- **`ilm-15-day-retention.sh`**:
  - **When to use**: Run this script initially after setting up Elasticsearch to configure the 15-day retention ILM policies or when you need to update these policies. It should be executed once during setup or after changes to the retention requirements.
  - **Usage**:
    ```bash
    ./ilm-15-day-retention.sh
    ```
  - **Output**: Displays the status of policy creation and lists all policies with 15-day retention.

- **`disk-usage-monitor.sh`**:
  - **When to use**: Use this script to monitor disk usage and identify indices consuming the most space or those older than 15 days. Run it periodically to check the health of your Elasticsearch cluster or when troubleshooting storage issues.
  - **Usage**:
    ```bash
    ./disk-usage-monitor.sh
    ```
  - **Output**: Shows the top 20 indices by size, data stream information, and a list of APM-related indices older than 15 days.

- **`cleanup-old-indices.sh`**:
  - **When to use**: Use this script to manually delete indices older than 15 days. **⚠️ WARNING: This script permanently deletes data** - review indices with `disk-usage-monitor.sh` before running.
  - **Usage**:
    ```bash
    ./cleanup-old-indices.sh
    ```
  - **Output**: Lists and deletes indices older than 15 days.

**Note**: Always review the output of `disk-usage-monitor.sh` before running `cleanup-old-indices.sh` to avoid accidental data loss. **The cleanup script will permanently delete data without confirmation.**

#### Three Ways Data Can Be Deleted

There are three different approaches to delete old indices from your Elasticsearch cluster:

##### **Option 1: ILM Automatic Deletion** ✅ (Recommended)

This is the **automated, production-ready** approach where Elasticsearch manages data lifecycle automatically.

**How it works:**
1. Run the ILM setup script to create policies:
   ```bash
   ./ilm-15-day-retention.sh
   ```

2. Attach policies to your indices (one-time manual step):
   ```bash
   # Example: Attach policy to an index via Kibana Dev Tools or curl
   curl -X PUT -u elastic:${ELASTIC_PASSWORD} \
     "http://localhost:9200/my-index-name/_settings" \
     -H "Content-Type: application/json" \
     -d '{"index.lifecycle.name": "logs-15day-retention"}'
   ```

3. Elasticsearch automatically handles:
   - Daily rollover (or at 10GB per shard)
   - Deletion after 15 days from rollover

**Timeline:**
- Day 0: Index created with policy attached
- Day 1: Rollover to new index
- Day 16: Old index automatically deleted

**Pros:**
- ✅ Fully automated after initial setup
- ✅ Production-ready and reliable
- ✅ No manual intervention needed
- ✅ Elasticsearch handles everything

**Cons:**
- ⚠️ Only affects indices with policies attached
- ⚠️ Requires manual policy attachment for existing indices
- ⚠️ 15-day wait before first deletion

---

##### **Option 2: Manual Cleanup Script** (Immediate)

Use the generated cleanup script to **manually delete old indices on demand**.

**How it works:**
1. Generate the cleanup script:
   ```bash
   ./ilm-15-day-retention.sh  # Creates cleanup-old-indices.sh
   ```

2. Review indices that will be deleted (optional):
   ```bash
   ./disk-usage-monitor.sh
   ```

3. Run the script to delete indices:
   ```bash
   ./cleanup-old-indices.sh
   ```
   
   **⚠️ WARNING:** This will **permanently delete** all indices older than 15 days without confirmation!

**Pros:**
- ✅ Immediate deletion
- ✅ Works on existing indices without policies
- ✅ Full control over when cleanup happens
- ✅ Simple and straightforward

**Cons:**
- ⚠️ Manual execution required
- ⚠️ Deletion is permanent and irreversible
- ⚠️ No confirmation prompt before deletion
- ⚠️ Must remember to run periodically

---

##### **Option 3: Scheduled Cleanup** (Cron Job)

Automate the cleanup script to run on a schedule using cron.

**How it works:**
1. Verify the cleanup script is executable:
   ```bash
   chmod +x cleanup-old-indices.sh
   ```

2. Add to crontab:
   ```bash
   crontab -e
   ```

3. Add this line to run daily at 2 AM:
   ```bash
   0 2 * * * /path/to/elastic-apm-quickstart/cleanup-old-indices.sh >> /path/to/elastic-apm-quickstart/cleanup.log 2>&1
   ```

4. Verify the cron job is scheduled:
   ```bash
   crontab -l
   ```

**Pros:**
- ✅ Automated daily cleanup
- ✅ Works with existing indices
- ✅ Logs output for monitoring
- ✅ No ILM policy setup needed

**Cons:**
- ⚠️ Requires cron access
- ⚠️ Less flexible than ILM
- ⚠️ Must ensure script has correct permissions
- ⚠️ Needs monitoring to ensure it runs
- ⚠️ Deletes data automatically without manual review

---

##### **Which Option Should You Choose?**

| Scenario | Recommended Option |
|----------|-------------------|
| **Production environment** | Option 1: ILM Automatic |
| **Need immediate cleanup** | Option 2: Manual Script |
| **Simple automated cleanup** | Option 3: Cron Job |
| **Testing/Development** | Option 2: Manual Script |
| **Large-scale deployment** | Option 1: ILM Automatic |

**Important:** Regardless of which option you choose, **always test in a non-production environment first** and ensure you have backups of critical data.

#### Scheduling Automated Cleanup with Cron

To automate the cleanup of indices older than 15 days, you can schedule `cleanup-old-indices.sh` to run via a cron job. Follow these steps:

1. **Verify the Script is Executable**:
   ```bash
   chmod +x cleanup-old-indices.sh
   ```

2. **Add to Cron**:
   - Open the crontab editor:
     ```bash
     crontab -e
     ```
   - Add a cron job to run the script daily at 2 AM (adjust the time as needed):
     ```bash
     0 2 * * * /path/to/elastic-apm-quickstart/cleanup-old-indices.sh >> /path/to/elastic-apm-quickstart/cleanup.log 2>&1
     ```
     Replace `/path/to/elastic-apm-quickstart/` with the actual path to your project directory.
   - Save and exit the editor.

3. **Verify the Cron Job**:
   - Check the cron log (typically `/var/log/syslog` or `/var/log/cron` on Linux) to ensure the job runs as scheduled.
   - Review the `cleanup.log` file for output and any errors.

**Note**: Ensure the `.env` file is accessible to the cron job (in the project directory) and contains the correct `ELASTIC_PASSWORD`. Test the script manually first to confirm it works as expected.

**⚠️ WARNING**: The cleanup script **permanently deletes indices older than 15 days** without confirmation. Always back up critical data and test the script manually before scheduling it with cron.

### Manual Setup

If you prefer to run commands manually, use the appropriate compose command for your runtime:

**For Docker:**
```bash
# Start all services
docker compose up -d
# OR if using older docker-compose
docker-compose up -d
```

**For Podman:**
```bash
# Start all services
podman-compose up -d
```

**Note:** The automated setup script handles Elasticsearch initialization and password setup automatically. Manual setup requires additional steps for proper security configuration.

## 🌐 Service URLs

Once deployed, access your Elastic Stack services:

| Service | URL | Description |
|---------|-----|-------------|
| 🔍 **Elasticsearch** | http://localhost:9200 | Search and analytics engine |
| 📊 **Kibana** | http://localhost:5601 | Data visualization dashboard |
| 📈 **APM Server** | http://localhost:8200 | Application performance monitoring |

## 🔐 Authentication

### Default Credentials

- **Username**: `elastic`
- **Password**: `OYyP6OIrT9aUaoXjk2tLaDxx` (from .env file)

### Security Tokens

- **APM Secret Token**: `Zi07Ksmqd1iCFyOlFWhGnhuP1KHg8fSaxx`
- **Kibana Encryption Key**: `RCQGBqLU5fJUOUvfmO9R4uk6qAlrYLUF`

> ⚠️ **Security Note**: Change these credentials for production use!

## 📈 APM Integration

### Connection Settings

| Parameter | Value |
|-----------|-------|
| **APM Server URL** | `http://localhost:8200` |
| **Secret Token** | `Zi07Ksmqd1iCFyOlFWhGnhuP1KHg8fSaxx` |
| **Service Name** | `your-app-name` |

### 💻 Language-Specific Configuration

<details>
<summary><strong>🟢 Node.js</strong></summary>

```javascript
const apm = require('elastic-apm-node').start({
  serverUrl: 'http://localhost:8200',
  secretToken: 'Zi07Ksmqd1iCFyOlFWhGnhuP1KHg8fSaxx',
  serviceName: 'my-nodejs-app',
  serviceVersion: '1.0.0',
  environment: 'development'
});
```

**Installation:**
```bash
npm install elastic-apm-node
```
</details>

<details>
<summary><strong>🐍 Python</strong></summary>

```python
import elasticapm
from elasticapm.contrib.django.middleware import TracingMiddleware

apm = elasticapm.Client({
    'SERVER_URL': 'http://localhost:8200',
    'SECRET_TOKEN': 'Zi07Ksmqd1iCFyOlFWhGnhuP1KHg8fSaxx',
    'SERVICE_NAME': 'my-python-app',
    'SERVICE_VERSION': '1.0.0',
    'ENVIRONMENT': 'development'
})
```

**Installation:**
```bash
pip install elastic-apm
```
</details>

<details>
<summary><strong>☕ Java</strong></summary>

```bash
-javaagent:elastic-apm-agent-1.x.x.jar
-Delastic.apm.server_urls=http://localhost:9200
-Delastic.apm.secret_token=Zi07Ksmqd1iCFyOlFWhGnhuP1KHg8fSaxx
-Delastic.apm.service_name=my-java-app
-Delastic.apm.service_version=1.0.0
-Delastic.apm.environment=development
```

**Download:** [Elastic APM Java Agent](https://search.maven.org/artifact/co.elastic.apm/elastic-apm-agent)
</details>

<details>
<summary><strong>🔷 .NET</strong></summary>

```csharp
using Elastic.Apm;
using Elastic.Apm.NetCoreAll;

// In Startup.cs
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    app.UseAllElasticApm(Configuration);
    // ... other middleware
}
```

**appsettings.json:**
```json
{
  "ElasticApm": {
    "ServerUrl": "http://localhost:8200",
    "SecretToken": "Zi07Ksmqd1iCFyOlFWhGnhuP1KHg8fSaxx",
    "ServiceName": "my-dotnet-app",
    "ServiceVersion": "1.0.0",
    "Environment": "development"
  }
}
```

**Installation:**
```bash
dotnet add package Elastic.Apm.NetCoreAll
```
</details>

## 🔄 What's New in 9.2.0

Note: For an authoritative list of changes and breaking notes, see the official Elastic Stack 9.2.0 release notes.

- Stability and performance improvements across the stack
- Ongoing security hardening and default-safe configurations
- APM and observability enhancements
- Refer to Elastic docs for full, version-specific details

## 🔧 Troubleshooting

### 🚁 Services Won't Start

<details>
<summary><strong>Common Issues & Solutions</strong></summary>

**Port Conflicts:**
```bash
# Check if ports are in use
lsof -i :9200,5601,8200

# Kill processes using these ports
sudo kill -9 $(lsof -t -i:9200)
```

**Memory Issues:**
```bash
# Check available memory
free -h

# Increase Docker memory limit (Docker Desktop)
# Settings → Resources → Memory → 4GB+
```

**Log Analysis:**
```bash
# Quick status check
./setup.sh --status

# Detailed logs
docker compose logs -f elasticsearch
docker compose logs -f kibana
docker compose logs -f apm-server
```
</details>

### 📊 Kibana Connection Issues

<details>
<summary><strong>"Unable to retrieve version information"</strong></summary>

**Solution Steps:**
1. **Wait for Elasticsearch**:
   ```bash
   curl -u elastic:OYyP6OIrT9aUaoXjk2tLaDxx http://localhost:9200/_cluster/health
   ```

2. **Verify Kibana Password**:
   ```bash
   # Check if kibana_system password is set
   curl -u elastic:OYyP6OIrT9aUaoXjk2tLaDxx -X GET "http://localhost:9200/_security/user/kibana_system"
   ```

3. **Reset if needed**:
   ```bash
   ./setup.sh --clean
   ```
</details>

### 📈 APM Server Problems

<details>
<summary><strong>Connection & Token Issues</strong></summary>

**Verify APM Server:**
```bash
# Test APM endpoint
curl -I http://localhost:8200

# Check APM server health
curl http://localhost:8200
```

**Token Validation:**
```bash
# Test with secret token
curl -H "Authorization: Bearer Zi07Ksmqd1iCFyOlFWhGnhuP1KHg8fSaxx" http://localhost:8200
```

**Firewall Check:**
```bash
# Test network connectivity
telnet localhost 8200
```
</details>

### 🔍 Common Commands

```bash
# 🔄 Restart everything
./setup.sh --stop && ./setup.sh --clean

# 📊 Health check
curl -u elastic:OYyP6OIrT9aUaoXjk2tLaDxx http://localhost:9200/_cluster/health

# 📜 View all logs
docker compose logs -f

# 📋 Container status
docker ps -a
```

## 📝 Command Reference

### 🐳 Docker Commands

```bash
# 🚀 Start services
docker compose up -d
docker-compose up -d    # Legacy syntax

# 🛑 Stop services
docker compose down
docker-compose down     # Legacy syntax

# 📜 View logs
docker compose logs -f [service-name]
docker-compose logs -f [service-name]  # Legacy syntax

# 🧹 Reset everything (removes data)
docker compose down -v
docker-compose down -v  # Legacy syntax
```

### 🐳 Podman Commands

```bash
# 🚀 Start services
podman-compose up -d

# 🛑 Stop services
podman-compose down

# 📜 View logs
podman-compose logs -f [service-name]

# 🧹 Reset everything
podman-compose down -v
```

## 📊 Project Structure

```
📁 Elastic APM 9.2.0/
├── 📜 README.md           # 📝 This documentation
├── 🚀 setup.sh             # 🤖 Automated setup script
├── 🐳 docker-compose.yml   # 📦 Container orchestration
├── 🔐 .env                 # 🔑 Environment variables
├── 📈 apm-server.yml       # ⚙️ APM server configuration
├── 🧹 cleanup-old-indices.sh # 🗑️ Script for cleaning old indices
├── 📊 disk-usage-monitor.sh  # 📈 Script for monitoring disk usage
├── 🔄 ilm-15-day-retention.sh # 🔧 Script for configuring ILM policies
```

### 🗂️ Key Files

| File | Purpose | Description |
|------|---------|-------------|
| `setup.sh` | 🤖 Automation | Intelligent setup script with runtime detection |
| `docker-compose.yml` | 📦 Orchestration | Service definitions and networking |
| `.env` | 🔑 Configuration | Passwords, tokens, and environment variables |
| `apm-server.yml` | ⚙️ APM Config | APM server-specific settings |
| `cleanup-old-indices.sh` | 🗑️ Index Cleanup | Deletes indices older than 15 days (dry-run by default) |
| `disk-usage-monitor.sh` | 📈 Disk Monitoring | Monitors index sizes and identifies old indices |
| `ilm-15-day-retention.sh` | 🔧 ILM Configuration | Configures 15-day retention policies for indices |

## 🔐 Security Guidelines

### 🚫 Development vs Production

| Aspect | Development | Production |
|--------|-------------|------------|
| **Passwords** | 🔓 Default (provided) | 🔐 Custom secure passwords |
| **SSL/TLS** | ❌ HTTP only | ✅ HTTPS with valid certificates |
| **Network** | 🏠 Local access | 🔥 Firewall + VPN |
| **Monitoring** | 👀 Basic logging | 📊 Full observability |

### 🔒 Production Checklist

- Change all passwords in `.env` file
- Enable SSL/TLS certificates
- Configure proper network security
- Set up backup procedures
- Enable audit logging
- Configure monitoring alerts
- Review security settings

## ✨ Setup Script Features

### 🎆 Capabilities

- 🔍 **Runtime Detection**: Automatically detects Docker/Podman
- 🔧 **Service Management**: Start, stop, status checking
- ❤️ **Health Monitoring**: Waits for services to be ready
- 🔐 **Security Setup**: Configures Kibana system user automatically
- 🧹 **Clean Installation**: Option to reset everything
- 📜 **Comprehensive Logging**: Detailed progress information

### 🚀 Usage Examples

```bash
# 🎆 Normal setup
./setup.sh

# 🧹 Clean setup (removes all data)
./setup.sh --clean

# 📊 Check service status
./setup.sh --status

# 🛑 Stop all services
./setup.sh --stop

# ❓ Show help
./setup.sh --help
```

## 🔗 Useful Links

- 📚 [Elastic Stack Documentation](https://www.elastic.co/guide/index.html)
- 📈 [APM Server Reference](https://www.elastic.co/guide/en/apm/server/current/index.html)
- 📊 [Kibana User Guide](https://www.elastic.co/guide/en/kibana/current/index.html)
- 🔍 [Elasticsearch Reference](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- 🐳 [Docker Compose Reference](https://docs.docker.com/compose/)
- 🐳 [Podman Documentation](https://podman.io/getting-started/)

## 👤 Contributing

Contributions are welcome! Please feel free to:

1. 🔍 Report bugs or issues
2. 💡 Suggest improvements
3. 🔄 Submit pull requests
4. 📝 Update documentation

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ by Siyam Sarker for the Elastic Stack community**

</div>