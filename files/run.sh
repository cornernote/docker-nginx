#!/bin/bash

# Fail on any error
set -o errexit

# Run nginx
nginx -g 'daemon off;'
