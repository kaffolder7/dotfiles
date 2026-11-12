# Runtimes and Happy

## Node

Homebrew installs mise. The shared configuration defaults to Node 24.
Project `mise.toml`, `.nvmrc`, and `.node-version` select project versions.
Package-manager declarations select npm, pnpm, or Yarn.

```sh
cd /path/to/project
mise install
mise exec -- node --version
```

For a new project, `mise use --pin node@24` records an exact version.
Commit that configuration. The installer does not rewrite other repositories.

The audited `rallly` project uses Node 24 and pnpm; `sleeve` declares Node 26.
Install and check each within its project directory.

Mise shims precede Homebrew's runtime dependencies. For scripts and IDE tasks,
`mise exec -- <command>` makes version selection explicit.
See [mise's Node documentation](https://mise.jdx.dev/lang/node.html).

## Python

Homebrew installs uv. Existing uv installations and virtual environments remain.
New machines get Python 3.14. Default `python` and `python3` commands are created
only if neither already exists.

```sh
cd /path/to/python-project
uv python pin 3.14
uv sync
uv run python --version
```

Use the project's required version. uv reads `.python-version`; an asdf
`.tool-versions` entry is not a uv pin. mise does not manage Python here.

Virtual environments contain machine-specific paths. Rebuild `.venv` locally
from project dependency files. The audit found old Homebrew paths in
`ics-calendar-aggregator`, `ics-calendar-aggregator-lambda`, and
`paprika-ai-grocery-python`; review these when next used.

## Java and Garmin

Homebrew `openjdk@25` supplies `JAVA_HOME` and `java`. The installer registers
the JDK in your user JavaVirtualMachines directory. Existing Java 21 stays.

Check `java -version` and `/usr/libexec/java_home -F -v 25`.
Garmin's SDK Manager installs SDKs separately. The shell selects the newest
versioned SDK directory already present. Verify a representative Connect IQ build.

## Happy

Mise installs the official npm package `happy`, pinned to `1.2.6`. The command
remains `happy`. The Nix packaging and Darwin strip workaround are removed.
Account and pairing data stay in `~/.happy`.

The mise entry permits Happy's own postinstall to unpack its bundled macOS tools.
Dependency build scripts remain disabled. See [mise's npm backend](https://mise.jdx.dev/dev-tools/backends/npm.html).

Check `happy --help`, `happy doctor`, and `happy daemon status`.
Avoid `happy --version` for automated checks: version 1.2.6 prints the version,
then continues into authentication and session startup.
After closing old sessions, use a fresh terminal to restart the old daemon:

```sh
happy daemon stop
happy daemon start
```

Verify the phone connection and your usual agent workflow before removing Nix.
The installer does not restart sessions automatically. Never delete `~/.happy`
as a pairing troubleshooting step.

If this Mac has not been paired, run `happy auth login` interactively and follow
the phone flow. Avoid sharing the output of `happy auth status`; upstream includes
a token preview when authenticated.

To upgrade, review upstream, change the shared mise version, and run
`mise install` from home. Test before committing the bump.

Happy Desktop is not installed. The original CLI receives critical fixes;
new features go to Desktop. See [upstream guidance](https://happy.engineering/guides/terminal/).

## Docker and DDEV

Docker keeps its existing context and credentials. On the MacBook, the active
context is OrbStack. The installer does not start, replace, or recreate containers.

When an existing `$XDG_CONFIG_HOME/ddev/global_config.yaml` is present, the shell
sets `DDEV_XDG_CONFIG_HOME` so current DDEV keeps using that configuration and
project registry. An explicit local value takes precedence. New machines without
that directory use DDEV's normal `~/.ddev` location.
See [DDEV's global configuration directory](https://docs.ddev.com/en/stable/users/usage/architecture/).
