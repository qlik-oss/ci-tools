const core = require('@actions/core');
const github = require('@actions/github');
const fs = require('fs');
const yaml = require('js-yaml');

try {
    const chartDir = process.env.CHART_DIR || core.getInput('chart_dir');
    const qlikcommonVersion = process.env.QLIKCOMMON_VERSION || core.getInput('qlikcommon_version');
    const fileContents = fs.readFileSync(`${chartDir}/requirements.yaml`, 'utf8');

    // Check if qlikcommon is listed as dependency.
    const {dependencies} = yaml.safeLoadAll(fileContents)[0];
    const {version} = dependencies.find(dep => dep.name == 'qlikcommon');
    if (version) {
        console.log(`Found qlikcommon version: ${version}`);
        console.log(`Requires qlikcommon version: ${qlikcommonVersion}`);
    }
    // Get the JSON webhook payload for the event that triggered the workflow
    const payload = JSON.stringify(github.context.payload, undefined, 2)
    console.log(`The event payload: ${payload}`);
    } catch (error) {
    core.setFailed(error.message);
}