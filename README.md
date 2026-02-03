# 🗄️ Database Migration Manager

Professional database migration tool with Docker integration and interactive terminal UI.

## 📋 Overview

A powerful command-line tool for managing database dumps, loads, and migrations across multiple database systems. All operations run in isolated Docker containers, eliminating the need for local database tools installation.

### Key Features

- **🔄 Three Operation Modes**: Dump, Load, and full Migration workflow
- **🗃️ Multi-Database Support**: MySQL/MariaDB, PostgreSQL, SQL Server
- **🐳 Docker-Powered**: All operations isolated in containers
- **📁 Auto-Naming**: Automatic timestamped filenames (`mysql-20260203-160530.txt`)
- **💾 Persistent Configuration**: Save and reuse connection settings
- **🎨 Interactive TUI**: Dialog-based terminal interface
- **🔧 Modular Architecture**: Shared utilities via `lib/log.lib.sh`

## 🚀 Quick Start

### Linux/Unix (Direct Mode)

```bash
# Make executable and run
chmod +x db-manager.sh
./db-manager.sh
```

### Linux/Unix (Docker Mode)

```bash
# Run inside Docker container
chmod +x run-docker-unix.sh
./run-docker-unix.sh
```

### Windows (Git Bash/MSYS2)

```bash
# Run inside Docker container
chmod +x run-docker-windows.sh
./run-docker-windows.sh
```

## 📦 Requirements

### Essential
- **Docker**: Must be installed and running
- **Bash**: Version 4.0 or higher

### Platform-Specific

**Linux (Direct Mode):**
- Bundled dialog binary included (x86_64)
- No additional dependencies

**Linux/Unix (Docker Mode):**
- Docker daemon access
- `/var/run/docker.sock` available

**Windows (Docker Mode):**
- Docker Desktop for Windows
- Git Bash or MSYS2 terminal

## 📂 Project Structure

```
Database-Migration-Manager/
├── db-manager.sh                    # Main orchestration script
├── run-docker-unix.sh               # Docker launcher (Linux/Unix)
├── run-docker-windows.sh            # Docker launcher (Windows)
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
│   ├── dialog/                      # Bundled dialog (Linux x86_64)
│   └── sqlpackage/                  # SQL Server tools
├── Dockerfile                       # Container image definition
├── .config                          # Auto-generated configuration
└── README.md                        # This file
```

## 📖 Usage Guide

### Initial Configuration

1. Launch the tool (direct or Docker mode)
2. Select **"Configure Database"** from main menu
3. Choose configuration approach:
   - **Complete Setup (Wizard)**: Guided step-by-step configuration
   - **Individual Settings**: Configure specific components

### Configuration Settings

#### Database Type
- MySQL/MariaDB (default port 3306)
- PostgreSQL (default port 5432)
- SQL Server (default port 1433)

#### Source Database
- Hostname/IP and port
- Authentication credentials
- Database name

#### Destination Database
- Hostname/IP and port
- Authentication credentials
- Database name

#### Dump Directory
- Local directory path for dump files
- Files auto-named: `<engine>-<timestamp>.txt`
- Example: `postgres-20260203-160530.txt`

### Operations

#### 🔽 Dump (Export)

Exports a database to an automatically timestamped file.

**How it works:**
- Generates filename with timestamp
- Saves to configured directory
- Uses appropriate database tool:
  - **MySQL**: `mysqldump` (full schema + data)
  - **PostgreSQL**: `pg_dump -F c` (custom format)
  - **SQL Server**: `sqlcmd` with BACKUP DATABASE

**Example output:**
```
postgres-20260203-160530.txt
mysql-20260203-161245.txt
sqlserver-20260203-162000.txt
```

#### 🔼 Load (Import)

Imports a database from a selected dump file.

**How it works:**
- Prompts for file selection
- Shows most recent dump as default
- Validates file exists
- Imports using appropriate tool:
  - **MySQL**: `mysql` client
  - **PostgreSQL**: `pg_restore --clean --if-exists`
  - **SQL Server**: `sqlcmd` with RESTORE DATABASE

#### 🔄 Migrate (Full Workflow)

Complete migration from source to destination in one operation.

**Process:**
1. Dumps from source database
2. Loads into destination database
3. Uses single timestamped file
4. Atomic operation (all or nothing)

**Use cases:**
- Clone production to staging
- Migrate between servers
- Backup and restore workflows
- Database version upgrades

### Menu Navigation

- **Arrow Keys**: Navigate options
- **Enter**: Select/Confirm
- **ESC**: Return to previous menu (never exits)
- **Tab**: Switch between form fields

## ⚙️ Configuration File

Location: `.config` (auto-generated in project root)

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
DUMP_DIR=/home/user/Downloads
```

### Security Best Practices

```bash
# Restrict file permissions
chmod 600 .config

# Add to gitignore
echo ".config" >> .gitignore

# Never commit credentials
git add .gitignore
```

## 🐳 Docker Details

### Container Images

| Database | Image | Tag | Approx Size |
|----------|-------|-----|-------------|
| MySQL | `mysql` | `8.0` | ~500MB |
| PostgreSQL | `postgres` | `16-alpine` | ~240MB |
| SQL Server | `mcr.microsoft.com/mssql-tools` | `latest` | ~150MB |

### Docker Network

- **Name**: `database-migration-network`
- **Driver**: bridge
- **Auto-created**: Yes
- **Isolation**: Container-to-container communication only

### Container Lifecycle

- **Ephemeral**: Containers removed after each operation (`--rm`)
- **Volumes**: Only `.config` mounted for persistence
- **Naming**: Auto-generated with timestamp

### Docker Mode vs Direct Mode

**Docker Mode (`run-docker-*.sh`):**
- ✅ Runs inside container with all dependencies
- ✅ Consistent environment across platforms
- ✅ No local dialog installation needed
- ⚠️ Requires Docker socket access
- ⚠️ Slightly slower startup

**Direct Mode (`db-manager.sh`):**
- ✅ Faster execution
- ✅ Direct access to host filesystem
- ✅ Lower overhead
- ⚠️ Requires system dialog (or uses bundled)
- ⚠️ Linux x86_64 only for bundled dialog

## 🔧 Troubleshooting

### Dialog Not Found (Direct Mode)

**Symptom**: "Dialog not available" error

**Solution**:
```bash
# Debian/Ubuntu
sudo apt-get install dialog

# RHEL/CentOS
sudo yum install dialog

# Fedora
sudo dnf install dialog

# Arch Linux
sudo pacman -S dialog
```

### Docker Permission Denied

**Symptom**: Cannot connect to Docker socket

**Linux Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply changes
newgrp docker
```

**Windows Solution**:
- Ensure Docker Desktop is running
- Check Docker Desktop → Settings → Resources → WSL Integration

### Configuration Not Persisting (Docker Mode)

**Symptom**: Configuration lost after container restart

**Cause**: `.config` created as directory instead of file

**Solution**:
```bash
# Remove incorrect directory
rm -rf .config

# Recreate as file
touch .config

# Run script again (will handle this automatically)
./run-docker-unix.sh
```

### Dump Directory Not Configured

**Symptom**: Error "Dump directory not configured"

**Solution**:
1. Go to Configure Database menu
2. Select "Dump Directory (Auto-named files)"
3. Enter valid absolute path (e.g., `/home/user/Downloads`)

### File Not Found During Load

**Symptom**: "File not found" when loading dump

**Solution**:
```bash
# Verify file exists
ls -lh /path/to/dump/directory/

# Check permissions
chmod 644 /path/to/dump/*.txt

# Ensure using absolute path
```

### SQL Server Connection Issues

**Common issues and solutions:**

- **Cannot connect**: Use IP address instead of `localhost`
- **Port not open**: Verify port 1433 is accessible
- **Authentication failed**: Enable SQL Server mixed mode authentication
- **Password error**: Ensure password meets SQL Server complexity requirements

### PostgreSQL Version Mismatch

**Symptom**: "pg_dump version mismatch" warning

**Info**: Script uses PostgreSQL 16

**Solution**:
- Dumps are forward-compatible
- Loading to older versions may require manual adjustments
- Consider upgrading target PostgreSQL version

### Network Already Exists

**Symptom**: "network database-migration-network already exists"

**Solution**:
```bash
# Remove existing network
docker network rm database-migration-network

# Script will recreate automatically on next run
```

## 🔒 Security Considerations

### Credential Storage
- ⚠️ **Plain Text**: Credentials stored unencrypted in `.config`
- 🔐 **Mitigation**: Use `chmod 600 .config` to restrict access
- 🚫 **Never commit**: Add `.config` to `.gitignore`
- 💡 **Best Practice**: Use read-only database users when possible

### Docker Socket Access
- ⚠️ **Full Access**: Docker mode mounts `/var/run/docker.sock`
- 🔐 **Implication**: Full control over Docker daemon
- 🚫 **Production**: Use direct mode with restricted permissions
- 💡 **Best Practice**: Only use Docker mode in development environments

### Network Exposure
- ✅ **Isolated**: Containers use dedicated bridge network
- ✅ **Ephemeral**: Containers removed immediately after operations
- ⚠️ **External**: Connections to external databases use host network
- 💡 **Best Practice**: Use VPN or SSH tunnels for remote databases

### Dump Files
- ⚠️ **Sensitive Data**: Dumps contain complete database contents
- 🔐 **Mitigation**: Encrypt dump directory or use secure storage
- 🚫 **Shared Drives**: Avoid network shares for sensitive dumps
- 💡 **Best Practice**: Set restrictive permissions on dump directory

## 🪟 Windows Specific Notes

### Prerequisites
- Docker Desktop for Windows (running)
- Git Bash or MSYS2 terminal
- WSL2 backend (recommended)

### Running on Windows

```bash
# Navigate to project
cd Database-Migration-Manager

# Make executable
chmod +x run-docker-windows.sh

# Launch
./run-docker-windows.sh
```

### Important Notes

- **Use Docker Mode**: Direct mode not supported on Windows
- **Path Conversion**: Script handles Windows path conversion automatically
- **Docker Socket**: Mounted via Docker Desktop's named pipe
- **File Sharing**: Ensure Docker has access to project directory

### Common Windows Issues

**Docker not found:**
```bash
# Verify Docker Desktop is running
docker --version

# Check Docker service
docker ps
```

**Path conversion errors:**
- Script sets `MSYS_NO_PATHCONV=1` automatically
- If issues persist, use absolute Windows paths

**Line ending issues:**
```bash
# Convert to Unix line endings
dos2unix *.sh operation/*.sh

# Or configure git
git config --global core.autocrlf input
```

## 🤝 Contributing

### Adding New Database Engines

1. **Create operation scripts** in `operation/`:
   ```bash
   <engine>-dump.operation.sh
   <engine>-load.operation.sh
   ```

2. **Script template**:
   ```bash
   #!/bin/bash
   source "$(dirname "$0")/../lib/log.lib.sh"
   
   # Parse parameters
   HOST="$1"
   PORT="$2"
   USER="$3"
   PASS="$4"
   DB="$5"
   DUMP_FILE="$6"
   
   # Docker operation logic
   docker run --rm \
       --network database-migration-network \
       -v "$(dirname "$DUMP_FILE"):/backup" \
       <image>:<tag> \
       <command>
   ```

3. **Update `db-manager.sh`**:
   - Add to `configure_db_type()` menu
   - Add case in `perform_dump()`
   - Add case in `perform_load()`
   - Add case in `perform_migrate()`

4. **Test thoroughly**:
   - Dump operation creates valid file
   - Load operation restores correctly
   - Migrate completes full workflow
   - Auto-naming generates correct filename

### Code Style Guidelines

- **Indentation**: 4 spaces (no tabs)
- **Variables**: Always quote: `"$VAR"`
- **Functions**: Use `log_*` functions for output
- **Errors**: Handle gracefully, never `set -e`
- **Comments**: Explain why, not what
- **Naming**: Use descriptive names

## 📝 License

This project is provided as-is for educational and professional use.

## 🙏 Acknowledgments

- **Dialog Project**: Excellent TUI library for Bash
- **Docker**: Making containerization accessible
- **MySQL Community**: Reliable database tools
- **PostgreSQL Community**: Robust open-source database
- **Microsoft**: SQL Server tooling

## 📞 Support

For issues, questions, or contributions:

1. Check existing documentation in this README
2. Review troubleshooting section
3. Verify Docker is running and accessible
4. Check `.config` file permissions and content
5. Test with simple local databases first

---

**Built for database administrators and developers who value automation and reliability.**

*Version 2.0 - February 2026*
