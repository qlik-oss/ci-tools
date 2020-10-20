# action-verify-compliance

GitHub Action for verifying compliance of a given type (twistlock, blackduck etc.).

## Required Environment variables

```yaml
TARGET_OWNER: # owner of the target for which a compliance verification should be performed; e.g. a repository owner
TARGET_NAME: # name of the target for which a compliance verification should be performed; e.g. a repository name
TARGET_REF: # ref for which a compliance verification should be performed; e.g. a fully qualified tag name (refs/tags/vX.Y.Z)
VERIFICATION_TYPE: # type of verification to be performed, e.g "twistlock" or "blackduck"
VERIFICATION_COMMAND_REPO: # the repository containing verification commands
GITHUB_TOKEN: # github token with read access to the verification command repo
ARTIFACTORY_PUBLISH_USER: # Artifactory username; required only for verification commands which need access to Artifactory
ARTIFACTORY_PUBLISH_PASS: # Artifactory password; required only for verification commands which need access to Artifactory
TWISTLOCK_USER: # Twistlock username; required only for twistlock verification
TWISTLOCK_PASS: # Twistlock password; required only for twistlock verification
BLACKDUCK_USER: # Blackduck username; required only for blackduck verification
BLACKDUCK_PASS: # Blackduck password; required only for blackduck verification
```

## Optional Environment variables

```yaml
VERIFICATION_COMMAND_REPO_BRANCH: # A branch to be checked out in the verification command repo before the verification command is executed. Default "HEAD"
```


# Example workflow

```yaml
TBD
```
