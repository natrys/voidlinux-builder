scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR -i ~/.ssh/id_rsa void/hostdir/binpkgs/*.xbps $REPO_SCP_ADDR
