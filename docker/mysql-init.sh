#!/bin/bash
set -eu

# Имя должно совпадать с DB_DATABASE в phpunit.xml.
TEST_DB=app_test

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<EOSQL
CREATE DATABASE IF NOT EXISTS ${TEST_DB};
GRANT ALL PRIVILEGES ON ${TEST_DB}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL
