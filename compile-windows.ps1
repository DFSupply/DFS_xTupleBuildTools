# xTuple Build Tools
#
# DF Supply, Inc.
# 02/28/2022
#
# DO NOT USE IN PRODUCTION WITHOUT PRIOR TESTING
#
# Requires:
# Windows Server 2022
#
# Built for Windows by Scott D Moore @ DF Supply - scott.moore@dfsupplyinc.com

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
	Write-Warning "Please run this as an administrator."
	Break
}

echo "xTuple Compile Utility (Windows x64)"
echo "DF Supply, Inc."
echo ""
echo ""
echo "Please confirm you wish to proceed with the build?"
Read-Host -Prompt "Press any key to confirm or CTRL+C to quit" 

echo ""
echo "Building Qt Environment..."
echo ""
cd ..
git clone https://github.com/DFSupply/DFS_QtApplicationCompileEnvironment.git
docker build -f "./DFS_QtApplicationCompileEnvironment/DockerFile-windows" -t qt-build-env:latest .
docker run --name qt-build-xtuple -it -d qt-build-env:latest
	
echo "Qt Environment Running..."
echo "Building xTuple Client Now..."
git clone https://github.com/DFSupply/qt-client
cd qt-client
(Get-Content "$PWD/.gitmodules").replace('xtuple','DFSupply') | Set-Content "$PWD/.gitmodules"
git submodule update --init --recursive
cd ..

docker cp qt-client qt-build-xtuple:c:/build-env/
docker exec qt-build-xtuple powershell "cd c:/build-env/qt-client/openrpt/ ; c:\vcpkg\installed\x64-windows\tools\qt5\bin\qmake.exe ;"
docker exec qt-build-xtuple powershell "cd c:/build-env/qt-client/openrpt/ ; jom ;"
docker exec qt-build-xtuple powershell "cd c:/build-env/qt-client/csvimp/ ; c:\vcpkg\installed\x64-windows\tools\qt5\bin\qmake.exe ;"
docker exec qt-build-xtuple powershell "cd c:/build-env/qt-client/csvimp/ ; jom ;"
docker exec qt-build-xtuple powershell "cd c:/build-env/qt-client/ ; c:\vcpkg\installed\x64-windows\tools\qt5\bin\qmake.exe ;"
docker exec qt-build-xtuple powershell "Add-Content C:\build-env\qt-client\global.pri 'LIBS += c:/vcpkg/installed/x64-windows/lib/zlib.lib' ;" #hacky workaround for lib building issues (issues with vcpkg in qmake)
docker exec qt-build-xtuple powershell "Add-Content C:\build-env\qt-client\global.pri 'INCLUDEPATH += -Lc:/vcpkg/installed/x64-windows/include' ;" #hacky workaround for lib building issues (issues with vcpkg in qmake)
docker exec qt-build-xtuple powershell "$env:LIBRARYPATH='c:\vcpkg\installed\x64-windows\lib' ;" #set library path in ENV
docker exec qt-build-xtuple powershell "cd c:/build-env/qt-client/ ; jom ;"

# collect the libraries for distribution
docker exec qt-build-xtuple powershell "c:\vcpkg\installed\x64-windows\tools\qt5\bin\windeployqt.exe c:\build-env\qt-client\bin\"
docker exec qt-build-xtuple powershell "xcopy c:\vcpkg\intalled\x64-windows\bin\*.dll c:\build-env\qt-client\bin\ /E/H"
docker exec qt-build-xtuple powershell "xcopy c:\vcpkg\intalled\x64-windows\plugins\*.dll c:\build-env\qt-client\bin\ /E/H"

echo ""
echo "Copying binary back from container..."
mkdir xTupleBuild
docker cp qt-build-xtuple:c:\build-env\qt-client\bin .\xTupleBuild\
remove-item -path .\qt-client\ -recurse -force

echo ""
echo "Stopping Qt Environment"
docker stop qt-build-xtuple
	
echo ""
echo "Finished!"
echo ""