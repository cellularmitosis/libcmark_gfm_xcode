#!/bin/bash

# pull in the cmark-gfm source code.

# when bumping to a more recent version of cmark-gfm, update this env var:
version=0.29.0.gfm.13
# then run 'make ultra-clean && make'

set -e -o pipefail

if test -e src/main.c ; then
    exit 0
fi

rm -rf src extensions

# fetch the cmark-gfm source.
curl -fL https://github.com/github/cmark-gfm/archive/refs/tags/$version.tar.gz | gunzip | tar x
# we just want the 'src' and 'extensions' dirs.
mv cmark-gfm-$version/src .
mv cmark-gfm-$version/extensions .
# parse out the version numbers.
PROJECT_VERSION_MAJOR=$(cat cmark-gfm-$version/CMakeLists.txt | grep 'set(PROJECT_VERSION_MAJOR' | awk '{print $NF}' | tr -d ')')
PROJECT_VERSION_MINOR=$(cat cmark-gfm-$version/CMakeLists.txt | grep 'set(PROJECT_VERSION_MINOR' | awk '{print $NF}' | tr -d ')')
PROJECT_VERSION_PATCH=$(cat cmark-gfm-$version/CMakeLists.txt | grep 'set(PROJECT_VERSION_PATCH' | awk '{print $NF}' | tr -d ')')
PROJECT_VERSION_GFM=$(cat cmark-gfm-$version/CMakeLists.txt | grep 'set(PROJECT_VERSION_GFM' | awk '{print $NF}' | tr -d ')')
# we're done with the upstream tarball.
rm -rf cmark-gfm-$version

# remove the cmake files.
rm src/CMakeLists.txt extensions/CMakeLists.txt

# this is normally done by cmake.
cat src/config.h.in | sed -e 's/#cmakedefine/#define/g' > src/config.h
rm src/config.h.in

# this is normally done by cmake.
cat src/cmark-gfm_version.h.in \
| sed -e "s/@PROJECT_VERSION_MAJOR@/$PROJECT_VERSION_MAJOR/g" \
| sed -e "s/@PROJECT_VERSION_MINOR@/$PROJECT_VERSION_MINOR/g" \
| sed -e "s/@PROJECT_VERSION_PATCH@/$PROJECT_VERSION_PATCH/g" \
| sed -e "s/@PROJECT_VERSION_GFM@/$PROJECT_VERSION_GFM/g" \
> src/cmark-gfm_version.h
rm src/cmark-gfm_version.h.in

# this is normally created by cmake.
cat > src/cmark-gfm_export.h << 'EOF'
#ifndef CMARK_GFM_EXPORT_H
#define CMARK_GFM_EXPORT_H

#ifdef CMARK_GFM_STATIC_DEFINE
#  define CMARK_GFM_EXPORT
#  define CMARK_GFM_NO_EXPORT
#else
#  ifndef CMARK_GFM_EXPORT
#    ifdef libcmark_gfm_EXPORTS
        /* We are building this library */
#      define CMARK_GFM_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define CMARK_GFM_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef CMARK_GFM_NO_EXPORT
#    define CMARK_GFM_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef CMARK_GFM_DEPRECATED
#  define CMARK_GFM_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef CMARK_GFM_DEPRECATED_EXPORT
#  define CMARK_GFM_DEPRECATED_EXPORT CMARK_GFM_EXPORT CMARK_GFM_DEPRECATED
#endif

#ifndef CMARK_GFM_DEPRECATED_NO_EXPORT
#  define CMARK_GFM_DEPRECATED_NO_EXPORT CMARK_GFM_NO_EXPORT CMARK_GFM_DEPRECATED
#endif

#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef CMARK_GFM_NO_DEPRECATED
#    define CMARK_GFM_NO_DEPRECATED
#  endif
#endif

#endif /* CMARK_GFM_EXPORT_H */
EOF

# xcodegen doesn't seem to generate an "umbrella header", so make one manually:
PROJNAME=libcmark_gfm
cat > src/$PROJNAME.h << EOF
#import <Foundation/Foundation.h>
FOUNDATION_EXPORT double ${PROJNAME}VersionNumber;
FOUNDATION_EXPORT const unsigned char ${PROJNAME}VersionString[];
EOF
