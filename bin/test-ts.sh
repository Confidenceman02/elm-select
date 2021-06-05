#!/usr/bin/env bash
set -eo pipefail

echo "Testing ts"
yarn mocha --exit -r ts-node/register 'tests/**/*.spec.ts'
