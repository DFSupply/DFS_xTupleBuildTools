#!/bin/bash
#
# xTuple Build Tools
#
# DF Supply, Inc.
# 02/24/2022
#
# DO NOT USE IN PRODUCTION WITHOUT PRIOR TESTING
#
# Requires:
# RHEL 8.x or RHEL 9.x
#
# Built for RHEL 8/9 by Scott D Moore @ DF Supply - scott.moore@dfsupplyinc.com

if [[ $(id -u) -ne 0 ]]
	then
		echo "Please run this script as root or sudo... Exit."
		exit 1
fi

if grep -q -i "Red Hat Enterprise Linux release 8" /etc/redhat-release; then
	echo "running RHEL 8.x"
	OS_VER="RHEL8"
elif grep -q -i "Red Hat Enterprise Linux release 9" /etc/redhat-release; then
	echo "running RHEL 9.x"
	OS_VER="RHEL9"
else
	echo "Unsupported OS. See README for tested distributions."
	OS_VER="UNSUP"
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
if [ "$OS_VER" == "RHEL8" ]; then
	subscription-manager repos --enable=codeready-builder-for-rhel-8-x86_64-rpms || exit
elif [ "$OS_VER" == "RHEL9" ]; then
	subscription-manager repos --enable=codeready-builder-for-rhel-9-x86_64-rpms || exit
fi
yum install podman -y || exit
podman build -f DockerFile-linux https://github.com/DFSupply/DFS_QtApplicationCompileEnvironment.git -t qt-build-env:latest
podman run --name qt-build-xtuple -it -d -rm qt-build-env:latest

# start build inside container
echo ""
echo "Qt Environment Running..."
echo "Building xTuple Client Now..."
git clone https://github.com/DFSupply/qt-client
cd qt-client || exit
sed -i -e 's|xtuple|DFSupply|' .gitmodules
git submodule update --init --recursive
cd .. || exit
podman cp qt-client qt-build-xtuple:/opt/
podman exec qt-build-xtuple bash -c "cd /opt/qt-client/openrpt/ ; qmake;"
podman exec qt-build-xtuple bash -c "cd /opt/qt-client/openrpt/ ; make -j$(nproc);"
podman exec qt-build-xtuple bash -c "cd /opt/qt-client/csvimp/ ; qmake;"
podman exec qt-build-xtuple bash -c "cd /opt/qt-client/csvimp/ ; make -j$(nproc);"
podman exec qt-build-xtuple bash -c "cd /opt/qt-client/ ; qmake;"
podman exec qt-build-xtuple bash -c "echo 'LIBS += -L/usr/local/Qt-5.15.2/lib' >> global.pri;" #hacky workaround for lib building issues
podman exec qt-build-xtuple bash -c "cd /opt/qt-client/ ; make -j$(nproc);"

echo ""
echo "Copying binary back from container..."
mkdir xTupleBuild
podman cp qt-build-xtuple:/opt/qt-client/bin/xtuple  ./xTupleBuild
rm -Rf qt-client

echo ""
echo "Stopping Qt Environment"
podman stop qt-build-xtuple

echo ""
echo "Finished!"
echo ""