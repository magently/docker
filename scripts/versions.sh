#!/bin/bash
set -e

##
# List versions
##
list_versions() {
    echo "$VERSIONS"
}

##
# List components
##
list_components() {
    if [ -n "$2" ]; then
        PREFIX="$(echo $2 | sed 's/\./\\./g')\."
    else
        PREFIX=""
    fi

    list_versions | grep -xP "$PREFIX.+" | cut -sd. -f$1 | sort -n | uniq
}

##
# List major version components
##
list_major() {
    list_components 1
}

##
# List minor version components
##
list_minor() {
    list_components 2 "$1"
}

##
# List patch version components
##
list_patch() {
    list_components 3 "$1"
}

##
# Process range of number
#
# [N]   - return n-th latest version
# [N-M] - return from n-th to m-th latest versions
#
# Examples:
# [1]   - return latest version
# [5]   - return fifth version after latest
# [1-5] - return five latest versions
# [2-3] - return two latest versions skipping the latest one
##
range() {
    range=$(echo $1 | sed 's/\(\[\|\]\)//g')
    left=$(echo $range | cut -d- -f1)
    right=$(echo $range | cut -d- -f2)

    cat | tail -n -$right | head -n $(( $right - $left + 1 ))
}

##
# Recursive process_components function
#
# Parses the given components,
# where each (MAJOR, MINOR, PATCH, ...) component
# may be either:
#
# - a number
# - a range ([N] | [N-M])
##
process_components() {
    local n=1
    local components=$@

    for component in $components; do
        if [[ "$component" =~ ^\[[0-9-]+\]$ ]]; then
            local prefix="$(echo "$components" | cut -d' ' -f-$(($n - 1)))"
            local suffix="$(echo "$components" | cut -d' ' -f$(($n + 1))-)"

            list_components $n $(echo "$prefix" | tr ' ' '.') | range "$component" | while read value; do
                process_components $prefix $value $suffix
            done

            # Stop processing current components
            return
        fi

        n=$(($n + 1))
    done

    # Print result
    echo "$(echo "${@:1:$(($n - 1))}" | tr ' ' '.')"
}

usage() {
    echo 'versions.sh [--help] <git-url> <constraint...>[:tag]'
}

info() {
    usage
    echo '  git-url: path to GIT url, e.g. Github'
    echo '  constraint: version constraint, see CONSTRAINT FORMAT'
    echo '  tag: version tag for single components constraint'
    echo ''
    echo 'CONSTRAINT FORMAT:'
    echo '  Format consits of multiple COMPONENTS: <major>.<minor>.<patch>...'
    echo '  Each COMPONENT is either a:'
    echo '      - number'
    echo '      - range: [N] or [N-M]'
    echo ''
    echo 'EXAMPLE #1 '
    echo ''
    echo '  Fetch latest Magento2 version'
    echo ''
    echo '  $ versions.sh https://github.com/magento/magento2 2.[1].[1]'
    echo '  2.2.0:2.20'
    echo ''
    echo 'EXAMPLE #2'
    echo ''
    echo '  Fetch two latest patch versions for two latest minor versions of Magento 2'
    echo ''
    echo '  $ versions.sh https://github.com/magento/magento2 2.[1-2][1-2]'
    echo '  2.2.0:2.2.0'
    echo '  2.1.9:2.2.0'
    echo '  2.1.8:2.1.8'
    echo ''
    echo 'EXAMPLE #3'
    echo ''
    echo '  Fetch latest version of Magento 2 tagged as latest'
    echo ''
    echo '  $ versions.sh https://github.com/magento/magento2 2.[1].[1]:latest'
    echo '  2.2.0:latest'
}

##
# Script starts here
##

if [ "$1" == '--help' ]; then
    info
    exit
fi

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

GIT_URL="$1"
shift 1

# Prefetch versions
VERSIONS=$(
    git ls-remote --tags "$GIT_URL" | \
    cut -sd/ -f3 | \
    grep -xP "\d+\.[0-9.]+\.\d+"
)

# Process all given formats
for arg in $@; do
    constraint="$(echo $arg | cut -d: -f1)"
    tag="$(echo $arg | cut -sd: -f2)"
    tag="${tag:-$constraint}"

    versions=$(process_components $(echo $constraint | tr '.' ' '))
    tags=$(process_components $(echo $tag | tr '.' ' '))

    if [[ $(echo $versions | wc -w) -ne $(echo $tags | wc -w) ]]; then
        echo "Returned tags count differs from versions count"
        exit 1
    fi

    count=$(echo $versions | wc -w)
    for i in $(seq 1 $count); do
        echo "$(echo $versions | cut -d' ' -f$i):$(echo $tags | cut -d' ' -f$i)"
    done
done
