# DFS_xTupleBuildTools
Compiles xTuple 6.x in a docker container for multiple platforms

Tested and built for RHEL 8.x

## You must have git setup already with SSH key (as this uses private REPOs)

Currently setup to clone from private DFS repositories. To use your own REPO, change the shell script(s) as required.

Compile for native (x64_linux):
```
cd /root/
git clone https://github.com/DFSupply/DFS_xTupleBuildTools.git
cd DFS_xTupleBuildTools
chmod +x compile-linux.sh
./compile-linux.sh
```