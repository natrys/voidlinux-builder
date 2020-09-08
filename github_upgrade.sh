#!/bin/sh

package="$2"
template=srcpkgs/$package/template

repo=$(perl -ne 'print $1 if /github.com\/(.*?)\/archive/' < $template)


release() {
  new_tag=$(curl -sL https://api.github.com/repos/$repo/releases/latest | jq -r .tag_name)
  new_version=$(echo $new_tag | perl -pe 's/\D+(.*\d).*/$1/')
  wget -O /tmp/$package.tar.gz https://github.com/$repo/archive/$new_tag.tar.gz
  sed -i -E "\|^_version|s|=.*|=$new_version|" $template
}

master() {
  last_commit=$(curl -sL https://api.github.com/repos/$repo/commits/master | jq -r .sha)
  old_revision=$(grep -Po 'revision=\K.*' $template)
  new_revision=$(expr $old_revision + 1)
  wget -O /tmp/$package.tar.gz https://github.com/$repo/archive/$last_commit.tar.gz
  sed -i -E "\|^_commit|s|=.*|=$last_commit|" $template
  sed -i -E "\|^revision|s|=.*|=$new_revision|" $template
}

"$@"

shasum=$(sha256sum /tmp/$package.tar.gz | cut -d' ' -f1)
sed -i -E "\|^checksum|s|=.*|=$shasum|" $template
rm /tmp/$package*
