# Watch-list: Containers, deployment, and boot paths

Attach when the diff touches Dockerfiles, compose files, entrypoints, init containers, deployment manifests, CI/CD, build scripts, deploy-time SQL or migrations, or platform-conditional code.

Probe after the coverage table. Confirm the application's contract first; a mismatch with an entry alone is not a finding. Named APIs are leads, not accepted fixes. `verified` closure needs a probe of the property; report a step you cannot run safely as not run. Report `ID: evidence`, a finding, or `ID: n/a`.

- **DP1 Every service boots.** Does each service and one-shot container start with production-shaped configuration, and does some check boot it when the goal or the project's gate requires boot evidence? Static YAML greps and unit tests are not boot evidence. **Verify:** name the test or command that starts each container, or run it.
- **DP2 Entrypoints fit the role.** Do init and one-shot containers override an inherited `ENTRYPOINT` or `CMD`, and is each role's required environment present? **Verify:** inspect the effective entrypoint and environment per service, for example with `docker inspect` or the compose config.
- **DP3 Images are complete and their binaries fit.** Does the runtime stage contain every workspace package and runtime dependency the entrypoint imports? Are copied binaries built for the image's platform and libc, from a reproducible source rather than whatever is on the build host? **Verify:** from a fresh clone, build and run the entrypoint. Check the `COPY` sources, `.dockerignore`, and each copied binary's target (`file`, `ldd`).
- **DP4 Mounts and permissions.** Does startup work as the runtime UID against absent, read-only, empty, and root-owned mounts, without following symlink ancestors out of the mount? **Verify:** run with each mount shape.
- **DP5 One migration gate.** Does every compose profile, entrypoint, and script go through the same migration or schema gate, with no `db push` side doors? Are deploy-time SQL files reviewed as consumers? **Verify:** search every deploy file for migration and schema commands.
- **DP6 Platform-gated code.** Is OS- or architecture-specific code behind conditional compilation, and do the other targets still build? **Verify:** build or type-check the other targets.
- **DP7 Assumed resources are provisioned.** Are the resources the code assumes (projects, buckets, namespaces, networks) created by a provisioning path? **Verify:** boot against a fresh environment.
