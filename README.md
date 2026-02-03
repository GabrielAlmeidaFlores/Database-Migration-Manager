# 🗄️ Database Migration Manager

Professional database migration tool with Docker integration, interactive TUI, and automatic file naming.

## ✨ Features

### Core Capabilities
- **🔄 Three Operation Modes**: Dump (Export), Load (Import), and Migrate (Full workflow)
- **🗃️ Multi-Database Support**: MySQL/MariaDB, PostgreSQL, and SQL Server
- **🐳 Docker-Powered**: All operations run in isolated Docker containers
- **📁 Auto-Named Files**: Timestamps files automatically (`mysql-20260203-160530.txt`)
- **💾 Persistent Config**: Save and reuse connection settings
- **🎨 Interactive TUI**: Beautiful dialog-based terminal interface

### Technical Highlights
- **Zero External Dependencies**: Bundled dialog binary for Linux x86_64
- **Shared Utilities**: Modular library system with `lib/log.lib.sh`
- **Cross-Platform**: Docker mode for Windows/macOS/Linux
- **Graceful Error Handling**: Never exits on ESC, always returns to menu
- **Network Isolation**: Dedicated Docker network for secure operations

## 📋 Requirements

### Minimum Requirements
- **Docker**: Must be installed and running
- **Bash**: Version 4.0 or higher
- **Disk Space**: Sufficient space for database dumps

### Platform Support
- **Linux**: x86_64 (bundled dialog included) - supports both Direct and Docker modes
- **Windows**: Direct mode only (requires Git Bash or WSL + Docker Desktop)
- **macOS**: Direct mode only (requires Docker Desktop + system dialog)

## 📂 Project Structure

```
Database-Migration-Manager/
├── db-manager.sh                    # Main orchestration script
├── operation/                       # Database-specific operations
│   ├── mysql-dump.operation.sh      # MySQL export
│   ├── mysql-load.operation.sh      # MySQL import
│   ├── postgres-dump.operation.sh   # PostgreSQL export
│   ├── postgres-load.operation.sh   # PostgreSQL import
│   ├── sqlserver-dump.operation.sh  # SQL Server export
│   └── sqlserver-load.operation.sh  # SQL Server import
├── lib/
│   └── log.lib.sh                   # Shared utilities and logging
├── dependencies/
│   ├── dialog/                      # Bundled dialog binary
│   │   └── dialog
│   └── sqlpackage/                  # SQL Server tools
├── Dockerfile                       # Container image for Docker mode
├── run-docker.sh                    # Docker mode launcher
├── .config                          # Auto-generated configuration
└── README.md                        # This file
```

## 🚀 Quick Start

### Direct Mode (Linux)

```bash
# Clone the repository
git clone <repository-url>
cd Database-Migration-Manager

# Make scripts executable
chmod +x db-manager.sh run-docker.sh operation/*.operation.sh

# Launch the manager
./db-manager.sh
```

### Docker Mode (Linux Only)

```bash
# Build and run in Docker
./run-docker.sh
```

**Note**: Docker mode requires `/var/run/docker.sock` access and works reliably only on **Linux**. For Windows and macOS, use **Direct Mode** instead (see below).

Docker mode automatically:
- Builds the `database-migration-manager` image
- Mounts Docker socket for container operations
- Mounts `.config` for persistent settings
- Creates `dumps/` directory for exports

### Direct Mode (Windows/macOS)

On Windows (Git Bash) or macOS, run directly:

```bash
# Make script executable
chmod +x db-manager.sh

# Run directly
./db-manager.sh
```

**Requirements**:
- Docker Desktop must be running
- System dialog may need to be installed (`brew install dialog` on macOS)

## 📖 Usage Guide

### Initial Configuration

1. **Launch the tool**: `./db-manager.sh`
2. **Select "Configure Database"** from main menu
3. **Choose configuration method**:
   - **Complete Setup (Wizard)**: Step-by-step guided configuration
   - **Individual options**: Configure specific components

#### Configuration Options

**Database Type**
- MySQL/MariaDB (Port 3306)
- PostgreSQL (Port 5432)
- SQL Server (Port 1433)

**Source Database**
- Host and port
- Username and password
- Database name

**Destination Database**
- Host and port
- Username and password
- Database name

**Dump Directory**
- Directory where dumps are saved/loaded
- Files auto-named: `<engine>-<timestamp>.txt`
- Default: `$HOME/Downloads`

### Operations

#### 🔽 Dump (Export Database)

Exports a database to a timestamped file:

```bash
# Example output
postgres-20260203-160530.txt
mysql-20260203-161245.txt
sqlserver-20260203-162000.txt
```

**How it works:**
- Automatically generates filename with timestamp
- Creates file in configured dump directory
- Uses database-specific tools:
  - **MySQL**: `mysqldump` with full schema and data
  - **PostgreSQL**: `pg_dump -F c` (custom format)
  - **SQL Server**: `sqlcmd` with `BACKUP DATABASE`

#### 🔼 Load (Import Database)

Imports a database from a selected dump file:

```bash
# Interactive file selection
- Shows most recent dump as default
- Enter full path or use suggested file
```

**How it works:**
- Prompts for dump file selection
- Validates file exists
- Imports using appropriate tool:
  - **MySQL**: `mysql` client
  - **PostgreSQL**: `pg_restore --clean --if-exists`
  - **SQL Server**: `sqlcmd` with `RESTORE DATABASE`

#### 🔄 Migrate (Complete Workflow)

Full migration from source to destination:

1. **Dumps** from source database
2. **Loads** into destination database
3. Uses single timestamped file
4. Atomic operation

**Use case:** Clone production to staging, migrate between servers, backup and restore.

### Menu Navigation

- **Arrow Keys**: Navigate options
- **Enter**: Select/Confirm
- **ESC**: Return to previous menu (never exits)
- **Tab**: Switch between form fields

## ⚙️ Configuration File

Location: `.config` (auto-generated)

```bash
DB_TYPE=postgres
SRC_HOST=10.8.0.1
SRC_PORT=5432
SRC_USER=postgres
SRC_PASS=yourpassword
SRC_DB=production_db
DST_HOST=10.8.0.1
DST_PORT=5432
DST_USER=postgres
DST_PASS=yourpassword
DST_DB=staging_db
DUMP_DIR=/home/user/dumps
```

**Security Best Practices:**
```bash
# Restrict access to config file
chmod 600 .config

# Ensure it's not tracked by git
echo ".config" >> .gitignore
```

## 🐳 Docker Details

### Images Used

| Database | Image | Tag | Size |
|----------|-------|-----|------|
| MySQL | `mysql` | `8.0` | ~500MB |
| PostgreSQL | `postgres` | `16-alpine` | ~240MB |
| SQL Server | `mcr.microsoft.com/mssql-tools` | `latest` | ~150MB |

### Network Configuration

- **Network Name**: `db-migration-net`
- **Driver**: bridge
- **Auto-created**: Yes
- **Isolation**: Container-to-container only

### Container Behavior

- **Lifecycle**: Containers are ephemeral (removed after operation)
- **Volumes**: Dump files mounted as volumes
- **Naming**: Auto-generated with timestamp

## 🔧 Troubleshooting

### Dialog Not Working

**Symptom**: Dialog interface doesn't appear or crashes

**Solution**:
```bash
# Install system dialog
sudo apt-get install dialog  # Debian/Ubuntu
sudo yum install dialog       # RHEL/CentOS
brew install dialog           # macOS
```

### Docker Permission Denied

**Symptom**: Cannot connect to Docker socket

**Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Restart session or use
newgrp docker
```

### Dump Directory Not Configured

**Symptom**: Error message "Dump directory not configured"

**Solution**:
1. Go to "Configure Database"
2. Select "Dump Directory (Auto-named files)"
3. Enter valid directory path

### File Not Found During Load

**Symptom**: "File not found" when loading dump

**Solution**:
- Verify dump file exists: `ls -lh /path/to/dumps/`
- Check file permissions: `chmod 644 /path/to/dumps/*.txt`
- Use absolute paths

### SQL Server Connection Fails

**Symptom**: Cannot connect to SQL Server

**Solution**:
- Use IP address, not `localhost`
- Verify port 1433 is open
- Check SQL Server authentication mode (mixed mode required)
- Ensure password meets complexity requirements

### PostgreSQL Version Mismatch

**Symptom**: "pg_dump version mismatch" warning

**Solution**:
- Script uses PostgreSQL 16
- Dumps are forward-compatible
- If loading to older version, may need manual adjustment

### Network Already Exists

**Symptom**: "network db-migration-net already exists"

**Solution**:
```bash
# Remove existing network
docker network rm db-migration-net

# Script will recreate automatically
```

## 🔒 Security Considerations

### Credential Storage
- ⚠️ **Plain Text**: Credentials stored unencrypted in `.config`
- 🔐 **Mitigation**: Use `chmod 600 .config` to restrict access
- 🚫 **Never commit**: Add `.config` to `.gitignore`

### Docker Socket Access
- ⚠️ **Full Access**: Docker mode mounts `/var/run/docker.sock`
- 🔐 **Mitigation**: Only run in trusted environments
- 🚫 **Production**: Use direct mode with restricted Docker permissions

### Network Exposure
- ✅ **Isolated**: Containers use dedicated Docker network
- ✅ **Ephemeral**: Containers removed after operations
- ⚠️ **Host Network**: Connections to external databases

### Dump Files
- ⚠️ **Sensitive Data**: Dumps contain full database contents
- 🔐 **Mitigation**: Encrypt dump directory or use secure storage
- 🚫 **Shared Drives**: Avoid storing dumps on network shares

## 🪟 Windows Usage

### Prerequisites
- Docker Desktop for Windows
- Git Bash or WSL (Windows Subsystem for Linux)

### Running on Windows

**Recommended: Direct Mode**

```bash
# Using Git Bash
cd Database-Migration-Manager
chmod +x db-manager.sh operation/*.operation.sh
./db-manager.sh

# Or using WSL
wsl
cd /mnt/c/path/to/Database-Migration-Manager
chmod +x db-manager.sh operation/*.operation.sh
./db-manager.sh
```

**Note**: Docker mode (`run-docker.sh`) is **not recommended** on Windows due to Docker socket mounting limitations. Use direct mode instead.

### Common Windows Issues

**Docker not found in Git Bash:**
```bash
# Add Docker to PATH
export PATH="$PATH:/c/Program Files/Docker/Docker/resources/bin"
```

**Line ending issues:**
```bash
# Convert to Unix line endings
dos2unix *.sh operation/*.sh
```

## 🤝 Contributing

### Adding New Database Engines

1. **Create operation scripts** in `operation/`:
   ```bash
   <engine>-dump.operation.sh
   <engine>-load.operation.sh
   ```

2. **Follow the pattern**:
   ```bash
   #!/bin/bash
   source "$(dirname "$0")/../lib/log.lib.sh"
   
   # Parameters
   HOST="$1"
   PORT="$2"
   # ... etc
   
   # Operation logic
   docker run --rm ...
   ```

3. **Update main script**:
   - Add engine to `configure_db_type()`
   - Add case statements in `perform_dump()`, `perform_load()`, `perform_migrate()`

4. **Test thoroughly**:
   - Test dump operation
   - Test load operation
   - Test migrate workflow
   - Verify auto-naming works

### Code Style

- Use 4-space indentation
- Quote all variables: `"$VAR"`
- Use `log_*` functions for output
- Handle errors gracefully
- Never use `set -e`

## 📝 License

This project is provided as-is for educational and professional use.

## 🙏 Acknowledgments

- **Dialog Project**: For the excellent TUI library
- **Docker**: For making containerization accessible
- **Database Communities**: MySQL, PostgreSQL, and SQL Server teams for their robust tools

---

**Made with ❤️ for database administrators and developers**
