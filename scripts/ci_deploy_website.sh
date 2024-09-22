#!/bin/bash

builddir=$1
destdir=$2
sha=$3

# check the PDF was created and upload to https://mapserver.org/pdf/MapServer.pdf
if [ -f $builddir/latex/en/MapServer.pdf ]; then
  set -x
  scp $builddir/latex/en/MapServer.pdf mapserver@mapserver.org:/var/www/mapserver.org/pdf/
  set +x
fi


if [ ! -d $destdir/mapserver.github.io ]; then
  git clone git@github.com:geographika/mapserver.github.io.git $destdir/mapserver.github.io
fi

# specify the files and directories to keep
keep_files=(.git README.md .nojekyll)

# delete all items in the repository
for item in * .[^.]*; do
    # Check if the item is not in the keep_files array
    if [[ ! " ${keep_files[@]} " =~ " ${item} " ]]; then
        # Remove the item (directory or file)
        rm -rf "$item"
    fi
done

# copy in the newly created files
cd $builddir/html
cp -rf * $destdir/mapserver.github.io

cd $destdir/mapserver.github.io
git config user.email "mapserverbot@mapserver.bot"
git config user.name "MapServer deploybot"

#rm -rf _sources */_sources
#rm -rf .doctrees */.doctrees */.buildinfo

git add -A
git commit -m "update with results of commit https://github.com/mapserver/MapServer-documentation/commit/$sha"
git push origin master
