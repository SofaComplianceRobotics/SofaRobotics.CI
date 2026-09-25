#!/bin/bash

set -euo pipefail # Exit on error, unset variable, or pipe failure

# Directory structure:
# - src : SOFA source
# - plugins : plugins source with a CMakeLists file 
# - build/bin/python : Python build standalone from Astral (https://github.com/astral-sh/python-build-standalone/)

os="$(uname -s)"

# Clone sofa repository into src and use Compliance Robotics postinstall-fixup
git clone https://github.com/sofa-framework/sofa.git src
git clone https://github.com/SofaComplianceRobotics/SofaRobotics.CI.Tools.git tools
rm -r src/tools/postinstall-fixup
mv tools/postinstall-fixup src/tools/postinstall-fixup

# Rename project to SOFA-Robotics
perl -pi -e 's/CPACK_PACKAGE_NAME "SOFA/CPACK_PACKAGE_NAME "SOFA-Robotics/g' src/CMakeLists.txt
perl -pi -e 's/CPACK_PACKAGE_FILE_NAME "SOFA/CPACK_PACKAGE_FILE_NAME "SOFA-Robotics/g' src/CMakeLists.txt

# Clone plugins into the plugins directory
git clone --single-branch --branch pr_bundlepython https://github.com/SofaComplianceRobotics/SofaPython3.git plugins/SofaPython3
git clone https://github.com/sofa-framework/BeamAdapter.git plugins/BeamAdapter
git clone --single-branch --branch robotics https://github.com/SofaComplianceRobotics/SofaGLFW.git plugins/SofaGLFW
git clone https://github.com/SofaDefrost/SoftRobots.git plugins/SoftRobots
git clone https://github.com/SofaDefrost/SoftRobots.Inverse.git plugins/SoftRobots.Inverse
git clone https://github.com/SofaDefrost/Cosserat.git plugins/Cosserat
git clone https://github.com/SofaDefrost/STLIB.git plugins/STLIB

# Create CMakelists for the plugins
# If plugins/CMakeLists.txt exists, remove it
if [ -f plugins/CMakeLists.txt ]; then
    rm plugins/CMakeLists.txt
fi
touch plugins/CMakeLists.txt
echo "cmake_minimum_required(VERSION 3.12)
sofa_add_subdirectory(plugin SofaPython3 SofaPython3 ON)
sofa_add_subdirectory(plugin STLIB STLIB ON)
sofa_add_subdirectory(plugin BeamAdapter BeamAdapter ON)
sofa_add_subdirectory(plugin Cosserat Cosserat ON)
sofa_add_subdirectory(plugin SoftRobots SoftRobots ON)
sofa_add_subdirectory(plugin SoftRobots.Inverse SoftRobots.Inverse ON)
sofa_add_subdirectory(plugin SofaGLFW SofaGLFW ON)" >> plugins/CMakeLists.txt

# Download Python
download_url=""

os="$(uname -s)"
case "$os" in
    Linux)
        download_url="https://github.com/astral-sh/python-build-standalone/releases/download/20260901/cpython-3.14.7+20260901-x86_64-unknown-linux-gnu-install_only.tar.gz"
        ;;

    MINGW*|MSYS*|CYGWIN*|Windows_NT)
        download_url="https://github.com/astral-sh/python-build-standalone/releases/download/20260901/cpython-3.14.7+20260901-x86_64-pc-windows-msvc-install_only.tar.gz"
        ;;
    Darwin)
        download_url="https://github.com/astral-sh/python-build-standalone/releases/download/20260901/cpython-3.14.7+20260901-aarch64-apple-darwin-install_only.tar.gz"
        ;;
    *)
        echo "Unsupported OS: $os" >&2
        exit 1
        ;;
esac

curl -L -o cpython.tar.gz  "$download_url"
tar -xf cpython.tar.gz
mkdir build
mkdir build/bin
mv python build/bin/python

echo "################################################"
echo "### Working Directory:"
ls 
echo "### plugins Directory:"
ls plugins
echo "### build/bin Directory:"
ls build/bin
echo "################################################"
