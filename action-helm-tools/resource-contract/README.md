## Resource Contract compliance check

This script checks whether a chart is using qlikcommon, and if it's using the correct (latest) version.

### Required environment variables

```yaml
CHART_DIR                   # The directory where Chart.yaml is located

LATEST_QLIKCOMMON_VERSION   # The latest (required) version of qlikcommon.
```

### Build and publish

In order to build a new version of this script, that *does not* rely on a checked in `node_modules`, do the following:

```sh
npm install
ncc build check-compliance.js --license licenses.txt
mv dist/index.js dist/check-compliance.js
```

This will create a "compiled" version of the script that has it's dependencies "baked in".