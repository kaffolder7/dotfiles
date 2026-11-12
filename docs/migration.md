# Migrate an existing Mac

Migrate the MacBook Pro first. Repeat the inventory and checks on the Mac mini.
Do not assume its live state matches the laptop just because the old host
modules were similar.

## 1. Preserve the starting point

The annotated tag `nix-home-manager-final-2026-11-12` contains the last Nix
configuration and the existing Brewfile additions.

Record the machine inventory outside the repository:

```sh
mkdir -p ~/.local/state/dotfiles
chmod 700 ~/.local/state/dotfiles
umask 077
./bin/dot audit > ~/.local/state/dotfiles/before-migration.txt
```

The audit prints paths and package names, not credential values.
The installer backs up replaced configuration when activated. It copies readable
file contents as well as recording original symlinks, so removing the Nix store
does not erase those configuration backups.
The JDK link is saved as link metadata; the installer does not copy an entire
runtime into the configuration backup.

## 2. Give Git ownership of this checkout

On **each** Mac, add this line to `~/Projects/.stignore`:

```text
/Personal/dotfiles
```

The ignore file is local to each Syncthing device. Apply the exclusion to both
devices before distributing changes. Preserve existing patterns. Do not delete
either checkout while it is still being synced.

Use independent Git checkouts at `~/Projects/Personal/dotfiles`. Before updating
the Mac mini, inspect `git status` there and preserve any machine-local edits.

Other project sync remains unchanged. Separately, consider excluding generated
`node_modules` and `.venv` directories and Git metadata from project sync.
Virtual environments should be rebuilt on the machine that uses them.

## 3. Install replacements and activate

From the durable checkout, after bringing it up to the migration commit:

```sh
./install.sh --host mbp --brew --dry-run
./install.sh --host mbp --brew
```

Use `--host macmini` on the other Mac. `--yes` skips only the installer confirmation.
`--packages-only` installs dependencies without activating files and can be used
while reviewing the migration in a temporary worktree.

Installation failures stop before configuration activation. A failed activation
restores replaced files. Homebrew packages and downloaded runtimes are not rolled
back; rerun after fixing the reported problem.

Homebrew may need to update dependencies even with `--no-upgrade`. It may also
need to adopt existing applications. If adoption conflicts with a manually
installed app, resolve that particular app before continuing; do not use
`--force` across the whole Brewfile.

The migration replaces the old shell, Git, SSH, tool-config, and Java links.
Personal Git settings and ordinary startup additions are preserved locally.
Unknown Nix references in personal startup/Git settings stop activation for review.

Do not run another Home Manager switch after activation. It can reclaim these
files. Do not run `home-manager uninstall` after replacement either; its empty
configuration switch can interfere with the migrated shell.

## 4. Verify before uninstalling Nix

Close and reopen your terminal rather than relying on its inherited environment.

```sh
dot doctor --no-nix
dot doctor --auth
git config --show-origin --get user.name
git config --show-origin --get user.email
git config --show-origin --get-all credential.https://github.com.helper
java -version
/usr/libexec/java_home -F -v 25
```

Complete the [1Password checks](1password.md). Confirm your existing GitHub
credentials, LFS, terminal appearance, completion, history, fzf, and zoxide.
Test Docker/DDEV against the existing OrbStack context, without replacing it.

In representative projects, check Node 24, Node 26, pnpm, a uv Python environment,
and a Garmin build if used. See [runtimes](runtimes.md).

Close old Happy sessions, restart its daemon from a fresh terminal, and verify
your phone connection. Keep `~/.happy` and all authentication data.

The user JDK registration should resolve to Homebrew's versioned formula. The
old system-level `openjdk-25.jdk` link may still point to unversioned `openjdk`.
After verifying its existing target, align it if needed:

```sh
sudo ln -sfn "$(brew --prefix openjdk@25)/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk-25.jdk
```

Do not replace an ordinary JDK directory with that command. Preserve Java 21.

## 5. Remove Nix with its own uninstaller

This step is intentionally separate from dotfiles installation. Run it only
after the checks above pass on the machine being migrated.

The MacBook used Determinate Nix Installer 3.15.1. Before removal it had
`/nix/nix-installer` and `/nix/receipt.json`. The supported removal command for
that installation was:

```sh
sudo /nix/nix-installer uninstall
```

Read the interactive removal plan. Do not use `--no-confirm` or delete `/nix`
manually. Keep the installer and receipt in place until it finishes.
See [Determinate's uninstall instructions](https://github.com/DeterminateSystems/nix-installer#uninstalling).

On the Mac mini, check its own installer/receipt first. Never copy the laptop's
receipt to it. If it used another installer, follow that installer's removal
instructions instead.

## 6. Inspect leftovers and reboot

After the uninstaller succeeds, inspect remaining user-level Nix paths:

```sh
ls -ld ~/.nix-profile ~/.nix-defexpr ~/.nix-channels \
  ~/.config/nix ~/.config/home-manager ~/.cache/nix \
  ~/.local/share/nix ~/.local/share/home-manager ~/.local/state/nix \
  ~/.local/state/home-manager ~/.local/state/systems.determinate.detsys-ids-client
```

Retire only confirmed Nix-specific leftovers after preserving anything wanted.
Also inspect `~/Applications/Home Manager Apps` for obsolete Nix-backed wrappers
and `~/Library/Fonts/.home-manager-fonts-version`. Keep the new Homebrew Zed app.

Check that Nix launch daemons and the Nix Store APFS volume are gone. The
uninstaller owns its system changes, including shell hooks and mount setup.
Do not delete `/etc/fstab`, `/etc/synthetic.conf`, or system shell files wholesale.
If it reports incomplete removal, resolve that specific error first.

The MacBook's uninstaller left an inactive launchd registration even after
deleting its plist. Check it with:

```sh
launchctl print system/systems.determinate.nix-installer.nix-hook
```

If it still exists after a successful uninstall, unload that registration with
`sudo launchctl bootout system/systems.determinate.nix-installer.nix-hook`.
A service-not-found response means it is already gone.

Also inspect `/etc/nix`. On the MacBook, only `macos-keychain.crt` remained.
After preserving that file and confirming nothing still uses it, remove that
specific file and use `rmdir` for the now-empty directory. Do not delete an
uninspected configuration directory recursively.

An empty `/nix` directory can remain until reboot even after the APFS volume is
gone. It is a synthetic mount point created by macOS. Once its entry is gone from
`/etc/synthetic.conf` and `/etc/synthetic.d`, reboot removes it. See
`man 5 synthetic.conf`; synthetic entries cannot be deleted while running.

The MacBook's user configuration and profile metadata were archived privately
under `~/.local/state/dotfiles/retired-nix-20261112-161430/`. Its disposable Nix
cache and obsolete Home Manager Zed copy were removed. The Homebrew Zed app and
existing migration backups remain. Post-removal checks passed before reboot.

Reboot, then run:

```sh
dot doctor --removed
dot doctor --auth
```

Keep the migration backup until both Macs have been used successfully.

## Recovery

Activation backups live under `~/.local/state/dotfiles/backups/<timestamp>/`.
The private `manifest.json` maps each destination to its original and content copy.
An activation error restores originals automatically.

Before Nix removal, manual recovery can restore the recorded original links
and files after moving the new links aside. After Nix removal, the content
copies remain readable, but restoring Nix-generated shell scripts does not
restore their missing runtime dependencies. Use the Git tag to inspect old
configuration, not as a promise of machine-level rollback.
