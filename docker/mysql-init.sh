#!/bin/bash
set -eu

# The name must match DB_DATABASE in phpunit.xml.
TEST_DB=app_test

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<EOSQL
CREATE DATABASE IF NOT EXISTS ${TEST_DB};
GRANT ALL PRIVILEGES ON ${TEST_DB}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL
