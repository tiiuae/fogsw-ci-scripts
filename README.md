# Fog SW CI/CD scripts

## USAGE
Have GITHUB_RUN_NUMBER variable set in environmet the script is called.
generate_deb.sh script takes two parameters:
 1. Path to the module source code that is built and packagaged
 2. Path to the output directory where debian package is generated to

```
git clone git@ghe.ssrc.fi:SSRC-EU/fogsw-ci-scripts.git
git clone <module-url>
cd fogsw-ci-scripts
./generate_deb.sh <cloned-module-dir> <deb-output-dir>

```
The debian package is generated and copied into given output directory

NOTE: For building Linux Kernel an environmental variable is needed to be set: KERNEL_CONFIG.<br>
As the name indicates, the variables contains the Linux Kernel configuration to be used in the build.
