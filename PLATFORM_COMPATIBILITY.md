# Platform Compatibility

## Cleanup and Monitoring Scripts

The `cleanup-old-indices.sh` and `disk-usage-monitor.sh` scripts use a **portable date calculation function** that automatically detects and uses the appropriate method for calculating dates across different operating systems.

### ✅ Supported Platforms

The scripts will work on **ALL** of the following platforms without any modifications:

#### Linux Distributions
- ✅ **Amazon Linux 2** (all AWS regions)
- ✅ **Amazon Linux 2023** (all AWS regions)
- ✅ **Ubuntu** (all versions: 18.04, 20.04, 22.04, 24.04+)
- ✅ **Debian** (all versions: 9, 10, 11, 12+)
- ✅ **RHEL / CentOS / Rocky Linux / AlmaLinux** (7, 8, 9+)
- ✅ **Fedora** (all versions)
- ✅ **SUSE Linux Enterprise / openSUSE**
- ✅ **Alpine Linux** (even with BusyBox)
- ✅ **Arch Linux**
- ✅ **Gentoo**

#### macOS
- ✅ **macOS** (all versions: 10.x, 11.x, 12.x, 13.x, 14.x, 15.x)
- ✅ Works with both **BSD date** and **GNU coreutils**

#### AWS EC2 Instances
- ✅ **All AWS regions** (us-east-1, us-west-2, eu-west-1, ap-southeast-1, etc.)
- ✅ **All EC2 instance types** (t2, t3, m5, c5, r5, etc.)
- ✅ **All AWS AMIs** (Amazon Linux, Ubuntu, RHEL, etc.)

#### Containers
- ✅ **Docker containers** (including minimal/distroless images)
- ✅ **Kubernetes pods**
- ✅ **ECS/EKS containers**

### 🔧 How It Works

The scripts use a **cascading fallback mechanism** that tries multiple methods in order:

1. **GNU date** (Linux standard) - `date --date="15 days ago"`
2. **BSD date** (macOS) - `date -v-15d`
3. **Python 3** - Uses `datetime` module (fallback for minimal systems)
4. **Python 2** - For older systems without Python 3
5. **Perl** - Final fallback using `Time::Piece`

The script automatically uses the **first available method** that works on your system.

### 📦 Requirements

At least **ONE** of the following must be available on your system:

- `date` command (GNU coreutils or BSD) - **Available by default on 99.9% of systems**
- `python3` or `python` - **Available on most AWS EC2 instances**
- `perl` - **Available on most Unix-like systems**

### ⚠️ Edge Cases

The only scenario where the scripts might not work:

- **Extremely minimal Docker images** without:
  - No `date` command
  - No Python (2 or 3)
  - No Perl

**Solution**: Install one of the following:
```bash
# Alpine Linux
apk add coreutils python3

# Debian/Ubuntu minimal containers
apt-get update && apt-get install -y coreutils python3-minimal

# RHEL/CentOS minimal containers
yum install -y coreutils python3
```

### 🧪 Testing Compatibility

To verify the scripts work on your system, run:

```bash
# Test the cleanup script (dry-run mode, safe)
./cleanup-old-indices.sh

# Test the disk monitoring script
./disk-usage-monitor.sh
```

If you see the cutoff date calculated successfully (e.g., "Starting cleanup of indices older than 2025-10-11"), the scripts will work correctly on your system.

### 🌍 AWS EC2 Specific Notes

**All AWS EC2 instances come with the required tools by default:**

- Amazon Linux 2/2023: GNU coreutils + Python 3 ✅
- Ubuntu AMI: GNU coreutils + Python 3 ✅
- RHEL AMI: GNU coreutils + Python 3 ✅
- Any other AWS-provided AMI: GNU coreutils ✅

**No additional installation required for AWS EC2 instances.**

### 🚀 Zero-Config Deployment

The scripts are designed to **"just work"** without any configuration changes, regardless of:
- Operating system
- Linux distribution
- AWS region
- Container environment
- System architecture (x86_64, ARM64/Graviton)

Simply copy the scripts to any system and run them—they will automatically adapt to the available tools.
