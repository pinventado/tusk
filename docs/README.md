# Creating a New Image

This folder explains how to create a new TUSK-based image with the Docker workflow.

## What to copy

Start by copying one of the existing Dockerfiles in `docker/`.

For example:

- copy `docker/26-resolute-small-tusk.Dockerfile` if you want a lean base image
- copy `docker/26-resolute-big-tusk.Dockerfile` if you want the graphics packages too

Rename the new file to match your image, for example:

```text
docker/26-resolute-medium-tusk.Dockerfile
```

## What to change in the Dockerfile

Update the following pieces:

- `org.opencontainers.image.authors`
- `org.opencontainers.image.title`
- `org.opencontainers.image.source`
- `org.opencontainers.image.description`

Then review the `apt-get install` list and add or remove packages for your image.

## What to change in the build script

Open `docker/build_tusk_images.sh` and make sure the script knows about your new Dockerfile name.

The script currently expects a size name such as:

- `small`
- `big`

If you create a new image name, update the script so it maps that size to the new Dockerfile.

## Build flow

The build works like this:

1. GitHub Actions or a local shell calls `docker/build_tusk_images.sh`.
2. The script builds the selected Dockerfile with Buildx.
3. The image is tagged and pushed to GHCR and Docker Hub.

## Local build

From the repository root:

```bash
cd docker
IMAGE_OWNER=YourOrg ./build_tusk_images.sh small
```

If you want the larger image:

```bash
cd docker
IMAGE_OWNER=YourOrg ./build_tusk_images.sh big
```

## GitHub web app build

You can start the build without using the command line:

1. Open the repository on GitHub.
2. Click **Actions**.
3. Select the **Build and Publish TUSK Image** workflow.
4. Click **Run workflow**.
5. Choose the image size, usually `small`.
6. Click **Run workflow** again to start the job.

GitHub only shows the **Run workflow** button for workflows that use `workflow_dispatch`.

## Tag build

The workflow also runs when you push a tag that starts with `image-`.

From the command line, the equivalent tag trigger is:

```bash
git tag image-2026-07-24
git push origin image-2026-07-24
```

To delete and recreate a tag locally:

```bash
git tag -d image-2026-07-24
git push origin :refs/tags/image-2026-07-24
```
