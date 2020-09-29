[ -z "$REPO_ADDR" ] && exit 1

mv /usr/share/xbps.d/00-repository-main.conf /etc/xbps.d/
cp /etc/xbps.d/00-repository-main.conf /etc/xbps.d/01-repository-main.conf
echo repository=$REPO_ADDR > /etc/xbps.d/00-repository-main.conf
yes | xbps-install -S -y
