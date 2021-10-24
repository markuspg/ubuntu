# Changelog

## 21.1024.1

* Update Bionic to 18.06.6
* Removal of Xenial

## 21.0828.1

* Update Focal to 20.04.3

## 21.0207.1

* Update Focal to 20.04.2
* Update Bionic to 18.04.5
* Update Xenial to 16.04.7

## 20.0813.1

* Update Focal to 20.04.1
* Update packer files for packer v1.6.x

## 20.0605.1

* Ensure that Virtualbox boxes (18.04 and up) use VMSVGA as default graphics adapter
* Remove hard coded name for Virtualbox
* Make Virtualbox boxes linked clones by default
* Add tests for various changes introduced recently
* Add rubocop and solargraph configuration
* Use live server image for Ubuntu 20.04

## 20.0425.1

* Fix packer scripts for packer 1.5.x
* Update Ubuntu Bionic to 4th point release
* Add support for Ubuntu Focal beta
* German input source is now added again when building the box
* Cleanup of packer configuration files
* ISOs of Ubuntu install media can now be put into the iso/ folder to avoid repeated downloads

## 19.1110.1

* Update Ubuntu Bionic to 3rd point release

## 19.0729.1

* Removed support for Ubuntu Trusty
* Remove motd script that displays information about the box on every login
* Cleanup of scripts
  * removal of unused scripts
  * minimize is now used during the build
* The screensaver is now disabled by default
* LibreOffice and some Gnome Tools have been removed to decrease the size of the boxes
* Fix auto-login

## 19.0306.1

* Update Ubuntu Xenial to 6th point release
* Fix formatting of README.md

## 19.0218.1

* Update Ubuntu bionic box to 2nd point release

## 18.1125.1

* Fix auto-login not working in Ubuntu 18.04
* Fix broken network configuration in vmware
* Remove parallels support

## older versions

* Add support for Ubuntu 18.04
* Remove support for non-LTS Ubuntu versions
* Remove support for LTS Ubuntu versions after their EOL
