#!/bin/bash

set -ex

# Install pnpm
npm i --silent -g pnpm@7 --unsafe-perm
# --usafe-perm to allow install scripts

# Install packages
pnpm i

# Output versions
pnpm -v
node -v
npm -v

# See package.json setup script
pnpm run setup

if [[ $BUILDKITE_BRANCH == integration/* ]] ;
then
    echo "Testing was skipped as it's an integration branch. For tests, check GitHub Actions or the Buildkite testing pipeline https://buildkite.com/prisma/test-prisma-typescript"
else
    echo "Start testing..."
    # Run test for all packages
    pnpm run test

    # New client test suite
    pnpm run --filter "@prisma/client" test:functional

    # Client memory test suite
    pnpm run --filter "@prisma/client" test:memory
fi

# Disable printing with +x and return as before just after
set +x
# Set NPM token for publishing
echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc
set -ex

# Publish all packages
pnpm run publish-all
