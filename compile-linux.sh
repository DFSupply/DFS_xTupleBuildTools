#!/bin/bash
#
# xTuple Build Tools
#
# DF Supply, Inc.
# 02/24/2022

# DO NOT USE IN PRODUCTION WITHOUT PRIOR TESTING
#
# Requires:
# RHEL 8.x
#
# Built for RHEL 8 by Scott D Moore @ DF Supply - scott.moore@dfsupplyinc.com

if [[ $(id -u) -ne 0 ]]
	then
		echo "Please run this script as root or sudo... Exit."
		exit 1
fi

if grep -q -i "Red Hat Enterprise Linux release 8" /etc/redhat-release; then
	echo "running RHEL 8.x"
else
	echo "Unsupported OS. See README for tested distributions."
	exit 1
fi

echo "xTuple Compile Utility (linux x64)"
echo "DF Supply, Inc."
echo ""

echo ""
echo "Please confirm you wish to proceed with the build? (y/n)"
read -r
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
	echo "Cancelling..."
	exit 1
fi

echo ""
echo "Building Qt Environment..."

subscription-manager repos --enable=codeready-builder-for-rhel-8-x86_64-rpms || exit
yum install podman -y || exit
git clone https://github.com/DFSupply/DFS_QtApplicationCompileEnvironment
cd DFS_QtApplicationCompileEnvironment || exit
podman build -f DockerFile -t qt-build-env:latest
podman run --name qt-build-xtuple -it qt-build-env:latest

echo ""
echo "Qt Environment Running..."
echo "Building xTuple Client Now..."
cd .. || exit
git clone https://github.com/DFSupply/qt-client
cd qt-client || exit
git submodule update --init --recursive
cd .. || exit


echo ""
echo "Finished!"
echo ""