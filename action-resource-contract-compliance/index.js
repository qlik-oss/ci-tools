const core = require('@actions/core');
const github = require('@actions/github');
//const fs = require('fs');
//const yaml = require('js-yaml');

try {
    //let fileContents = fs.readFileSync('./data-multi.yaml', 'utf8');
    //let data = yaml.safeLoadAll(fileContents);

    const nameToGreet = core.getInput('artifactory_user');
    console.log(`Hello ${nameToGreet}!`);
    const time = (new Date()).toTimeString();
    core.setOutput("time", time);
    // Get the JSON webhook payload for the event that triggered the workflow
    const payload = JSON.stringify(github.context.payload, undefined, 2)
    console.log(`The event payload: ${payload}`);
    } catch (error) {
    core.setFailed(error.message);
}