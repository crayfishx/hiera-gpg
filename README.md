DEPRECATION NOTICE - END OF LIFE:

Please note that this project is now considered end-of-life and is no longer actively maintained.  Hiera-eyaml provides a much nicer implementation of encrypted hiera data and should be used instead of hiera-gpg.

If anyone feels like they would like to continue with this project and maintain please contact craig@craigdunn.org



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
   :datadir: /etc/hiera/data

   # Optional, defaults to ~/.gnupg
   :key_dir: /etc/hiera/gpg
</pre>


By default hiera-gpg will look for GPG keys in the users' home directory (~/.gnupg) - if you want to install your secret keys somewhere else, the :key_dir: setting will override the GNUPGHOME environment variable and cause GPG to look there instead.  Note: in 0.x releases this setting is called "homedir"


GPG Back end
============

hiera-gpg 0.1.0+ shells out to the command line and assumes that /usr/bin/env gpg is in your path.  As of 1.0 it uses the gpgme rubygem to do all the GPG related stuff.  If for any reason you have problems with gpgme then you may want to downgrade to the latest 0.x release.


Further Reading
===============

* http://www.craigdunn.org/2011/10/secret-variables-in-puppet-with-hiera-and-gpg/

Contact
=======

* Author: Craig Dunn
* Email: craig@craigdunn.org
* Twitter: @crayfishX
* IRC (Freenode): crayfishx
* Web: http://www.craigdunn.org


