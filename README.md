Introduction
============

Hiera is a configuration data store with pluggable back ends, hiera-gpg is a backend for hiera that supports gpg coded YAML files

Why?
====

Hiera is often used by configuration management systems such as Puppet with all the configuration stored in a VCS.  Often you want to store sensitive information such as database root passwords in the same place as the rest of your configuration so Puppet can read it.  hiera-gpg allows you to place your YAML in a gpg encoded file which can be read by Hiera on the command line or via Puppet on any machine that has a valid secret key.

Configuration
=============
Here is a sample hiera.yaml file that will work with gpg

<pre>
---
:backends: - gpg

:logger: console

:hierarchy: - %{env}
            - common

:gpg:
   :datadir: /etc/puppet/hieradata

   # Optional, defaults to ~/.gnupg
   :homedir: "/etc/puppet/gpg"
</pre>

Todo
====

The back end currently just shells out to the GPG command (/usr/bin/env gpg) - I would like to implement this without shelling out, perhaps by using the gpgme API.  Perhaps someone would care to fork it and look at doing that :)


Contact
=======

* Author: Craig Dunn
* Email: craig@craigdunn.org
* Twitter: @crayfishX
* IRC (Freenode): crayfishx
* Web: http://www.craigdunn.org


