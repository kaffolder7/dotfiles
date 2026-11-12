# 1Password SSH and CLI

The Brewfile installs the desktop app and `1password-cli`. The desktop app
supplies the SSH agent; installing `op` alone does not start it.

## Enable the integrations

On each Mac, open and unlock 1Password:

1. Open **Settings > Developer**.
2. Enable **Use the SSH Agent** and **Integrate with 1Password CLI**.
3. In **Settings > General**, enable **Keep 1Password in the menu bar** and
   **Start at login**.
4. Enable Touch ID if desired. Keep the normal authorization prompts.

These steps follow the official [SSH guide](https://developer.1password.com/docs/ssh/get-started/)
and [CLI guide](https://developer.1password.com/docs/cli/get-started/).
An organization policy may control access to these settings.

## SSH configuration

The managed configuration uses 1Password's documented macOS socket:

```sshconfig
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

It includes 1Password's bookmark configuration first, then OrbStack, Colima,
and `~/.ssh/config.local` before the final defaults. Each include starts in a
`Host *` context so an included host block cannot restrict the next include.

For existing bookmarks, enable **Settings > Developer > SSH Agent > Advanced >
Generate SSH config files with bookmarked hosts**. 1Password owns
`~/.ssh/1Password/config` and its public-key files. Do not edit those generated
files. See [SSH Bookmarks](https://developer.1password.com/docs/ssh/bookmarks/).

By default, keys come from the Personal, Private, or Employee vault. If a key
lives elsewhere, use a local `~/.config/1Password/ssh/agent.toml` following the
[agent configuration guide](https://developer.1password.com/docs/ssh/agent/config/).
This repository does not broaden access to every vault.

For a particular host, `IdentityFile` can select a **public** key alongside
`IdentitiesOnly yes` in `~/.ssh/config.local`. Keep private keys in 1Password.
Do not enable `IdentitiesOnly yes` globally without selecting public keys.

## Verify

In a fresh terminal:

```sh
op --version
op signin
op whoami
ssh -G github.com | rg '^identityagent '
dot doctor --auth
```

`op signin` should use the desktop authorization flow. Run `op whoami` in that
same terminal session. `dot doctor --auth` performs both steps. Do not put your password
or Secret Key in dotfiles. A Secret Key prompt usually means direct sign-in was
selected instead of desktop integration.

To inspect available SSH keys locally:

```sh
SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ssh-add -l
```

This temporary assignment is needed because `ssh-add` does not read
`IdentityAgent`. The dotfiles do not globally replace `SSH_AUTH_SOCK` or enable
agent forwarding.

Test an existing connection, such as `ssh -T git@github.com`. GitHub reports
successful authentication but exits with status 1 because it provides no shell;
read the message.

## Optional Git signing

SSH authentication and commit signing are separate. Existing signing settings
are preserved. The installer does not select a signing key.

Use 1Password's **Configure Commit Signing** workflow and place personal settings
in `~/.gitconfig.local`. On macOS the helper is normally
`/Applications/1Password.app/Contents/MacOS/op-ssh-sign`. Register the public
signing key with your Git provider.

Follow the official [Git signing guide](https://developer.1password.com/docs/ssh/git-commit-signing/).
