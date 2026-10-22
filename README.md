# BoxForGlobal 🌍

**Role:** International Hub & Download Station

This repository contains the configuration for the **Global Region** nodes (currently based in Poland/Voxihost).

## 🎯 Strategic Objective
To serve as the high-bandwidth gateway for the rest of the world and act as the "Resource Retainment" center for the cluster.

## 🏗 Architecture Specifics
*   **Public Face:** The IP address behind `*.aiursoft.com` for international users.
*   **CDN Origin:** Protected by Cloudflare.
*   **Download Station:**
    *   Since bandwidth is cheap/unlimited here, this node handles mirroring of:
        *   Ubuntu Apt Repos
        *   PyPI (Python)
        *   Docker Hub Images
        *   NPM / NuGet Packages
    *   It serves these mirrored assets to `BoxForChina` and `BoxForProart` to save their limited bandwidth.

## 📦 Stacks Included
*   **Stage 3 (Registry & Auth):**
    *   `authentik`: The central SSO Identity Provider (IDP).
    *   `zot`: OCI-native Docker Registry.
    *   `puller`: Automated image syncing service.
    *   `aptmirror` / `ppamirror`: Local repositories for Debian/Ubuntu.
*   **Stage 4 (Apps):**
    *   `alertcenter`: Alert management and on-call response at `alertcenter.aiursoft.com`.
    *   `manhours`, `wiki`, `www`: Static or lightweight web apps.
    *   `uptimekuma`: External monitoring of the other two boxes.

## CorpHome contact alerts

The `stage4/stacks/corphome` stack enables AlertCenter integration using `CORPHOME_ALERTCENTER_API_KEY`. Supply a dedicated CorpHome application key with **create incident** permission through the deployment's existing secret substitution mechanism; do not commit the key. Configure the application's sev2 notification route and responder access in AlertCenter.

Deploy the CorpHome version containing contact-alert migrations before applying this stack configuration. New contact submissions are queued durably, including while delivery is disabled; pre-integration contacts are not backfilled. The app sends sev2 incidents asynchronously, retries with stable report IDs, and leaves follow-up/resolution manual. Verify one valid test submission creates one incident and reaches the intended channel. The application defaults to disabled outside this stack; if delivery must be paused here, set `GlobalSettings__AlertCenter_Enabled=false` in the stack because environment values override UI settings.

After supplying the key in the deployment environment file and updating this repository on the Global node, deploy only the CorpHome stack from the repository root:

```bash
sudo bash deploy.sh --stage 4 --filter corphome
```

## 🚀 Deployment

```bash
# On a fresh Global VPS (e.g., Voxihost):
git clone https://gitlab.aiursoft.cn/aiursoft/bash-app.git
cd bash-app/Boxes/BoxForGlobal
sudo bash deploy.sh
```
