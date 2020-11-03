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
        core.warning(`The chart must be converted to Resource Contract`)
    }
    else if (dependency.version != requiredVersion) {
        core.warning(`qlikcommon: ${dependency.version} is outdated, upgrade to ${requiredVersion}`);
    }
} catch (error) {
    console.log(error.message);
    core.warning("The chart must be converted to Resource Contract");
}
