#!/usr/bin/env python3
"""Homebrew bootstrap and reversible, per-file dotfile activation."""
import argparse
import datetime
import json
import os
from pathlib import Path
import platform
import re
import shlex
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
NIX_PATTERN = re.compile(r"/nix/|\.nix-profile/|hm-session-vars|nix-daemon\.sh")


def exists(path):
    return path.exists() or path.is_symlink()


def nix_link(path):
    return path.is_symlink() and (
        str(path.resolve()).startswith("/nix/") or "/nix/" in os.readlink(path)
    )


def run(args, **kwargs):
    print("+ " + shlex.join(str(a) for a in args), flush=True)
    return subprocess.run([str(a) for a in args], check=True, **kwargs)


class Activation:
    """Back up bytes and original links; restore originals on activation errors."""

    def __init__(self, state, dry_run=False):
        self.state = state
        self.dry_run = dry_run
        self.backup = None
        self.records = []
        self.created_dirs = []

    def mkdir(self, path):
        if self.dry_run or path.is_dir():
            return
        self.mkdir(path.parent)
        path.mkdir(mode=0o700)
        self.created_dirs.append(path)

    def ensure_backup(self):
        if self.backup is None:
            self.mkdir(self.state / "backups")
            self.backup = Path(tempfile.mkdtemp(
                prefix=datetime.datetime.now().strftime("%Y%m%d-%H%M%S-"),
                dir=self.state / "backups"))

    def remember(self, dst, copy_contents=True):
        self.ensure_backup()
        index = str(len(self.records))
        record = {"path": str(dst), "original": None, "content": None}
        if exists(dst):
            original = self.backup / (index + ".original")
            content = self.backup / (index + ".content")
            # Copy file contents before moving the original symlink. Socket links
            # have metadata only; broken links retain their original target.
            if copy_contents and dst.is_dir():
                shutil.copytree(dst, content, symlinks=False, ignore_dangling_symlinks=True)
                record["content"] = str(content)
            elif copy_contents and dst.is_file():
                shutil.copy2(dst, content, follow_symlinks=True)
                content.chmod(0o600)
                record["content"] = str(content)
            if dst.is_symlink():
                record["link"] = os.readlink(dst)
            shutil.move(str(dst), original)
            record["original"] = str(original)
        self.records.append(record)
        self.save_manifest()

    def save_manifest(self):
        (self.backup / "manifest.json").write_text(json.dumps(self.records, indent=2) + "\n")

    def link(self, src, dst, copy_contents=True):
        if dst.is_symlink() and os.readlink(dst) == str(src):
            return
        print("link {} -> {}".format(dst, src))
        if not self.dry_run:
            self.mkdir(dst.parent)
            self.remember(dst, copy_contents)
            dst.symlink_to(src)

    def write(self, dst, content, mode=0o600):
        if dst.is_file() and not dst.is_symlink() and dst.read_text() == content:
            return
        print("write " + str(dst))
        if not self.dry_run:
            self.mkdir(dst.parent)
            self.remember(dst)
            dst.write_text(content)
            dst.chmod(mode)

    def retire(self, dst):
        if not exists(dst):
            return
        print("retire " + str(dst))
        if not self.dry_run:
            self.remember(dst)

    def rollback(self):
        for record in reversed(self.records):
            dst = Path(record["path"])
            if dst.is_symlink() or dst.is_file():
                dst.unlink()
            elif dst.is_dir():
                shutil.rmtree(dst)
            if record["original"]:
                shutil.move(record["original"], dst)
        for directory in reversed(self.created_dirs):
            try:
                directory.rmdir()
            except OSError:
                pass


def clean_profile(text):
    """Remove only the known previous bootstrap; preserve unrelated local code."""
    text = re.sub(
        r"(?m)^if \[ -e [^\n]*(?:nix-daemon\.sh|hm-session-vars\.sh)[^\n]*\]; then\n"
        r"[ \t]*\.[^\n]*\nfi\n?", "", text)
    lines = []
    for line in text.splitlines():
        if line.strip().startswith("#"):
            continue
        if "brew shellenv" in line or line.strip() == 'export PATH="$HOME/.local/bin:$PATH"':
            continue
        lines.append(line)
    result = "\n".join(lines).strip()
    if NIX_PATTERN.search(result):
        raise RuntimeError("Unrecognized Nix reference in local startup configuration; review before activation.")
    return result + "\n" if result else ""


def clean_git(text):
    # The two previously generated gh helper forms are known, not arbitrary code.
    text = re.sub(
        r'(?m)^(\s*helper\s*=\s*)["!]?(?:/nix/[^"\n ]+|[^"\n ]*\.nix-profile/[^"\n ]+)'
        r'/\.?gh(?:-wrapped)? auth git-credential"?\s*$',
        r'\1!gh auth git-credential', text)
    # A migrated root config must not recursively include its new destination.
    text = re.sub(r'(?m)^\s*path\s*=\s*"?~/.gitconfig.local"?\s*$', "", text)
    if NIX_PATTERN.search(text):
        raise RuntimeError("Unrecognized Nix reference in Git configuration; review before activation.")
    return text


def paths(home):
    def xdg(name, default):
        value = Path(os.environ.get(name, str(home / default))).expanduser()
        if not value.is_absolute():
            raise RuntimeError(name + " must be an absolute path")
        return value
    return (
        xdg("XDG_CONFIG_HOME", ".config"),
        xdg("XDG_STATE_HOME", ".local/state"),
        xdg("XDG_BIN_HOME", ".local/bin"),
    )


def choose_brew():
    for candidate in (Path("/opt/homebrew/bin/brew"), Path("/usr/local/bin/brew")):
        if candidate.is_file():
            return candidate
    return None


def install_dependencies(brew, vscode):
    if brew is None:
        raise RuntimeError("Install Homebrew from https://brew.sh, then rerun this command.")
    env = os.environ.copy()
    prefix = brew.parent.parent
    env["PATH"] = "{}:{}:/usr/bin:/bin:/usr/sbin:/sbin".format(prefix / "bin", prefix / "sbin")
    env["HOMEBREW_NO_AUTO_UPDATE"] = "1"
    # Dependency failure must precede all activation.
    for manifest in [ROOT / "Brewfile"] + ([ROOT / "Brewfile.vscode"] if vscode else []):
        run([brew, "bundle", "--file=" + str(manifest), "--no-upgrade"], env=env)
    # Use an isolated config directory to install runtimes before linking configs.
    # Installed tools remain in the normal mise data directory.
    with tempfile.TemporaryDirectory(prefix="dotfiles-mise-") as temp:
        config = Path(temp) / "config.toml"
        shutil.copy2(ROOT / "xdg/mise/config.toml", config)
        runtime_env = env.copy()
        runtime_env.update(MISE_CONFIG_DIR=temp, MISE_CONFIG_FILE=str(config))
        run([prefix / "bin/mise", "install"], env=runtime_env, cwd=temp)
        # --version in Happy 1.2.6 continues into authentication/session startup.
        run([prefix / "bin/mise", "exec", "--", "happy", "--help"],
            env=runtime_env, cwd=temp, stdout=subprocess.DEVNULL)
        happy = subprocess.check_output(
            [prefix / "bin/mise", "where", "npm:happy"], env=runtime_env, cwd=temp, text=True).strip()
        native = Path(happy) / "node_modules/happy/tools/unpacked"
        if not all((native / name).is_file() for name in ("rg", "difft", "ripgrep.node", "happy-capability")):
            raise RuntimeError("Happy's native tools are missing. Run mise install --force npm:happy using xdg/mise/config.toml.")
    run([prefix / "bin/uv", "python", "install", "3.14"], env=env)
    # Preserve working uv defaults; create defaults only when absent.
    local_bin = Path(os.environ.get("XDG_BIN_HOME", str(Path.home() / ".local/bin")))
    if not exists(local_bin / "python") and not exists(local_bin / "python3"):
        run([prefix / "bin/uv", "python", "install", "--default", "3.14"], env=env)


def activation_actions(home, host, prefix, vscode):
    config, state, bindir = paths(home)
    actions = []

    def link(src, dst, copy_contents=True):
        actions.append(("link", Path(src), Path(dst), copy_contents))

    def write(dst, content):
        actions.append(("write", Path(dst), content))

    def retire(dst):
        actions.append(("retire", Path(dst)))

    def append_local(dst, content):
        if not content.strip():
            return
        previous = dst.read_text() if dst.is_file() else ""
        write(dst, content.rstrip() + "\n\n" + previous)

    # Read and validate local overrides before performing any writes.
    root_git = home / ".gitconfig"
    local_git = home / ".gitconfig.local"
    if root_git.is_file() and root_git.resolve() != ROOT / "home/.gitconfig" and not nix_link(root_git):
        previous = clean_git(local_git.read_text()) if local_git.is_file() else ""
        write(local_git, clean_git(root_git.read_text()).rstrip() + "\n\n" + previous)
    elif local_git.is_file():
        cleaned = clean_git(local_git.read_text())
        if cleaned != local_git.read_text():
            write(local_git, cleaned)
    old_xdg_git = config / "git/config"
    if nix_link(old_xdg_git):
        retire(old_xdg_git)

    for name in (".zshenv", ".zprofile", ".zshrc"):
        old = home / name
        if old.is_file() and old.resolve() != ROOT / "home" / name and not nix_link(old):
            append_local(home / (name + ".local"), clean_profile(old.read_text()))
        local = home / (name + ".local")
        if local.is_file() and NIX_PATTERN.search(local.read_text()):
            raise RuntimeError("Nix reference in {}; review before activation.".format(local))

    old_ssh = home / ".ssh/config"
    if old_ssh.is_file() and old_ssh.resolve() != ROOT / "home/.ssh/config" and not nix_link(old_ssh):
        previous = old_ssh.read_text()
        if NIX_PATTERN.search(previous):
            raise RuntimeError("Nix reference in local SSH config; review before activation.")
        # Strip self-includes so the preserved local file cannot include itself.
        previous = re.sub(r"(?m)^Include .*config\.local.*\n?", "", previous)
        append_local(home / ".ssh/config.local", previous)

    write(config / "dotfiles/host", host + "\n")
    if vscode or (config / "dotfiles/vscode").exists():
        write(config / "dotfiles/vscode", "enabled\n")
    for name in (".gitconfig", ".zshenv", ".zprofile", ".zshrc"):
        link(ROOT / "home" / name, home / name)
    link(ROOT / "home/.ssh/config", old_ssh)
    for name in ("zsh/zshrc.d", "zsh/.p10k.zsh", "bat/config", "fd/ignore",
                 "ripgrep/ripgreprc", "direnv/direnv.toml", "ghostty/config",
                 "ghostty/themes/One Dark", "mise/config.toml"):
        link(ROOT / "xdg" / name, config / name)
    # gh writes config itself. Keep a writable copy and never touch hosts.yml.
    gh = config / "gh/config.yml"
    if not gh.exists() or nix_link(gh):
        write(gh, (ROOT / "xdg/gh/config.yml").read_text())
    nano = (ROOT / "xdg/nano/nanorc").read_text()
    write(config / "nano/nanorc", nano + 'include "{}/share/nano/*.nanorc"\n'.format(prefix))
    for name in ("dot", "dot-doctor"):
        link(ROOT / "bin" / name, bindir / name)
    link(home / "Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock",
         home / ".1password/agent.sock")
    link(prefix / "opt/openjdk@25/libexec/openjdk.jdk",
         home / "Library/Java/JavaVirtualMachines/openjdk-25.jdk", copy_contents=False)
    # Only retire links that still belong to Home Manager.
    for old in (config / "direnv/lib/hm-nix-direnv.sh", home / ".cache/.keep",
                state / ".keep", home / "Library/Fonts/.home-manager-fonts-version"):
        if nix_link(old):
            retire(old)
    # Docker mutates this file. Some hosts still have the Home Manager link.
    docker = Path(os.environ.get("DOCKER_CONFIG", str(home / ".docker"))) / "config.json"
    if nix_link(docker):
        write(docker, docker.read_text())
    # Preserve an existing prompt that happens to be a Nix symlink.
    if nix_link(home / ".p10k.zsh"):
        write(home / ".p10k.zsh", (home / ".p10k.zsh").read_text())
    # Never write through an ancestor directory owned by Nix.
    for operation, *args in actions:
        dst = args[1] if operation == "link" else args[0]
        if str(dst.parent.resolve()).startswith("/nix/"):
            raise RuntimeError("Parent directory resolves into Nix: " + str(dst.parent))
    if str(state.resolve()).startswith("/nix/"):
        raise RuntimeError("State directory resolves into Nix: " + str(state))
    return actions, state / "dotfiles"


def apply_actions(actions, state, dry_run=False):
    tx = Activation(state, dry_run)
    try:
        for operation, *args in actions:
            getattr(tx, operation)(*args)
    except BaseException:
        if not dry_run:
            tx.rollback()
        raise
    if tx.backup:
        print("Recovery files: " + str(tx.backup))
    return tx


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", choices=("mbp", "macmini"))
    parser.add_argument("--brew", action="store_true", help="install packages and runtimes before activation")
    parser.add_argument("--packages-only", action="store_true", help="install dependencies without activating dotfiles")
    parser.add_argument("--with-vscode", action="store_true", help="include optional VS Code bundle")
    parser.add_argument("--dry-run", action="store_true", help="print actions without writing or installing")
    parser.add_argument("--yes", action="store_true", help="skip the activation confirmation")
    args = parser.parse_args()
    if args.packages_only:
        args.brew = True
    if platform.system() != "Darwin":
        parser.error("This setup supports macOS.")
    home = Path.home()
    config, _, _ = paths(home)
    host_file = config / "dotfiles/host"
    host = args.host or (host_file.read_text().strip() if host_file.exists() else None)
    if host not in ("mbp", "macmini"):
        parser.error("Specify --host mbp or --host macmini on the first run.")
    brew = choose_brew()
    prefix = brew.parent.parent if brew else Path("/opt/homebrew")
    vscode = args.with_vscode or (config / "dotfiles/vscode").exists()
    if args.packages_only:
        if args.dry_run:
            print("Would install Brewfile packages, mise tools, and uv Python 3.14.")
        else:
            install_dependencies(brew, vscode)
        return
    actions, state = activation_actions(home, host, prefix, vscode)
    if args.dry_run:
        if args.brew:
            print("Would install Brewfile packages, mise tools, and uv Python 3.14.")
        apply_actions(actions, state, True)
        return
    if "/.codex/worktrees/" in str(ROOT):
        parser.error("Activate from the durable dotfiles checkout, not a temporary Codex worktree.")
    if not args.yes:
        answer = input("Activate dotfiles for {} with backups? [y/N] ".format(host))
        if answer.lower() not in ("y", "yes"):
            return
    if args.brew:
        install_dependencies(brew, vscode)
    elif brew is None:
        parser.error("Homebrew is required. Install it from https://brew.sh first.")
    apply_actions(actions, state)
    print("Open a new terminal, then run: dot doctor")
    print("Finish 1Password app integration: " + str(ROOT / "docs/1password.md"))
    print("Nix is still installed. Follow docs/migration.md after verification.")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, subprocess.CalledProcessError) as error:
        print("Installation stopped: " + str(error), file=sys.stderr)
        sys.exit(1)
