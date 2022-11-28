# DFS_xTupleBuildTools
Compiles xTuple 6.x for multiple platforms

Tested and built for RHEL 8.x, RHEL 9.x, and Windows Server 2022

## You must have git setup already with SSH key (as this uses private REPOs)

Currently setup to clone from private DFS repositories. To use your own REPO, change the shell script(s) as required.

Process:
 - Builds a pod (docker container) based on RHEL 8.x that is setup to compile Qt applications
 - Compiles openrpt (in the pod)
 - Compiles csvimp (in the pod)
 - Compiles qt-client (in the pod)
 - Copies the binaries (out of the pod)
 - Tears down the running container

Compile for native (x64_linux) *tested in RHEl 8/9*:
```
git clone https://github.com/DFSupply/DFS_xTupleBuildTools.git
cd DFS_xTupleBuildTools
chmod +x compile-linux.sh
./compile-linux.sh
```

Compile for native (x64_windows) *tested in Windows Server 2022*:   
*note: cannot be run in detached mode like the linux build due to a limitaion of MSVC needing batch file bootstrapped*   
```
mkdir build-archives
git clone https://github.com/DFSupply/DFS_QtApplicationCompileEnvironment.git
docker build -f "./DFS_QtApplicationCompileEnvironment/DockerFile-windows" -t qt-build-env:latest .
docker run --name qt-build-xtuple -it --rm --env GHUSER=%your_github_username% --env GHPASS=%your_github_token_pass% -v $PWD\build-archives\:c:\build-archives\ qt-build-env:latest

----inside of container----
----PowerShell----
cd c:\build-env\
git clone https://github.com/DFSupply/DFS_xTupleBuildTools.git
cd DFS_xTupleBuildTools
.\compile-windows.ps1
```