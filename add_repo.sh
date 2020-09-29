[ -z "$REPO_ADDR" ] && exit 1

echo "Adding personal repository to the list"

mv /usr/share/xbps.d/00-repository-main.conf /etc/xbps.d/
cp /etc/xbps.d/00-repository-main.conf /etc/xbps.d/01-repository-main.conf
echo repository="$REPO_ADDR" > /etc/xbps.d/00-repository-main.conf
yes | xbps-install -S -y
sed -i -e "1s|^|repository=$REPO_ADDR\n|" /hostrepo/void/etc/xbps.d/repos-remote.conf
