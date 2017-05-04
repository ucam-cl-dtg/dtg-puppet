#!/bin/sh

# Abort if something goes wrong
set -e

# Install puppet
echo "Installing puppet-common and git-core"
apt-get -y install puppet-common git-core python-software-properties \
    software-properties-common parted

# From mfpl-puppet/modules/mayfirst/files/freepuppet/frepuppet-init
# prep a server to be free of a puppet master
# re-run this command to clear out your local git
# repo (allowing you to re-push after git commit --amend)

echo "Setting up git repositories"
git config --system core.sharedRepository group

# remove /etc/puppet as installed by puppet
rm -rf /etc/puppet

mkdir /etc/puppet
cd /etc/puppet
git init --shared=group

# create bare repo that admins will push to
admin_bare_repo="/etc/puppet-bare"
[ -d "$admin_bare_repo" ] && rm -rf "$admin_bare_repo"
mkdir "$admin_bare_repo"
cd "$admin_bare_repo"
git init --bare --shared=group

# create post-update hook to pull in changes to the real puppet repo
target="$admin_bare_repo/hooks/post-update"
cat > $target << EOM
echo ---- Pulling changes into /etc/puppet -----

cd /etc/puppet
unset GIT_DIR
git pull --recurse-submodules=yes bare  master
git submodule sync
git submodule update --init

sudo chmod -R --quiet g+u . .git || true

sudo chgrp -R --quiet adm . .git || true

find . -type d -print0 | sudo xargs -0 -s 256 chmod --quiet g+s || true

find .git -type d -print0 | sudo xargs -0 -s 256 chmod --quiet g+s || true

echo ---- Applying new recipes ----

sudo -H puppet apply --verbose --modulepath modules manifests/nodes/
EOM

chmod 775 hooks/post-update

# Ensure sensible permissions for bare repository
chmod -R g+u .
chgrp -R adm .
find . -type d -print0 | xargs -0 -s 256 chmod g+s

# add  as a remote to real puppet repo
cd /etc/puppet
git remote add bare "$admin_bare_repo"

# Pull the current contents of the repository
git pull --recurse-submodules=yes git://github.com/ucam-cl-dtg/dtg-puppet.git
git submodule update --init

# Ensure sensible permissions for checked out repository
chmod -R g+u . .git
chgrp -R adm . .git
find . -type d -print0 | xargs -0 -s 256 chmod g+s
find .git -type d -print0 | xargs -0 -s 256 chmod g+s
chmod -R g+u .git # otherwise not necessarily covered
chgrp -R adm .git

# Pull in the current contents
git push --set-upstream bare master

