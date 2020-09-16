#!/bin/sh

package="$2"
template=srcpkgs/$package/template

repo=$(grep -Po 'github.com/\K(.*?)(?=/archive)' < $template)
[ -n "$repo" ] || exit 1

release() {
  new_tag=$(curl -sL https://api.github.com/repos/$repo/releases/latest | jq -r .tag_name)
  old_version=$(grep -Po '^version=\K.*' $template)
  new_version=$(echo $new_tag | perl -pe 's/\D+(.*\d).*/$1/')
  
  [ "$old_version" = "$new_version" ] && exit 1
  wget -O /tmp/$package.tar.gz https://github.com/$repo/archive/$new_tag.tar.gz
  sed -i -E "\|^_version|s|=.*|=$new_version|" $template
}

master() {
  info=/tmp/$package.commit
  curl -sL https://api.github.com/repos/$repo/commits/master > $info
  old_commit=$(grep -Po '^_commit=\K.*' $template)
  new_commit="$(jq -r .sha $info)"
  [ "$old_commit" = "$new_commit" ] && exit 1
  
  wget -O /tmp/$package.tar.gz https://github.com/$repo/archive/$new_commit.tar.gz

  old_version=$(grep -Po 'version=\K\d{8}' $template)
  if [ "$old_version" ]; then
    new_version=$(jq -r .commit.committer.date < $info | sed -E 's|T.*||; s|-||g')
    if [ "$old_version" = "$new_version" ]; then
      old_revision=$(grep -Po '^revision=\K.*' $template)
      new_revision=$(expr $old_revision + 1)
    else
      new_revision=1
    fi
    
    sed -i -E "\|^version|s|=.*|=$new_version|" $template
    rm $info
  fi

  sed -i -E "\|^_commit|s|=.*|=$new_commit|" $template
  sed -i -E "\|^revision|s|=.*|=$new_revision|" $template
}

"$@"

shasum=$(sha256sum /tmp/$package.tar.gz | cut -d' ' -f1)
sed -i -E "\|^checksum|s|=.*|=$shasum|" $template
rm /tmp/$package.tar.gz
