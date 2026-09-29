#!/bin/bash

set -euo pipefail # Exit on error, unset variable, or pipe failure

usage() {
    echo "Usage: setup-download.sh <sofa-target> <plugins> <python-version> <requirements-file>"
}

if [[ "$#" -ge 4 ]]; then
    sofa_target="$1"
    plugins_repos="$2"
    python_version="$3"
    requirements_file_url="$4"
else
    usage; exit 1
fi

echo "--------------- setup-download.sh args ---------------"
echo "Running setup-download.sh with the following parameters:"
echo "SOFA target: $sofa_target"
echo "Plugins repos: $plugins_repos"
echo "Python version: $python_version"
echo "Requirements file: $requirements_file_url"
echo "------------------------------------------------------"

validate_plugins_repos() {
    # json looks like {"https://url.to/plugin/repo.git": "branch_or_commit", "https://url.to/another/plugin.git": "branch_or_commit"}
    local repos_json="$1"
    jq -e . >/dev/null 2>&1 <<<"$repos_json" || { echo "Invalid JSON for plugins repos: $repos_json" >&2; exit 1; }
    for repo in $(jq -r 'keys[]' <<<"$repos_json"); do
        if [[ ! "$repo" =~ ^https?:// ]]; then
            echo "Invalid plugin repo URL: $repo" >&2
            exit 1
        fi
    done
}

validate_python_version() {
    local version="$1"
    if [[ ! "$version" =~ ^3\.[0-9]{1,2}\.[0-9]{1,2}$ ]]; then
        echo "Invalid Python version: $version" >&2
        exit 1
    fi
}

validate_plugins_repos "$plugins_repos"
validate_python_version "$python_version"

# Directory structure:
# - src : SOFA source
# - plugins : plugins source with a CMakeLists file 
# - build/bin/python : Python build standalone from Astral (https://github.com/astral-sh/python-build-standalone/)

os="$(uname -s)"

# Clone sofa repository into src and use Compliance Robotics postinstall-fixup
git clone https://github.com/sofa-framework/sofa.git src
git -C src checkout "$sofa_target"
git clone https://github.com/SofaComplianceRobotics/SofaRobotics.CI.Tools.git tools
rm -r src/tools/postinstall-fixup
mv tools/postinstall-fixup src/tools/postinstall-fixup

# Rename project to SOFA-Robotics
perl -pi -e 's/CPACK_PACKAGE_NAME "SOFA/CPACK_PACKAGE_NAME "SOFA-Robotics/g' src/CMakeLists.txt
perl -pi -e 's/CPACK_PACKAGE_FILE_NAME "SOFA/CPACK_PACKAGE_FILE_NAME "SOFA-Robotics/g' src/CMakeLists.txt

# Plugins
mkdir -p plugins
# If plugins/CMakeLists.txt exists, remove it
if [ -f plugins/CMakeLists.txt ]; then
    rm plugins/CMakeLists.txt
fi
touch plugins/CMakeLists.txt
echo "cmake_minimum_required(VERSION 3.12)" >> plugins/CMakeLists.txt

# Clone plugins into the plugins directory
echo "$plugins_repos" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r repo head; do
    plugin_name=$(basename "$repo" .git)
    head="${head%$'\r'}"
    echo "Cloning plugin $plugin_name from $repo at $head into plugins/$plugin_name"
    git clone "$repo" "plugins/$plugin_name"
    if [ -n "$head" ]; then
        git -C "plugins/$plugin_name" checkout "$head"
    fi
    echo "sofa_add_subdirectory(plugin $plugin_name $plugin_name ON)" >> plugins/CMakeLists.txt
done

# Download Python
download_url=""

os="$(uname -s)"
case "$os" in
    Linux)
        download_url="https://github.com/astral-sh/python-build-standalone/releases/download/20260901/cpython-${python_version}+20260901-x86_64-unknown-linux-gnu-install_only.tar.gz"
        ;;

    MINGW*|MSYS*|CYGWIN*|Windows_NT)
        download_url="https://github.com/astral-sh/python-build-standalone/releases/download/20260901/cpython-${python_version}+20260901-x86_64-pc-windows-msvc-install_only.tar.gz"
        ;;
    Darwin)
        download_url="https://github.com/astral-sh/python-build-standalone/releases/download/20260901/cpython-${python_version}+20260901-aarch64-apple-darwin-install_only.tar.gz"
        ;;
    *)
        echo "Unsupported OS: $os" >&2
        exit 1
        ;;
esac

echo "Downloading Python from $download_url"
curl -L --fail --show-error -o cpython.tar.gz  "$download_url"
tar -xf cpython.tar.gz
mkdir build
mkdir build/bin
mv python build/bin/python

# Download requirements if URL or copy to current folder is not empty
if [[ -n "$requirements_file_url" ]]; then
    if [[ "$requirements_file_url" =~ ^https?:// ]]; then
        echo "Downloading requirements file from $requirements_file_url"
        curl -L --fail --show-error -o requirements.txt "$requirements_file_url"
    else
        if [[ ! -f "$requirements_file_url" ]]; then
            echo "Requirements file not found: $requirements_file_url" >&2
            exit 1
        fi
        cp "$requirements_file_url" requirements.txt
    fi
fi

echo "################################################"
echo "### Working Directory:"
ls 
echo "### plugins Directory:"
ls plugins
echo "---plugins/CMakeLists.txt---"
cat plugins/CMakeLists.txt
echo "### build/bin Directory:"
ls build/bin
echo "################################################"
