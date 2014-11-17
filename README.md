# SDSC "sdsc" roll

## Overview

This roll bundles a collection of files required for developing and using
Rocks rolls from the SDSC development group.

## Requirements

To build/install this roll you must have root access to a Rocks development
machine (e.g., a frontend or development appliance).


## Dependencies

None.


## Building

To build the sdsc-roll, execute this on a Rocks development
machine (e.g., a frontend or development appliance):

```shell
% make 2>&1 | tee build.log
```

A successful build will create the file `weka-*.disk1.iso`.  If you built the
roll on a Rocks frontend, proceed to the installation step. If you built the
roll on a Rocks development appliance, you need to copy the roll to your Rocks
frontend before continuing with installation.


## Installation

To install, execute these instructions on a Rocks frontend:

```shell
% rocks add roll *.iso
% rocks enable roll sdsc
% cd /export/rocks/install
% rocks create distro
% rocks run roll sdsc | bash
```


## Testing

The sdsc-roll includes a test script which can be run to verify proper
installation of the roll documentation, binaries and module files. To
run the test scripts execute the following command(s):

```shell
% /root/rolltests/sdsc.t 
```
