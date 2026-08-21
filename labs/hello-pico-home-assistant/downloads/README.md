# Downloads — Hello Pico on Home Assistant

These files ship the graphical ControlSurface layer for the approved
`labs/hello-pico-on-manifold/` runtime. The Home Assistant integration
here reads declared runtime state and asserts one OperatorIntent by
delegating to the approved Python CLI (`bin/pico` from the academy
repository, subcommand `runtime`). It never bypasses Kubernetes,
Manifold, Wrangler, or the Python CLI.

## Files

- `configuration.yaml` — Home Assistant configuration snippet. Merge its
  four top-level keys (`command_line`, `shell_command`, `input_button`,
  `automation`) into your `configuration.yaml`.
- `hello-pico-ha-phase.sh` — command_line sensor helper. Delegates to
  `pico runtime inspect` and prints just the Pico engine Pod phase.
- `event.json` — the same one-event payload the underlying
  `labs/hello-pico-on-manifold/` lab ships. Kept here byte-identical so
  the two lab paths remain honest about the single event on the wire.
- `verify.sh` — automatable shape verification for this lab.

## Home Assistant runtime requirements

The `command_line` sensor and `shell_command` both spawn processes
inside the Home Assistant container. To keep the delegation honest:

- The `pico` executable (from `bin/pico` at the academy repository
  root) MUST be on the `PATH` visible to the Home Assistant container.
- A `kubeconfig` pointing at the same minikube cluster the
  `hello-pico-on-manifold` lab deployed MUST be visible to the `pico`
  process (typically by mounting `~/.kube/config` into the HA
  container).
- The helper script is expected at `/config/hello-pico/hello-pico-ha-phase.sh`
  inside the HA container (adjust the sensor `command:` path if you
  install it elsewhere).

Any operator setup that satisfies these three requirements is fine.
The lab does not prescribe a specific HA installation shape (HA OS,
Container, Supervised, or Core) because that choice does not change
what runs on the Kubernetes side, which remains the declared truth.
