# OkDocker - Image builder

Dockerfiles have defects.

1. You can't control build container runtime options, and thus can't mount volumes at buildtime (for example, for domain specific caching purpose, as in .deb downloads, compilations, .whl files ...).

2. You can't have precise control on what happens on what layer, and usually, you can see a "lot of layer" trend where it's not really necessary.

3. It tends to be slow unless everything is already cached.


OkDocker is one way to avoid Dockerfiles.
