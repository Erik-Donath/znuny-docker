# Znuny Docker Setup

A production-ready Docker setup for [Znuny](https://www.znuny.org/) based on Debian with Apache2, Cron, and the Znuny Daemon. MariaDB is provided as a separate container for modularity and data integrity.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Upgrading Znuny](#upgrading-znuny)
- [SSL Support](#ssl-support)
- [Data Persistence & Backup](#data-persistence--backup)
- [Troubleshooting](#troubleshooting)
- [Security Recommendations](#security-recommendations)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- Based on official Debian Apache2 for mod_perl and CGI support
- Automated download/installation of configurable Znuny version
- Separate MariaDB container
- Persistent storage for Znuny data, logs, and certificates
- Healthchecks for app and database containers
- Flexible configuration via environment variables
- Ready for reverse proxy and SSL

---

## Architecture

```plaintext
[Browser] <---> [Znuny (Apache2)] <---> [MariaDB]
```

- Containers are orchestrated via `docker-compose.yaml`.
- App and DB run separately for modularity and security.
- Volumes persist data, logs, and SSL certs.

---

## Requirements

- Docker ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose ([Install Compose](https://docs.docker.com/compose/install/))

---

## Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/Erik-Donath/znuny-docker.git
   cd znuny-docker
   ```

2. **Build and start containers**
   ```bash
   docker compose up --build
   ```
   Znuny will be available at: [http://localhost:8080/znuny/installer.pl](http://localhost:8080/znuny/installer.pl)

---

## Configuration

### Environment Variables

**Znuny Service (`znuny-app`):**

- `TZ` – Timezone (default: Europe/Berlin)
- `LANG`, `LANGUAGE`, `LC_ALL` – Locale settings
- `ZNUNY_VERSION` – Znuny version (default: 7.1.7, set at build time)
- `VIRTUAL_HOST`, `LETSENCRYPT_HOST`, `LETSENCRYPT_EMAIL` – For reverse proxy/SSL setups

**MariaDB Service (`db`):**

- `MYSQL_ROOT_PASSWORD` – MariaDB root password (**change for production!**)
- `MYSQL_USER` – Database user (default: root)
- `MYSQL_PASSWORD` – DB user password (default: znuny_password)
- `MYSQL_DATABASE` – DB name (default: znuny)
- `TZ` – Timezone

Set these in `docker-compose.yaml` as required.

---

## Upgrading Znuny

To use a different Znuny version:

1. Edit `ZNUNY_VERSION` in `docker-compose.yaml` under `build.args`.
2. Rebuild:
   ```bash
   docker compose build znuny-app
   docker compose up -d
   ```
3. Follow usual installer steps.

---

## SSL Support

- Mount your SSL certs into the `apache-certs` volume (`/etc/apache2/conf/certs`).
- Required files: `server.crt` (certificate), `server.key` (private key)
- Alternatively, use an external reverse proxy (nginx, Traefik, etc.)

---

## Data Persistence & Backup

- **Znuny data:** `znuny-var`, `znuny-config`, `znuny-custom` volumes
- **MariaDB data:** `db-data` volume
- **Apache logs/certs:** `apache-logs`, `apache-certs` volumes

Back up these volumes regularly for disaster recovery.

---

## Troubleshooting

- **App unreachable?**  
  Check `docker compose logs`. Ensure both containers are running and ports are open.
- **DB errors?**  
  Ensure DB container is healthy and credentials match.
- **Permissions?**  
  Ensure volumes are not owned by root on the host.
- **Healthchecks in Compose:**  
  Containers auto-restart if unhealthy.

---

## Security Recommendations

- Change all default passwords!
- Enable SSL for Apache.
- Limit container network exposure.
- Regularly back up volumes.
- Keep images up-to-date.

---

## Contributing

Contributions welcome! Open an issue or submit a PR.

---

## License

MIT License (see [LICENSE](LICENSE))

---

**Questions or improvements?**  
Open an [issue](https://github.com/Erik-Donath/znuny-docker/issues) or a pull request!
