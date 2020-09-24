#!/usr/bin/env node
const core = require('@actions/core');
const fs = require('fs');
const yaml = require('js-yaml');

try {
    console.log('==> Check resource Contract compliance');

    const chartDir = process.env.CHART_DIR;
    const requiredVersion = process.env.LATEST_QLIKCOMMON_VERSION;
    const fileContents = fs.readFileSync(`${chartDir}/requirements.yaml`, 'utf8');

    // Check if qlikcommon is listed as dependency, and has the correct version.
    const {dependencies} = yaml.safeLoadAll(fileContents)[0];
    const dependency = dependencies.find(dep => dep.name == 'qlikcommon');
    if (dependency == undefined) {
        core.warning(`Component is not using resource contract`)
    }
    else if (dependency.version != requiredVersion) {
        core.warning(`Wrong version of qlikcommon: ${dependency.version} (required: ${requiredVersion})`);
    }
} catch (error) {
    core.warning(error.message);
}
