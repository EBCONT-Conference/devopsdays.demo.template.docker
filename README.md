# Template Docker

## About

This template can be used to build and potentially deploy Docker images via HELM charts

## Contacts

- **Owner**: EBCONT Conference Team
- **Support**: [EBCONT Conference Team](github@ebcont.com)

## Resources

- **Repository**: [EBCONT-Conference/devopsdays.demo.template.docker](https://github.com/EBCONT-Conference/devopsdays.demo.template.docker)
- **Documentation**: All necessary details are covered in this README file.

## Usage

<b>Don't use this template via the GitHub UI.</br>
Use our [self-service](https://github.com/EBCONT-Conference/devopsdays.demo.self-service) to create a new repository based on this template.</b>

## Description

This template ought to be used to build & deploy one or multiple Docker files. The workflow is powerful yet simple: it support small, medium and large projects all the same. E.g. you may use the template for a singular Docker image or you might need to build 10 images with different build arguments and secrets.

## Workflows

- `entrypoint.yml` is the core workflow calling [a reusable workflow for building]([TODO](https://github.com/EBCONT-Conference/devopsdays.demo.reusable-workflow.build.docker)) capable of handling any Docker operations and [a reusable workflow for deploying]([TODO](https://github.com/EBCONT-Conference/devopsdays.demo.reusable-workflow.deployment.helm)) capable of handling any HELM operations. Please take a look there to see how these workflows can be used, how they can be configured and which requirements must be met.

### Requirements & configuration

- You need at least one `Dockerfile` within your repository
    - You may create and name your `Dockerfile` however you like. Nevertheless, per default the location `./Dockerfile` is used (root level)
- The `entrypoint` workflow is used for build & deploy operations. For builds, a [GitHub actions job matrix](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations) is used. Deployments may only be triggered after successful builds (of all images)

#### Build

The build is straightforward and the default should suffice for most projects. Essentially, if you have a simple, singular `Dockerfile` on the root level which does not need any build secrets or arguments, the default configuration will produce an adequate image. However, you may configure the workflow as you please (remember that GitHub actions job matrixes are used!).

#### Deployment

This repository can be used to trigger deployments. The deployments may either run in the repository itself or in any other compatible deployment repository. For instance, you may build your Docker images here and run any HELM workflows in a dedicated HELM repository. You may use the variables below to change the behaviour of the deployment.

| Option | Description | Default / Notes |
| :--- | :--- | :--- |
| `DEPLOYMENT` | If set to anything but `true`, no deployment will be run. Neither locally nor as a dispatch in another repository | Defaults to `true` (if unset) |
| `DEPLOYMENT_REPOSITORY` | If set, the deployment will run in the specified repository rather than locally. Specify the full repository name with `owner/name`. Ensure the referenced repository has at least one release! Otherwise, specify `DEPLOYMENT_REFERENCE` explicitly. | Not set |
| `DEPLOYMENT_REFERENCE` | Only works if `DEPLOYMENT_REPOSITORY` is set. Per default, the latest release of the referenced repository is used. If no release is available yet or you want to hardcode a specific branch or tag (only use this for testing purposes!) you may use this variable | Not set |
| `ENVIRONMENTS` | The environment string can be influenced by using this variable. Read [here](https://github.com/ebcont/ebcont.it-support.action.environment-selection) if you want to learn more about its options | Not set (which leads to the default environment string being used) |
| `PATH` | The path of the folder where the `Chart.yaml` and all `values.yaml` files reside. | Defaults to `helm` |

Please note that all these variables only work on repository level or above (aka organization and repository, but not environment level).

#### Secrets

These secrets are available:

| Option | Description | Default / Notes |
| :--- | :--- | :--- |
| `BITWARDEN_TOKEN` | Specifies the Bitwarden API token used to access the Bitwarden collection where all secrets reside. Works in tantum with any `secret.json` files. Read more [here](https://github.com/ebcont/ebcont.it-support.action.bitwarden) | Not set |