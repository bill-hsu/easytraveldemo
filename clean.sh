#!/bin/bash
set -e

. ./config/os-settings.sh

oc login https://${OS_MASTER_IP}:8443 -u admin -p admin
oc delete project easytravel