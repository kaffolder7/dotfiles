# Roll out to the Mac mini

The MacBook migration has been exercised locally. The Mac mini has not been
accessed, so inventory its live configuration before replacing anything.

## 1. Confirm GitHub is current

The migration commits and archive tag are published on GitHub. If you make
further changes on the MacBook, review `git status` and the commits, then publish
them before updating the Mac mini:

```sh
cd ~/Projects/Personal/dotfiles
git log --oneline origin/main..main
git push origin main
git push origin nix-home-manager-final-2026-11-12
```

The working branch is `homebrew-only-migration`. The permanent MacBook checkout's
`main` branch contains the same migration commits.

## 2. Stop syncing this checkout on the Mac mini

Add `/Personal/dotfiles` to `~/Projects/.stignore` on the Mac mini. Keep its existing
patterns. The MacBook already has this exclusion. Leave other project folders alone.

Do this before updating the checkout. Syncthing's ignore file is local to each
device. Afterward, use Git to transfer dotfiles changes.

## 3. Preserve local work and update

On the Mac mini:

```sh
cd ~/Projects/Personal/dotfiles
git status
git branch --show-current
git diff
```

If there are edits, preserve and review them before continuing. Do not reset or
overwrite them. Once the working tree is clean and any local commits are accounted
for, update with a fast-forward merge:

```sh
git fetch origin --tags
git switch main
git merge --ff-only origin/main
```

If Git refuses the merge, stop and reconcile the divergence. Do not force it.

## 4. Inventory and preview

```sh
umask 077
mkdir -p ~/.local/state/dotfiles
chmod 700 ~/.local/state/dotfiles
./bin/dot audit > ~/.local/state/dotfiles/macmini-before-migration.txt
./install.sh --host macmini --brew --dry-run
```

Check that the preview targets this Mac's home directory and permanent checkout.
Review unexpected Nix dependencies, launch agents, personal shell settings, and
Java registrations. The installer stops if it finds an unknown Nix reference in
startup or Git settings rather than guessing how to translate it.

## 5. Install and activate

```sh
./install.sh --host macmini --brew
```

Use `--with-vscode` only if wanted. The installer backs up files it replaces,
preserves personal Git settings, and keeps Docker and Happy data. If Homebrew
reports an existing-app conflict, resolve that one app and rerun.

Open a fresh terminal. Complete [1Password's per-device setup](1password.md), then:

```sh
dot doctor --no-nix --auth
git config --show-origin --get user.email
docker context show
ddev version
```

Check an existing Git connection, Node projects, Python projects, and the Happy
phone connection. Runtime installation is per machine; run `mise install` inside
Node projects. Rebuild machine-specific Python `.venv` directories from their
dependency files as needed.

## 6. Remove Nix last

Follow [the removal and recovery guide](migration.md#5-remove-nix-with-its-own-uninstaller).
Inspect this Mac's installer and receipt first. Use its supported uninstaller,
review its interactive plan, inspect leftovers, reboot, and run
`dot doctor --removed --auth`.

Keep both the Git archive tag and private activation backups until the new setup
has worked on both Macs.
