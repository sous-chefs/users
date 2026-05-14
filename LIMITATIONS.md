# Limitations

## Package Availability

The users cookbook manages operating system users and groups with Chef Infra's built-in `user`,
`group`, `directory`, and `template` resources. It does not install or configure a third-party
package and therefore has no vendor APT, DNF/YUM, or Zypper repository.

## Platform Support

Support is constrained by Chef Infra's native account-management resources and the cookbook helper
logic for platform-specific defaults.

The tested Linux platform matrix uses currently supported Sous Chefs Dokken images:

* AlmaLinux 8, 9, and 10
* Amazon Linux 2023
* CentOS Stream 9 and 10
* Debian 12 and 13
* Fedora latest
* Oracle Linux 8 and 9
* Rocky Linux 8, 9, and 10
* Ubuntu 22.04 and 24.04

macOS remains covered through the exec driver because the cookbook contains macOS-specific helper
logic. AIX, FreeBSD 13+, openSUSE Leap 16+, SUSE Linux Enterprise 15+, and zLinux remain declared
metadata support because the cookbook uses Chef's native resources for those platforms, but they
are not part of the default local Dokken verification path.

## Architecture Limitations

No package architecture limits apply. Account-management behavior depends on the target operating
system's user and group tooling.

## Source/Compiled Installation

No source or compiled installation is performed.

## Known Issues

* Windows support remains disabled in CI and metadata because the existing Windows workflow is not
  currently active.
* openSUSE Leap 15.6 reached end of life on 2026-04-30; Leap 16 is the current supported Leap
  release, but no matching Dokken image is currently used by this cookbook.
* Data bag searches require Chef Server, Policyfile test data, or a compatible local solo search
  setup when used outside Test Kitchen.
