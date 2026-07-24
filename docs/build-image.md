# Building the Image

This document contains the actual build and publish instructions for the TUSK image.

## What this repo contains

Keep the repo focused on the image build path:

- `mkdockerimage.sh`
- `quickinstall.sh`
- `packages/base.txt`
- `README.md`
- `LICENSE.md`
- `docs/build-image.md`

## Build flow

The image build works like this:

1. `mkdockerimage.sh` creates a fresh Ubuntu root filesystem with `debootstrap`.
2. The script copies `quickinstall.sh` and `packages/base.txt` into that root filesystem.
3. `quickinstall.sh` installs the package set, including `gh`, `curl`, and the C++ toolchain.
4. The root filesystem is imported as a Docker image.
5. The image is tagged and pushed to your GHCR namespace.

## Local build

From the repository root:

```bash
IMAGE_OWNER=YourOrg \
IMAGE_NAME=26-resolute-small-tusk \
./mkdockerimage.sh
```

Useful defaults:

- Ubuntu codename: `resolute`
- image owner: derived from your Git remote, or `mshafae` as a fallback
- image name: derived from the repo name and Ubuntu codename

Before the push step runs, make sure you are logged in to GHCR:

```bash
docker login ghcr.io
```

If you are building for your own organization, the pushed image will look like:

```text
ghcr.io/YourOrg/YourImage:latest
```

## GitHub web app build

You can start the build without using the command line:

1. Open the repository on GitHub.
2. Click **Actions**.
3. Select the **Build and Publish TUSK Image** workflow.
4. Click **Run workflow**.
5. Choose the branch to run from, if prompted.
6. Fill in the optional inputs if you want to override the image owner, image name, or Ubuntu codename.
7. Click **Run workflow** again to start the job.

GitHub only shows the **Run workflow** button for workflows that use `workflow_dispatch`.

## GitHub web app tag build

The same workflow also runs when you push a tag that starts with `image-`.

If you want to create that tag from the GitHub web app:

1. Open the repository on GitHub.
2. Click **Releases**.
3. Click **Draft a new release**.
4. In the **Choose a tag** box, type a tag such as `image-2026-07-24`.
5. Choose the branch or commit to tag.
6. Publish the release.

That creates the tag in the repository and triggers the workflow because the workflow listens for `image-*` tag pushes.

## Tag build from git

If you are using the command line, the equivalent tag build is:

```bash
git tag image-2026-07-24
git push origin image-2026-07-24
```

To delete and recreate the tag locally:

```bash
git tag -d image-2026-07-24
git push origin :refs/tags/image-2026-07-24
```

## Editing the package list

Edit `packages/base.txt` when you want to add or remove tools from the image.

Keep the package list small and intentional.

## When to rebuild

Rebuild the image whenever you change:

- the package list
- the base Ubuntu release
- the default image owner or image name
- the bootstrap script
