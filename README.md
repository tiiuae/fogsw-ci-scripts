# Fog SW CI/CD scripts

## USAGE
Have GITHUB_RUN_NUMBER variable set in environmet the script is called

```
git clone git@ghe.ssrc.fi:SSRC-EU/fogsw-ci-scripts.git
git clone <module-url>
cd fogsw-ci-scripts
./generate_deb.sh <cloned-module-dir> <deb-output-dir>

```
The debian package is generated into "module" directory
