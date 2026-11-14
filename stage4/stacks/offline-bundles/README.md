# AnduinOS offline update publisher

One worker builds cumulative Resolute/amd64 bundles every 48 hours and publishes
them to the dedicated R2 bucket. It has no HTTP endpoint or website dependency.
Each release group keeps three published batches; retired objects have a 24-hour
deletion grace. See the [publisher documentation](https://github.com/AiursoftWeb/anduinosofflinebundles/blob/master/docs/automation.md).

## First deployment

Prepare these directories under `/swarm-vol/anduinos-offline-bundles`:

- `data`: writable by UID/GID 10001, for schedules, archives and build evidence.
- `signing`: mode 0700, owned by 10001, containing the existing production GnuPG
  private key. Restore it from the controlled MS backup when moving hosts.
- `inputs`: read-only to the worker, containing the authenticated Ubuntu and
  AnduinOS public archive keyrings, genuine 2.0.0/2.0.4 baseline metadata, and
  `keys/bundle-signing.gpg`.

The public signing key is available at
<https://offline-update-packages.anduinos.com/sign-cert.gpg>. Its SHA-256 is
`4aee607db52c652290045b0b77c30d62adecff7bf3f6d801a66d38f9db5693df`, and its
OpenPGP fingerprint is `8F083DFE22EEC13D5FCB525E1EBE8FD7C3DA8DF4`.
The updater package checks the same SHA-256 when building. The startup command
checks the public key and requires the existing private key; it never generates
or replaces a signing identity. Do not regenerate it on an empty mount.

Set only `OFFLINE_BUNDLES_R2_ACCESS_KEY` and `OFFLINE_BUNDLES_R2_SECRET_KEY` in
private `.env.prod`. The token is restricted to `anduinos-offline-updates`.
The endpoint, bucket, schedule and public key identity are reviewed in Compose.
The JSON environment value is written to a private temporary file solely because
the CLI accepts a settings-file argument; it contains no credentials.

Before enabling the stack, use the published image to run `automate --once`
with the same settings, mounts and resource limits. Verify the uploaded bundle
and catalog, and measure disk, memory and build duration. `--once` respects the
persisted schedule: the long-running worker then waits until the next due run.
Do not publish test-signed archives or enable other release groups without their
real baselines and installation/reboot acceptance.

Synchronize the image with the existing Puller, then deploy through the normal
Box stage 4 flow with filter `offline-bundles`. The stage 4 preamble also checks
registry login and copies the existing ClickHouse configuration files; the
filter only selects business stacks. Shepherd updates the image normally.
A single replica, local state lock, stop-first updates and a 120-second stop grace
preserve pending work during restarts. The worker uses up to 1 CPU and 2 GiB RAM.

## Signing key lifecycle

The production key was initialized once using GnuPG inside the published image,
on an empty private signing volume, with networking disabled. Its private bytes
stay on Global and in the MS backup; only the exported binary public key is in R2.
The key has no automatic expiry and is not rotated by routine builds. A deliberate
rotation requires coordinated source review, new updater trust and old-client
compatibility planning. Never silently replace `sign-cert.gpg`.

Stop only this stack when pausing publication. Preserve the signing and data
volumes; a later restart resumes the same schedule and unfinished archive.
