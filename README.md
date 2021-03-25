# Fog SW CI/CD scripts

## USAGE
Have GITHUB_RUN_NUMBER variable set in environmet the script is called

```
git clone <module-url>
cd <module>
git clone git@ghe.ssrc.fi:SSRC-EU/fogsw-ci-scripts.git ./packaging/common
./packaging/common/generate_deb.sh .
```
The debian package is generated into "module" directory
