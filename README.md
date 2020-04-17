# Packer templates for Ubuntu

## Overview

This repository contains [Packer](https://packer.io/) templates for creating Ubuntu Vagrant boxes.

## Current Boxes

Pre-built boxes can be found here: [vagrantup](https://app.vagrantup.com/fasmat)

## Building the Vagrant boxes with Packer

To build all the boxes, you will need [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and
[VMware Fusion](https://www.vmware.com/products/fusion) or [VMware Workstation](https://www.vmware.com/products/workstation)
installed.

We make use of JSON files containing user variables to build specific versions of Ubuntu.
You tell `packer` to use a specific user variable file via the `-var-file=` command line
option.  This will override the default options on the core `ubuntu.json` packer template,
which builds Ubuntu 20.04 by default.

For example, to build Ubuntu 18.04, use the following:

```bash
packer build -var-file=ubuntu1804-desktop.json ubuntu.json
```

If you want to make boxes for a specific desktop virtualization platform, use the `-only`
parameter.  For example, to build Ubuntu 18.04 for VirtualBox:

```bash
packer build -only=virtualbox-iso -var-file=ubuntu1804-desktop.json ubuntu.json
```

The templates currently support the following desktop virtualization strings:

* `virtualbox-iso` - [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
  desktop virtualization
* `vmware-iso` - [VMware Fusion](https://www.vmware.com/products/fusion) or
  [VMware Workstation](https://www.vmware.com/products/workstation) desktop virtualization

## Building the Vagrant boxes with the box script

We've also provided a wrapper script `bin/box` for ease of use, so alternatively, you can use
the following to build Ubuntu 20.04 for all providers:

```bash
bin/box build ubuntu2004-desktop
```

Or if you just want to build Ubuntu 20.04 for VirtualBox:

```bash
bin/box build ubuntu2004-desktop virtualbox
```

## Building the Vagrant boxes with the Makefile

A GNU Make `Makefile` drives a complete basebox creation pipeline with the following stages:

* `build`   - Create basebox `*.box` files
* `test`    - Verify that the basebox `*.box` files produced function correctly
* `deliver` - Upload `*.box` files to [Vagrant Cloud](https://app.vagrantup.com)

The pipeline is driven via the following targets, making it easy for you to include them
in your favorite CI tool:

```bash
make build       # Build all available box types
make test        # Run tests against all the boxes
make deliver     # Upload box artifacts to a repository
make test-cloud  # Test deployed boxes (after downloading them)
make clean       # Clean up build detritus
```

### Proxy Settings

The templates respect the following network proxy environment variables
and forward them on to the virtual machine environment during the box creation
process, should you be using a proxy:

* http_proxy
* https_proxy
* ftp_proxy
* rsync_proxy
* no_proxy

### Tests

Automated tests are written in [Serverspec](http://serverspec.org) and require
the `vagrant-serverspec` plugin to be installed with:

```bash
vagrant plugin install vagrant-serverspec
```

The `bin/box` script has sub-commands for running both the automated tests
and for performing exploratory testing.

Use the `bin/box test` sub-command to run the automated Serverspec tests.
For example to execute the tests for the Ubuntu 20.04 box on VirtualBox, use
the following:

```bash
bin/box test ubuntu2004-desktop virtualbox
```

### Variable overrides

There are several variables that can be used to override some of the default
settings in the box build process. The variables can that can be currently
used are:

* cpus
* disk_size
* memory
* update

The variable `HEADLESS` can be set to run Packer in headless mode.
Set `HEADLESS := true`, the default is false.

The variable `UPDATE` can be used to perform OS patch management.  The
default is to not apply OS updates by default.  When `UPDATE := true`,
the latest OS updates will be applied.

The variable `PACKER` can be used to set the path to the packer binary.
The default is `packer`.

The variable `ISO_PATH` can be used to set the path to a directory with
OS install images. This override is commonly used to speed up Packer builds
by pointing at pre-downloaded ISOs instead of using the default download
Internet URLs.

The variables `SSH_USERNAME` and `SSH_PASSWORD` can be used to change the
default name & password from the default `vagrant`/`vagrant` respectively.

The variable `INSTALL_VAGRANT_KEY` can be set to turn off installation of the
default insecure vagrant key when the image is being used outside of vagrant.
Set `INSTALL_VAGRANT_KEY := false`, the default is true.

The variable `CUSTOM_SCRIPT` can be used to specify a custom script
to be executed. You can add it to the `script/custom` directory (content
is ignored by Git).
The default is `custom-script.sh` which does nothing.

## Contributing

1. Fork and clone the repository.
2. Create a new branch, please don't work in your `master` branch directly.
3. Add new [Serverspec](http://serverspec.org/) tests in the `test/` subtree for the change you want to make.
4. Run `make test` to test all templates or `bin/box test` on individual boxes to see if the tests pass.
5. Fix stuff if necessary. Repeat steps 3-5 until done.
6. Update `README.md` and `AUTHORS` to reflect any changes.
7. If you have a large change in mind, it is still preferred that you split them into small commits.  Good commit messages are important.
   The git project has some nice guidelines on [writing descriptive commit messages](http://git-scm.com/book/ch5-2.html#Commit-Guidelines).
8. Push to your fork and submit a pull request.
