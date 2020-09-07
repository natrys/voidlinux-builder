#!/bin/sh

package="$1"
template=srcpkgs/$package/template

repo=$(perl -ne 'print $1 if /github.com\/(.*?)\/archive/' < $template)

old_revision=$(grep -Po 'revision=\K.*' $template)
new_revision=$(expr $old_revision + 1)

last_commit=$(curl -sL https://api.github.com/repos/$repo/commits/master | jq -r .sha)
echo $last_commit

wget -O /tmp/$package.tar.gz https://github.com/$repo/archive/$last_commit.tar.gz
shasum=$(sha256sum /tmp/$package.tar.gz | cut -d' ' -f1)

sed -i -E "\|^_commit|s|=.*|=$last_commit|" $template
sed -i -E "\|^revision|s|=.*|=$new_revision|" $template
sed -i -E "\|^checksum|s|=.*|=$shasum|" $template
