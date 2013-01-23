DTG Puppet Repository
=====================

Contains puppet configuration for DTG services.

To fully clone including submodules you need to do:
`git submodule init && git submodule update`

The copyright status of this code needs clarifying, it would probably have to be AGPL at the moment because we use some mayfirst stuff.

TODO
----
* Fix envelope from address for emails to be a dtg- alias rather than root@cl so that we rather than the cl sysadmins get bounces.
* Run puppet-lint on the code
* Get signing of nodes ssh and gpg keys working - more automation
* Setup a secrets server using the root gpg-ssh key of nodes to ssh in, doing access control using unix, later/when there is actually sensitive stuff on it move to also encrypting the secrets on the secret server so that we don't have to trust it.
* Move all existing servers into puppet:
 * jenkins - get jenkins config into version control so that we can restore that, pull in required secrets from secret server.
 * code
 * minibus
 * learn
 * meter-www-live
 * dtg-weather
 * dtg-www
 * husky
 * trac (or at least something to replace trac)
 * open-room-map
* Configure backups
