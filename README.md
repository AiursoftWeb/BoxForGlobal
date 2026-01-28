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
    *   `manhours`, `wiki`, `www`: Static or lightweight web apps.
    *   `uptimekuma`: External monitoring of the other two boxes.

## 🚀 Deployment

```bash
# On a fresh Global VPS (e.g., Voxihost):
git clone https://gitlab.aiursoft.cn/aiursoft/bash-app.git
cd bash-app/Boxes/BoxForGlobal
sudo bash deploy.sh
```
