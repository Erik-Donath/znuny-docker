# Znuny Docker Setup

This repository provides a ready-to-use Docker setup for [Znuny](https://www.znuny.org/) including Apache2, Cron, and the Znuny Daemon. MariaDB is used as a separate service.  
**Suitable for testing and production environments.**

---

## Features

- Automated download and installation of Znuny
- Starts Apache, Cron, and Znuny Daemon inside the container
- Persistent storage for Znuny data and MariaDB database
- Flexible database configuration via Docker Compose
- Recommended MariaDB settings for large attachments

---

## Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

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

   The images will be built and the containers started.  
   Znuny will be available at: [http://localhost:8080/znuny/installer.pl](http://localhost:8080/znuny/installer.pl)

---

## Complete the Installation

1. **Open the Znuny web installer**

   Go to: [http://localhost:8080/znuny/installer.pl](http://localhost:8080/znuny/installer.pl)

2. **Enter the following database connection details in the installer:**

   | Field     | Value           |
   |-----------|-----------------|
   | Host      | db              |
   | User      | root            |
   | Password  | root_password   |
   | Database  | znuny           |

   > **Note:** The database `znuny` and the Znuny database user will be created automatically by the installer.  
   > You only need to provide the MariaDB root user and password.

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

---

## Notes & Tips

- MariaDB is started with settings for large attachments and packets.
- The Znuny Daemon runs automatically in the container.
- For production, set secure passwords and consider enabling SSL for Apache.
- You can back up your data by backing up the Docker volumes.

---

## License

MIT License

---

**Questions or improvements?**  
Open an [issue](https://github.com/Erik-Donath/znuny-docker/issues) or a pull request!
