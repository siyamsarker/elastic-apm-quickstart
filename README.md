# 🚀 Elastic Stack 9.0.3 - Complete APM Setup

> **Production-ready Elasticsearch, Kibana, and APM Server deployment with automated setup**

[![Elastic Stack](https://img.shields.io/badge/Elastic%20Stack-9.0.3-005571)](https://www.elastic.co/)
[![Docker](https://img.shields.io/badge/Docker-supported-2496ED)](https://www.docker.com/)
[![Podman](https://img.shields.io/badge/Podman-supported-892CA0)](https://podman.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📖 Overview

This repository provides a **complete, production-ready Elastic Stack 9.0.3** setup with:

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
-Delastic.apm.server_urls=http://localhost:8200
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

## 🔄 What's New in 9.0.3

- 🔒 **Enhanced Security**: Improved authentication and authorization
- 🚀 **Performance**: Better resource utilization and faster startup
- 📊 **Monitoring**: Enhanced APM capabilities and metrics
- 🔧 **Configuration**: Streamlined setup with better defaults

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
📁 Elastic APM 9.0.3/
├── 📜 README.md           # 📝 This documentation
├── 🚀 setup.sh             # 🤖 Automated setup script
├── 🐳 docker-compose.yml   # 📦 Container orchestration
├── 🔐 .env                 # 🔑 Environment variables
└── 📈 apm-server.yml       # ⚙️ APM server configuration
```

### 🗂️ Key Files

| File | Purpose | Description |
|------|---------|-------------|
| `setup.sh` | 🤖 Automation | Intelligent setup script with runtime detection |
| `docker-compose.yml` | 📦 Orchestration | Service definitions and networking |
| `.env` | 🔑 Configuration | Passwords, tokens, and environment variables |
| `apm-server.yml` | ⚙️ APM Config | APM server-specific settings |

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
