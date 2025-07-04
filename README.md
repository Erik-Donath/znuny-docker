# Znuny Docker Setup

This repository provides a ready-to-use Docker setup for [Znuny](https://www.znuny.org/), including Apache2, Cron, and the Znuny Daemon. MariaDB runs as a separate service.  
**Suitable for both testing and production environments.**

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Environment Variables](#environment-variables)
- [Installation Guide](#installation-guide)
- [Data Persistence](#data-persistence)
- [Important Files](#important-files)
- [Useful Commands](#useful-commands)
- [Troubleshooting](#troubleshooting)
- [Security Recommendations](#security-recommendations)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- Automated download and installation of Znuny
- Starts Apache, Cron, and the Znuny Daemon inside the container
- Persistent storage for Znuny data and MariaDB database
- Flexible database configuration via Docker Compose
- MariaDB settings optimized for large attachments

---

## Architecture

```
[User] --> [Browser] --> [Apache2/Znuny Docker Container] --> [MariaDB Docker Container]
```

- All containers are orchestrated via `docker-compose.yaml`.
- Znuny application and database run as separate containers for modularity and security.

---

## Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

---

## Quick Start

1. **Clone the repository**

   ```sh
   git clone https://github.com/Erik-Donath/znuny-docker.git
   cd znuny-docker
   ```

2. **Build and start the containers**

   ```sh
   docker compose up --build
   ```

   Znuny will be available at: [http://localhost:8080/znuny/installer.pl](http://localhost:8080/znuny/installer.pl)

---

## Environment Variables

### Znuny Service

- `TZ` – Timezone for the container (default: Europe/Berlin).

### MariaDB Service

- `MYSQL_ROOT_PASSWORD` – MariaDB root user password. **Change this for production!**
- `MYSQL_USER` – MariaDB user for the app (default: root).
- `MYSQL_PASSWORD` – Password for the MariaDB user (default: znuny_password).
- `TZ` – Timezone for the container.

These can be set in the `docker-compose.yaml` file.

---

## Installation Guide

1. **Open the Znuny web installer**

   Go to: [http://localhost:8080/znuny/installer.pl](http://localhost:8080/znuny/installer.pl)

2. **Enter the following database connection details in the installer:**

   | Field     | Value           |
   |-----------|-----------------|
   | Host      | db              |
   | User      | root            |
   | Password  | znuny_password  |
   | Database  | znuny           |

   > **Note:** The database `znuny` and the Znuny database user will be created automatically by the installer.  
   > You only need to provide the MariaDB user and password as defined above.

3. **Finish the installer and start using Znuny**

---

## Data Persistence

- **Znuny data:** stored in the `znuny-data` volume
- **MariaDB data:** stored in the `db-data` volume

Your data will persist across container restarts and rebuilds as long as you do not delete the volumes.

---

## Important Files

- `Dockerfile` – Based on Debian, installs Znuny and all required packages
- `entrypoint.sh` – Starts Cron, Znuny Daemon, and Apache
- `docker-compose.yaml` – Orchestrates Znuny app and MariaDB with volumes

---

## Useful Commands

- **Stop the containers:**  
  `docker compose down`
- **Restart the containers:**  
  `docker compose restart`
- **Delete database and Znuny volumes (Warning: data loss!):**  
  `docker compose down -v`
- **Check logs:**  
  `docker compose logs`

---

## Troubleshooting

- **Znuny is not reachable:**  
  Check logs with `docker compose logs`. Ensure both containers are running and port 8080 is not in use.
- **Database connection errors:**  
  Ensure MariaDB container is running, and credentials match those in the installer.
- **Permission errors:**  
  Make sure Docker volumes are not owned by root on the host.
- **Port conflicts:**  
  Make sure port 8080 is available on your host.

---

## Security Recommendations

- Change all default passwords before using in production.
- Consider enabling SSL for Apache.
- Limit container network exposure as needed.
- Regularly back up your Docker volumes.

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

---

## License

MIT License

---

**Questions or improvements?**  
Open an [issue](https://github.com/Erik-Donath/znuny-docker/issues) or a pull request!
