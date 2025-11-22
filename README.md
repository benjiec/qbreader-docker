# qbreader/docker

Creates a Docker setup to run qbreader locally, for development purposes.

## Getting Started

### Setup - You only need to do this once

1. Clone the repository and go to working directory
   e.g. `git clone https://github.com/benjiec/qbreader-docker && cd qbreader-docker`

2. Clone `qbreader/website`. You will need a version that has support for
   specifying MongoDB URI.

   For now use `https://github.com/benjiec/qbreader-website`, then switch to
   `add-mongodb-uri-env` branch. A PR for the support is being sent to
   `https://github.com/qbreader/website` the official repository.

   Also, if you are doing your own development, you will want to clone from the
   appropriate forked repo.

3. Clone `qbreader/database`. You will need a version that has support for
   specifying MongoDB URI.

   For now use
   `https://github.com/benjiec/qbreader-database`, then switch to
   `add-mongodb-uri-env` branch. A PR for the support is being sent to
   `https://github.com/qbreader/database` the official repository.

   Also, if you are doing your own development, you will want to clone from the
   appropriate forked repo.

4. Download a backup copy of the database and put that in `dump/qbreader`. This
   directory should contain the various `.bson` files. E.g. visit
   `https://www.qbreader.org/db/backups`, visit the backup Google Drive,
   download one of the timestamped directories as a zip file, and unzip and
   copy the `.bson` files to `dump/qbreader`.

5. Build docker images and start docker instances using
   `docker compose up -d --build`

6. Populate local MongoDB server with backup
   `BACKUP_DIR=/<full-path-to-parent-dir>/qbreader-docker/dump ./scripts/setup-db.sh`

### Running

1. `docker-compose up -d`

2. Visit `localhost:3000` from a browser
