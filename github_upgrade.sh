#!/bin/sh

pkgname="$2"
template=srcpkgs/$pkgname/template

repo=$(grep -Po 'github.com/\K(.*?/.*?)(?=/)' < $template)
[ -n "$repo" ] || exit 1

export distfile=$(grep -Po "^distfiles=\\K\"https://github.com/$repo/.*\"" < $template)

release() {
  new_tag=$(curl -sL https://api.github.com/repos/$repo/releases/latest | jq -r .tag_name)
  old_version=$(grep -Po '^version=\K.*' $template)
  new_version=$(echo $new_tag | perl -pe 's/(?:\D*)?(.*\d)(?:.*)?/$1/')
  [ "$old_version" = "$new_version" ] && exit 1

  tarball=$(pkgname=$pkgname version=$new_version sh -c 'eval echo $distfile')
  wget -O /tmp/$pkgname.tar.gz $tarball
  
  sed -i -E "\|^version|s|=.*|=$new_version|" $template
}

head() {
  branch=master
  [ -n "$2" ] && branch=$2
  info=/tmp/$pkgname.commit
  curl -sL https://api.github.com/repos/$repo/commits/$branch > $info
  old_commit=$(grep -Po '^_commit=\K.*' $template)
  new_commit="$(jq -r .sha $info)"
  [ "$old_commit" = "$new_commit" ] && exit 1
  
  old_revision=$(grep -Po '^revision=\K.*' $template)
  
  tarball=$(pkgname=$pkgname _commit=$new_commit sh -c 'eval echo $distfile')
  wget -O /tmp/$pkgname.tar.gz $tarball

  old_date=$(grep -Po 'version=\K\d{8}' $template)
  if [ "$old_date" ]; then
    new_date=$(jq -r .commit.committer.date < $info | sed -E 's|T.*||; s|-||g')
    if [ "$old_date" = "$new_date" ]; then
      new_revision=$(expr $old_revision + 1)
    else
      new_revision=1
    fi
    sed -i -E "\|^version|s|=.*|=$new_date|" $template
    rm $info
  else
    new_revision=$(expr $old_revision + 1)
  fi

  sed -i -E "\|^_commit|s|=.*|=$new_commit|" $template
  sed -i -E "\|^revision|s|=.*|=$new_revision|" $template
}

"$@"

shasum=$(sha256sum /tmp/$pkgname.tar.gz | cut -d' ' -f1)
sed -i -E "\|^checksum|s|=.*|=$shasum|" $template
rm /tmp/$pkgname.tar.gz
