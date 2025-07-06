#!/bin/bash
# coverage.sh

crystal spec
crystal tool unreachable -f json spec/** > coverage.json
# jq 'map(select(.file | contains("src/"))' coverage.json
