# Building Your Own TUSK Image

This document explains how to turn this repository into a small, maintainable image build repo for Ubuntu 26.04 LTS.

## What this repo keeps

Keep only the files needed to define, build, and publish the image:

- `mkdockerimage.sh`
- `quickinstall.sh`
- `packages/base.txt`
- `README.md`
- `LICENSE.md`
- `docs/build-image.md`

Everything else in the upstream TUSK repo is optional for the image build path and can be removed from a focused fork.

## Build flow

The build process is:

1. `mkdockerimage.sh` creates a fresh Ubuntu root filesystem with `debootstrap`.
2. The script copies `quickinstall.sh` and `packages/base.txt` into that root filesystem.
3. `quickinstall.sh` installs the package set, including `gh`, `curl`, and the C++ toolchain.
4. The root filesystem is imported as a Docker image.
5. The image is tagged and pushed to your GHCR namespace.

## Required tools

- Docker
- `debootstrap`
- `sudo`
- a GitHub account with permission to push packages to GHCR

## Build steps

From the repository root:

```bash
IMAGE_OWNER=CPP-Refresher-Su2026 \
IMAGE_NAME=26-resolute-small-tusk \
./mkdockerimage.sh
```

The script defaults to:

- Ubuntu codename `resolute`
- image owner `mshafae`
- image name `tusk-resolute`

Override `IMAGE_OWNER` and `IMAGE_NAME` if you want a different GHCR path.

## Publishing

Before the push step runs, make sure you are logged in to GHCR:

```bash
docker login ghcr.io
```

If you are building for your own organization, the pushed image will look like:

```text
ghcr.io/YourOrg/YourImage:latest
```

## Editing the package list

Edit `packages/base.txt` when you want to add or remove tools from the image.

Keep the package list small and intentional:

- `gh` if you want the workflow to use the GitHub CLI
- `curl` if you want simple API calls in workflows
- the C++ compiler and linting tools needed by the refresher

If a package is only needed for one course or one lab, prefer adding it here rather than restoring the full upstream repo layout.

## When to rebuild

Rebuild the image whenever you change:

- the package list
- the base Ubuntu release
- the default image owner or image name
- the bootstrap script

## Notes for future maintainers

If you fork this repo for another course:

1. Rename the image to match your organization.
2. Update the package list to reflect the tools your labs actually use.
3. Keep the README short and build-oriented.
4. Avoid reintroducing old vagrant or legacy image variants unless you need them again.
