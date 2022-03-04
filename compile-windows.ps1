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

echo "Building xTuple Client Now..."
cd c:\build-env\
git clone https://$env:GHUSER:$env:GHPASS@github.com/DFSupply/qt-client
cd qt-client
git clone https://$env:GHUSER:$env:GHPASS@github.com/DFSupply/csvimp
git clone https://$env:GHUSER:$env:GHPASS@github.com/DFSupply/openrpt

Add-Content C:\build-env\qt-client\global.pri 'INCLUDEPATH += "c:\\vcpkg\\installed\\x64-windows\\include"' #workaround for zlib building issues (issues with vcpkg in qmake)
Add-Content C:\build-env\qt-client\global.pri 'INCLUDEPATH += "c:\\vcpkg\\installed\\x64-windows\\include\\zlib.h"' #workaround for zlib building issues (issues with vcpkg in qmake)
Add-Content C:\build-env\qt-client\global.pri 'LIBS += "c:\\vcpkg\\installed\\x64-windows\\lib\\zlib.lib"' #workaround for zlib building issues (issues with vcpkg in qmake)
$env:LIBRARYPATH='c:\vcpkg\installed\x64-windows\lib' #set library path in ENV

cd c:/build-env/qt-client/openrpt/
c:\vcpkg\installed\x64-windows\tools\qt5\bin\qmake.exe
nmake #don't use jom here. It doesn't link openrpt well to qt-client for some reason

cd c:/build-env/qt-client/csvimp/
c:\vcpkg\installed\x64-windows\tools\qt5\bin\qmake.exe
nmake

cd c:/build-env/qt-client/
c:\vcpkg\installed\x64-windows\tools\qt5\bin\qmake.exe
jom

# collect the libraries for distribution
c:\vcpkg\installed\x64-windows\tools\qt5\bin\windeployqt.exe c:\build-env\qt-client\bin\
xcopy c:\vcpkg\intalled\x64-windows\bin\*.dll c:\build-env\qt-client\bin\ /E/H/Y
xcopy c:\vcpkg\intalled\x64-windows\plugins\*.dll c:\build-env\qt-client\bin\ /E/H/Y
	
Compress-Archive -Path c:\build-env\qt-client\bin\* -DestinationPath c:\build-env\qt-client.zip
cp c:\build-env\qt-client.zip c:\build-archives\qt-client.zip

echo ""
echo "Finished!"
echo "Binaries are available at: c:\build-env\qt-client.zip"
echo "And have been copied back to host directory (if they were mounted in c:\build-archives\ during run)"
echo ""