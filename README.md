<a href="http://github.com/igal/antipackaging/raw/master/barbarian.jpg"><img src="http://github.com/igal/antipackaging/raw/master/barbarian.jpg" height="25%"></a>

A Barbarian's Guide To Avoiding Packaging
=========================================

Overview
--------

This document discusses and demonstrates techniques for avoiding packaging by abusing your configuration system.

Guide
-----

DISCLAIMER: Packages are the "correct" way. Avoid them at your own risk.

Barbaric analogy: Looting may provide a much higher value for the effort invested than agriculture. However, it's wrong, unsustainable and dangerous.

Why: You can save phenomenal amounts of time by avoiding packaging in certain cases. Doing packaging "correctly" can require weeks to months to learn bizarre tools, setup new build and repository servers, change your workflow, reverse-engineer existing packages, etc. In contrast, very complete solutions leveraging your existing configuration system can be designed in hours to days, and adding support for managing new application with them can sometimes be done within minutes.

Scope: When this document talks about packages, it's referring to things like rpm's and deb's -- but not Rubygems, Python Eggs, PEAR, CPAN, etc.

How to avoid packaging:

* Control your software: Use a configuration system (e.g. Puppet, Chef, etc) to download, compile and install software from source.
* Control your files: Optionally use a cache (e.g. Amazon S3) to keep copies of source files rather than have the configuration system download them from the official site.  This avoids problems with the official site going offline, or reorganizing or expiring the files.
* Control your links: Optionally use a symlink manager (e.g. [stow](http://www.gnu.org/software/stow/) or [xstow](http://xstow.sourceforge.net/)) to install software into self-contained directories that you can symlink into place, so you can later uninstall or upgrade the software. See "Stow" section below for further details.
* Control your security: Optionally cryptographically sign and maybe encrypt the files to thwart hackers. E.g. passphrase encryption or GPG key.
* Control your compiles: Optionally upload compiled versions of the installed files for the target OS. If you do this and the rest of the optional things, then congrats: you've built your own packaging system.

Pros:

* Hubris: No need to learn packaging tools, just need to master your configuration system.
* Impatience: Can often modify a single file and go from concept to production in minutes, if you know what you're doing.
* Laziness: No separate build process, no build artifacts, no build servers, no repository servers, nor any coordination of separate packages and configurations. Build steps are right there in the configuration and never go out of sync.

Cons:

* Reinventing the wheel: The complete system I've described is basically a hacked-together custom package manager. :)
* Resources: Downloading all the dependencies and compiling sources on each computer can take a lot of time and bandwidth.
* Risk and repeatability: Relying on a bunch of compile-time dependencies, clever configuration code and running crazy shell commands increases the risk of something going horribly wrong.
* Complexity: Building software with your configuration system can require complicated code that's hard to write, maintain, and train others to support.
* Mixing concerns: Shoving compile logic into your configuration system is barbaric.

Stow
----

Here's how [stow](http://www.gnu.org/software/stow/) is used from a shell, which is needed to understand the recipes and providers later:

```bash
    # Extract some source code
    % tar xvfz nginx-1.3.1.tar.gz
    % cd nginx-1.3.1

    # Compile and install it into a standalone directory
    % ./configure --prefix=/usr/local/stow/nginx-1.3.1
    % make
    % sudo make install

    # Go into the stow directory
    % cd /usr/local/stow

    # Look at the standalone directory we just installed
    % find nginx-1.3.1
    nginx-1.3.1/
    nginx-1.3.1/sbin
    nginx-1.3.1/sbin/nginx
    ...

    # Stow the software
    % sudo stow nginx-1.3.1

    # Check that a symlink was created
    % type nginx
    nginx is /usr/local/sbin/nginx

    # Notice the symlink points at our standalone directory
    % ls -lad `which nginx`
    /usr/local/sbin/nginx -> ../stow/nginx-1.3.1/sbin/nginx

    # Unstow the software
    % sudo stow -D nginx-1.3.1

    # The symlink is gone
    % type nginx
    bash: type: foo: not found

    # Uninstall the software
    % sudo rm -rf nginx-1.3.1
```

Recipes
-------

* [standalone](http://github.com/igal/antipackaging/blob/master/cookbooks/antipackaging/recipes/standalone.rb) - An easy-to-understand Chef recipe to download, compile, install and stow an application.
* [stow](http://github.com/igal/antipackaging/blob/master/cookbooks/antipackaging/recipes/stow.rb) - A streamlined process for installing different applications using a custom resource.
* [uninstall](http://github.com/igal/antipackaging/blob/master/cookbooks/antipackaging/recipes/uninstall.rb) - A streamlined process for uninstalling different applications using a custom resource.

Resources and Providers
-----------------------

* [stow resource](http://github.com/igal/antipackaging/blob/master/cookbooks/stow_package/resources/default.rb) - A custom Chef resource to download, compile, install and stow applications.
* [stow provider](http://github.com/igal/antipackaging/blob/master/cookbooks/stow_package/providers/default.rb) - A custom Chef provider to implement the above resource.

Running examples
----------------

To run the examples, you should setup a test machine running Ubuntu 10.04 that will run the code. Either name the machine `client` in your `/etc/hosts`, or rename `nodes/client.json` so that `client` is actual name.

Checkout this repository and go into it:

    git clone git://github.com/igal/antipackaging.git
    cd antipackaging

Install pocketknife, you may need to use `sudo`:

    gem install pocketknife

The following commands will apply changes to `client`. The first time you use these, you may be asked to install Chef on the client, agree to this or install it yourself. Because these download and compile code, they may take a few minutes.

Apply the `standalone` recipe to install `nginx`:

    pocketknife client -r antipackaging::standalone

Apply the `stow` recipe to install `nginx` and `ts` if needed using a reusable resource:

    pocketknife client -r antipackaging::stow

Apply the `uninstall` recipe to uninstall `nginx` and `ts`:

    pocketknife client -r antipackaging::uninstall

Picture
-------

The amusing picture at the top is from Gord Webster and is available under a Create Commons ShareAlike license:
http://www.flickr.com/photos/thievingjoker/3020262823/

License
-------

Copyright (c) 2012 Igal Koshevoy under the [MIT License](http://www.opensource.org/licenses/mit-license.php).
