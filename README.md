# Znuny Docker Setup (Debian Apache2 Base)

This repository provides a ready-to-use Docker setup for [Znuny](https://www.znuny.org/), including Apache2, Cron, and the Znuny Daemon. MariaDB runs as a separate service for modularity and data safety.  
**Suitable for both testing and production environments.**

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Environment Variables](#environment-variables)
- [SSL Support](#ssl-support)
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

- Based on the official Debian Apache2 image for full mod_perl and CGI support
- Automated download and installation of Znuny (default: version 7.1.7, see [Znuny Downloads](https://www.znuny.org))
- Starts Apache, Cron, and the Znuny Daemon inside the container
- Persistent storage for Znuny data, Apache logs/certs, and MariaDB database
- Flexible configuration via Docker Compose and environment variables
- MariaDB settings optimized for large attachments
- Ready for reverse proxy and SSL (self-signed or real certificates)

---

## Architecture

Plaintext diagram (for copy/paste):

  [Browser] --> [Znuny (Apache2)] --> [MariaDB]

- All containers are orchestrated via `docker-compose.yaml`.
- Znuny application and database run as separate containers for modularity and security.
- Volumes ensure data, logs, and certificates persist across restarts.

---

## Requirements

- Docker: https://docs.docker.com/get-docker/
- Docker Compose: https://docs.docker.com/compose/install/

---

## Quick Start

1. **Clone the repository**

    ```
    git clone https://github.com/Erik-Donath/znuny-docker.git
    cd znuny-docker
    ```

2. **Build and start the containers**

    ```
    docker compose up --build
    ```

    Znuny will be available at:  
    http://localhost:8080/znuny/installer.pl

---

## Environment Variables

### Znuny Service (`znuny-app`)

- `TZ` – Timezone for the container (default: Europe/Berlin)
- `LANG` – Locale (default: en_US.UTF-8)
- `LANGUAGE` – Locale (default: en_US:en)
- `LC_ALL` – Locale (default: en_US.UTF-8)
- `VIRTUAL_HOST` – For reverse proxy setups (optional)
- `LETSENCRYPT_HOST` – For SSL automation (optional)
- `LETSENCRYPT_EMAIL` – For SSL automation (optional)

### MariaDB Service (`db`)

- `MYSQL_ROOT_PASSWORD` – MariaDB root user password (**change this for production!**)
- `MYSQL_USER` – MariaDB user for the app (default: root)
- `MYSQL_PASSWORD` – Password for the MariaDB user (default: znuny_password)
- `MYSQL_DATABASE` – Database name for Znuny (default: znuny)
- `TZ` – Timezone for the container

Set these in the `docker-compose.yaml` file as needed.

---

## SSL Support

1. **Mount your SSL certificates** into the `apache-certs` volume (`/etc/apache2/conf/certs`).
2. **Configure your Apache SSL site** as needed (see Znuny/Apache documentation).
3. **Certificates required:**
    - `server.crt` (certificate)
    - `server.key` (private key)
4. **Reverse proxy:**  
   You may also use an external reverse proxy (nginx, Traefik, etc.) for SSL.

---

## Installation Guide

1. **Open the Znuny web installer**

    Go to: http://localhost:8080/znuny/installer.pl

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

- **Znuny data:** stored in `./znuny-data` (`/opt/znuny`)
- **MariaDB data:** stored in `./db-data` (`/var/lib/mysql`)
- **Apache logs:** stored in `./apache-logs` (`/var/log/apache2`)
- **Apache certs:** stored in `./apache-certs` (`/etc/apache2/conf/certs`)

Your data, logs, and certificates will persist across container restarts and rebuilds as long as you do not delete the directories.

---

## Important Files

- `Dockerfile` – Based on Debian Apache2, installs Znuny and all required packages
- `entrypoint.sh` – Starts Cron, Znuny Daemon, and Apache2
- `docker-compose.yaml` – Orchestrates Znuny app and MariaDB with bind mounts and environment variables

---

## Useful Commands

- **Stop the containers:**  
    `docker compose down`
- **Restart the containers:**  
    `docker compose restart`
- **Delete all volumes (Warning: data loss!):**  
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
    Make sure Docker volumes (the `./znuny-data`, `./db-data`, etc. directories) are not owned by root on the host.
- **Port conflicts:**  
    Make sure port 8080 (and 8443 if using SSL) is available on your host.
- **Installer fails to connect to database:**  
    Wait a few seconds for the database to initialize, then retry.

---

## Security Recommendations

- Change all default passwords before using in production.
- Enable SSL for Apache (see [SSL Support](#ssl-support)).
- Limit container network exposure as needed.
- Regularly back up your Docker volumes/directories.
- Keep your images up to date and monitor for security advisories.

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

---

## License

MIT License

---

**Questions or improvements?**  
Open an [issue](https://github.com/Erik-Donath/znuny-docker/issues) or a pull request!

---

*Note: As of July 2025, the latest version available on the [Znuny website](https://www.znuny.org) is 7.1.7. If you intend to use a newer version, verify the download and directory naming conventions as they may change.* [1]
