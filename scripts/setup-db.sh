#!/bin/bash
set -euo pipefail

# Creates the application user in the running Mongo container and restores backups
# using database/backups/restore-backup.sh inside a mongo:6 helper container.
#
# Requirements:
# - docker compose up -d (mongo must be running)
# - Backups present locally (default: ./download/2025-07-07_21_58_52)
#
# Configurable via env:
#   MONGO_CONTAINER (default: qbreader-mongo)
#   MONGO_ROOT_USER (default: root)
#   MONGO_ROOT_PASSWORD (default: example)
#   BACKUP_DIR (default: ./download/2025-07-07_21_58_52)

MONGO_CONTAINER="${MONGO_CONTAINER:-qbreader-mongo}"
MONGO_ROOT_USER="${MONGO_ROOT_USER:-root}"
MONGO_ROOT_PASSWORD="${MONGO_ROOT_PASSWORD:-example}"
BACKUP_DIR="${BACKUP_DIR:-$(pwd)/download/2025-07-07_21_58_52}"

if ! docker ps --format '{{.Names}}' | grep -q "^${MONGO_CONTAINER}\$"; then
  echo "Mongo container '${MONGO_CONTAINER}' not running. Start it with: docker compose up -d"
  exit 1
fi

echo "Creating application user 'qbreader' (idempotent)..."
docker exec -i "${MONGO_CONTAINER}" mongosh -u "${MONGO_ROOT_USER}" -p "${MONGO_ROOT_PASSWORD}" --authenticationDatabase admin --eval '
  db = db.getSiblingDB("admin");
  if (!db.getUser("qbreader")) {
    db.createUser({
      user: "qbreader",
      pwd: "qbreader",
      roles: [
        { role: "readWrite", db: "qbreader" },
        { role: "readWrite", db: "account-info" },
        { role: "readWrite", db: "geoword" }
      ]
    });
    print("Created user qbreader.");
  } else {
    print("User qbreader already exists.");
  }
'

if [ ! -d "$BACKUP_DIR" ]; then
  echo "Backup dir '$BACKUP_DIR' not found. Set BACKUP_DIR or place dumps under that path."
  exit 1
fi

echo "Restoring backups from '$BACKUP_DIR' using restore-backup.sh..."
docker run --rm \
  --network "container:${MONGO_CONTAINER}" \
  -v "$(pwd)/database/backups":/backups:ro \
  -v "$BACKUP_DIR":/dump:ro \
  mongo:6 bash -lc '
    cd /;
    export MONGODB_URI="mongodb://'"${MONGO_ROOT_USER}"':'"${MONGO_ROOT_PASSWORD}"'@localhost:27017/?authSource=admin";
    bash /backups/restore-backup.sh
  '

echo "Database setup complete."


