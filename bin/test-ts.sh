#!/usr/bin/env bash
set -eo pipefail

echo "Testing ts"
yarn mocha --timeout 10000 --exit -r ts-node/register 'tests/**/*.spec.ts'
