#!/bin/bash
set -e

# Note: this script is based on the installer script from msysGit
# (/share/msysGit/net/release.sh)

INSTALLER_NAME="winconfig"
INSTALLER_TITLE="winconfig installation"
INSTALLER_DIRNAME="winconfig"

DESTARCHIVE="$(pwd -L)"/winsible.7z
TMPDIR=/tmp/winsible
OPTS7="-m0=lzma -mx=9 -md=64M"

# Get script dir
cd "$(dirname "${0}")"
SHARE="$(pwd -L)"
cd - > /dev/null

test ! -d "$TMPDIR" || rm -rf "$TMPDIR" || exit
mkdir "$TMPDIR"
cd "$TMPDIR"

(cd .. && test ! -f "$DESTARCHIVE" || rm "$DESTARCHIVE")

echo "Copying files"

mkdir msys64

sed 's/\r//g' "$SHARE"/fileList.txt | while read -r filepath || [ -n "$filepath" ]
do
  # do something with $filepath here
  rsync --archive --relative --include "*/python3.8/**/ansible/**/test*/" --exclude "*.pyc" --exclude "*/__pycache__" --exclude "*/python3.8/**/test*/" /./${filepath} msys64/
done

sed 's/\r//g' "$SHARE"/fileList-mingw.txt | while read -r filepath || [ -n "$filepath" ]
do
  # do something with $filepath here
  rsync --archive --relative --include "*/python3.8/**/ansible/**/test*/" --exclude "*.pyc" --exclude "*/__pycache__" --exclude "*/python3.8/**/test*/" /mingw64/./${filepath} msys64/
done

pushd msys64

strip usr/bin/*.exe usr/lib/git-core/*.exe

mkdir -p usr/share
cp -R /usr/share/terminfo ./usr/share/terminfo

mkdir -p usr/ssl
cp -R /usr/ssl/certs ./usr/ssl/certs

mkdir tmp

mkdir etc
cp /etc/fstab ./etc/fstab
cp /etc/msystem ./etc/msystem
cp /etc/profile ./etc/profile

mkdir -p dev/shm

if test -d /etc/profile.d
then
	cp -R /etc/profile.d ./etc/profile.d
fi

# Pop msys64 dir, to get back to $TMPDIR
popd

echo "Creating archive"

cd ..
/usr/bin/7za a $OPTS7 "$DESTARCHIVE" ${TMPDIR}/*
echo "Success! You'll find the new archive at \"$DESTARCHIVE\"."
rm -rf "$TMPDIR"
