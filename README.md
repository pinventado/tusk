# TUSK Image Builder

This repository is a focused build and packaging repo for a shared CSUF teaching container image.

It keeps only the pieces needed to:

- define the package set for the image;
- build an Ubuntu LTS-based container with TUSK tooling;
- and publish the result to your own GitHub Container Registry namespace.

## What to edit

- `packages/base.txt` is the canonical package list.
- `mkdockerimage.sh` controls the Ubuntu release, target image name, and GHCR destination.
- `quickinstall.sh` is the in-image bootstrap script that installs the package set.

## Quick start

1. Clone this repo.
2. Edit `packages/base.txt` if you want to add or remove packages.
3. Build the image:

```bash
IMAGE_OWNER=YourOrg \
IMAGE_NAME=26-resolute-small-tusk \
./mkdockerimage.sh
```

4. Confirm the image is available locally.
5. Push it to GHCR.

## Build trigger

The repository includes a GitHub Actions workflow that builds the image on demand or when you push a tag that starts with `image-`.

That means normal commits do not rebuild the image. To start a build, either:

1. use the `workflow_dispatch` button in GitHub Actions, or
2. push a tag such as `image-2026-07-24`.

## Release commands

From a local clone of this fork, the exact commands for a tag-triggered build are:

```bash
git tag image-2026-07-24
git push origin image-2026-07-24
```

If you want to delete and recreate the tag locally before pushing it again:

```bash
git tag -d image-2026-07-24
git push origin :refs/tags/image-2026-07-24
```

## Notes

- The default build targets Ubuntu 26.04 LTS, codename `resolute`.
- The package list is copied into the build rootfs so the image build does not depend on this repository being public.
- If you need a different image name or namespace, set `IMAGE_OWNER` and `IMAGE_NAME` before running the build script.

## Building another image

If another instructor wants to create their own image:

1. Fork this repo.
2. Update the package list.
3. Adjust the image owner/name in `mkdockerimage.sh` or pass them as environment variables.
4. Run the build script from the repo root.

For a more detailed walkthrough, see `docs/build-image.md`.
