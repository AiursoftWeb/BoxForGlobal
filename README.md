<a name="boxforglobal-"></a>

# Aiursoft BoxForGlobal

## Overview

### What is BoxForGlobal?

**Role:** International Hub & Download Station

This repository contains the configuration for the **Global Region** nodes (currently based in Poland/Voxihost).

<a name="-strategic-objective"></a>

**Strategic objective.**

To serve as the high-bandwidth gateway for the rest of the world and act as the "Resource Retainment" center for the cluster.

## Installation

Use a dedicated Linux host with systemd, Git, Bash and sudo access for this Box. The deployment entry point changes host configuration, installs or configures Docker, and deploys Docker Swarm services. Prepare the intended host, its storage and network access before running it.

Fetch the configuration repository:

```bash
git clone https://gitlab.aiursoft.com/aiursoft/boxforglobal.git
cd boxforglobal
```

Configure the private environment described in Configuration before deployment. This repository configures its named target; it is not a general-purpose installer for an unrelated workstation.

## Usage

<a name="-architecture-specifics"></a>

### Architecture

*   **Public Face:** The IP address behind `*.aiursoft.com` for international users.
*   **CDN Origin:** Protected by Cloudflare.
*   **Download Station:**
    *   Since bandwidth is cheap/unlimited here, this node handles mirroring of:
        *   Ubuntu Apt Repos
        *   PyPI (Python)
        *   Docker Hub Images
        *   NPM / NuGet Packages
    *   It serves these mirrored assets to `BoxForChina` and `BoxForProart` to save their limited bandwidth.

<a name="-stacks-included"></a>

### Stacks included

*   **Stage 3 (Registry & Auth):**
    *   `authentik`: The central SSO Identity Provider (IDP).
    *   `zot`: OCI-native Docker Registry.
    *   `puller`: Automated image syncing service.
    *   `aptmirror` / `ppamirror`: Local repositories for Debian/Ubuntu.
*   **Stage 4 (Apps):**
    *   `chessserver`: Signed-in chess games at `chess.aiursoft.com`.
    *   `dms`: Single-instance operations Controller with OIDC at `dms.aiursoft.com`; persistent workflow state and isolated MySQL/ClickHouse data.
    *   `alertcenter`: Alert management and on-call response at `alertcenter.aiursoft.com`.
    *   `manhours`, `wiki`, `www`: Static or lightweight web apps.
    *   `uptimekuma`: External monitoring of the other two boxes.

The list above describes the Box's service roles. The tracked `stage*/stacks` directories are the source of truth for the current deployable stack inventory.

### Deployment operations

Select a starting stage and, when needed, a stage-4 stack name filter:

```bash
sudo bash deploy.sh --stage 4 --filter shepherd
```

`--stage` starts at the selected stage and continues through the later stages; it is not an instruction to run only that stage. `--filter` matches stage-4 stack names by substring. Earlier stages are not filtered, so combine it with `--stage 4` for a targeted application deployment.

**Check the result.** On the target Swarm manager, inspect the selected stack and its tasks:

```bash
sudo docker stack ls
sudo docker stack services shepherd
sudo docker stack ps shepherd --no-trunc
```

Replace `shepherd` with the stack being inspected. Confirm the desired replicas, task errors and the service's own health endpoint or application behavior. A successful `docker stack deploy` submission does not prove every service is healthy. For a failed change, inspect task errors and restore a reviewed configuration through the same deployment entry point; preserve existing bind-mounted data.

## Configuration

`deploy.sh` reads `.env.prod` first and falls back to `.env`; it does not merge the two files. Keep real credentials in the private deployment environment. Values replace matching `{{VARIABLE_NAME}}` placeholders in temporary Compose copies; tracked Compose sources remain unchanged.

Prepare the private file from the tracked [.env](.env) reference and fill in the values required by the selected services:

```bash
cp .env .env.prod
$EDITOR .env.prod
```

`REGISTRY_HOST` and `REGISTRY_VERIFICATION_IMAGE` select the registry and the image used to verify access. `DOCKERHUB_USERNAME` and `DOCKERHUB_PASSWORD` are the deployment registry credentials. `PUBLIC_DOCKER_HUB_USERNAME` and `PUBLIC_DOCKER_HUB_PASSWORD` provide the separate public Docker Hub bootstrap credentials. The tracked environment reference also lists each application's OIDC, API, mail and other external settings. An absent environment file does not supply defaults for required registry credentials.

Service definitions and bind mounts live in `stage<N>/stacks/<stack-name>/docker-compose.yml`; custom image sources live in `stage<N>/images`. Review these files, the Caddy routes and any FRP configuration together before changing a service's exposure or storage. Keep existing database credentials and persistent data consistent during updates.

## Development

Validate the configuration using the repository's existing lint entry point:

```bash
bash -n deploy.sh
python3 ./lint.py
```

The linter requires Python 3 and PyYAML. The existing GitLab merge-request pipeline runs the repository's configured lint checks. Syntax and configuration checks do not deploy services or verify a live host.

<a name="-deployment"></a>

Use the supported deployment entry point for the intended target:

```bash
# On a fresh Global VPS (e.g., Voxihost):
git clone https://gitlab.aiursoft.com/aiursoft/boxforglobal.git
cd boxforglobal
sudo bash deploy.sh
```

## How to contribute

There are many ways to contribute to the project: logging bugs, submitting pull requests, reporting issues, and creating suggestions.

Even if you have push rights on the repository, you should create a personal fork and create feature branches there when you need them. This keeps the main repository clean and your workflow cruft out of sight.

We're also interested in your feedback on the future of this project. You can submit a suggestion or feature request through the issue tracker. To make this process more effective, we're asking that these include more information to help define them more clearly.

## License

Licensed under the [GNU General Public License v3.0](LICENSE).
