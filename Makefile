# Makefile

EXTENSION = pg_restore_points
DATA = pg_restore_points--1.5.sql
DOCS = README.md

# List of SQL test files to run
REGRESS = pg_restore_points_test

# Configuration for PostgreSQL
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
