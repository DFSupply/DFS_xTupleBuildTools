# DFS_xTupleBuildTools
Compiles xTuple 6.x for multiple platforms

Tested and built for RHEL 8.x

## You must have git setup already with SSH key (as this uses private REPOs)

Currently setup to clone from private DFS repositories. To use your own REPO, change the shell script(s) as required.

Process:
 - Builds a pod (docker container) based on RHEL 8.x that is setup to compile Qt applications
 - Compiles openrpt (in the pod)
 - Compiles csvimp (in the pod)
 - Compiles qt-client (in the pod)
 - Copies the binaries (out of the pod)
 - Tears down the running container

Compile for native (x64_linux):
```
git clone https://github.com/DFSupply/DFS_xTupleBuildTools.git
cd DFS_xTupleBuildTools
chmod +x compile-linux.sh
./compile-linux.sh
```