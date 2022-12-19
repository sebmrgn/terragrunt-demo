#!/bin/bash
find . -type d -name '.terragrunt-cache' -exec rm -rf {} \;
find . -type f -name '.terraform.lock.hcl' -exec rm -rf {} \;
