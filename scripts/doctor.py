#!/usr/bin/env python3
"""Check installed dotfiles without reading credentials or changing settings."""
import argparse
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys

from install import ROOT, NIX_PATTERN, choose_brew, paths

TOOLS = (
    "git", "git-lfs", "gh", "op", "b2", "bat", "bbrew", "codex", "curl",
    "direnv", "docker", "ddev", "eza", "fastfetch", "fd", "fzf", "jq",
    "nano", "nvim", "rg", "uv", "mise", "node", "npm", "python3", "java",
    "happy", "mkcert", "repomix", "yt-dlp", "zoxide", "dot",
)


def command(args, env=None):
    try:
        return subprocess.run(args, env=env, capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.TimeoutExpired):
        return None


def active_nix_references(home):
    config, _, bindir = paths(home)
    findings = []
    for key in ("PATH", "JAVA_HOME", "SSL_CERT_FILE", "NIX_SSL_CERT_FILE"):
        if NIX_PATTERN.search(os.environ.get(key, "")):
            findings.append(key + " contains a Nix path")
    for base in (config, bindir, home / "Library/Java/JavaVirtualMachines",
                 home / ".ssh", home / ".1password"):
        if not base.exists():
            continue
        for folder, dirs, files in os.walk(base):
            dirs[:] = [d for d in dirs if d not in {
                ".git", "node_modules", "conversations", "logs", "backups",
            }]
            for name in dirs + files:
                p = Path(folder) / name
                if p.is_symlink() and str(p.resolve()).startswith("/nix/"):
                    findings.append("Nix symlink: " + str(p))
    for p in [home / name for name in (
        ".zshenv", ".zprofile", ".zshrc", ".zlogin", ".zshenv.local",
        ".zprofile.local", ".zshrc.local", ".gitconfig", ".gitconfig.local",
    )] + [config / "git/config", home / ".ssh/config.local", home / ".docker/config.json"]:
        if p.is_symlink() and str(p.resolve()).startswith("/nix/"):
            findings.append("Nix symlink: " + str(p))
        elif p.is_file() and NIX_PATTERN.search(p.read_text(errors="replace")):
            findings.append("Nix reference: " + str(p))
    for p in (home / "Library/LaunchAgents").glob("*.plist"):
        try:
            if NIX_PATTERN.search(str(plistlib.loads(p.read_bytes()))):
                findings.append("Nix launch agent: " + str(p))
        except (OSError, ValueError):
            findings.append("Unreadable launch agent: " + str(p))
    return sorted(set(findings))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--no-nix", action="store_true", help="fail on active user-level Nix dependencies")
    parser.add_argument("--removed", action="store_true", help="also require Nix to be uninstalled")
    parser.add_argument("--auth", action="store_true", help="ask 1Password to verify CLI and agent access")
    args = parser.parse_args()
    failures = []

    def check(passed, label):
        print(("OK   " if passed else "FAIL ") + label, flush=True)
        if not passed:
            failures.append(label)

    home = Path.home()
    config, state, bindir = paths(home)
    check((ROOT / "Brewfile").is_file(), "repository: " + str(ROOT))
    host = config / "dotfiles/host"
    check(host.exists() and host.read_text().strip() in ("mbp", "macmini"), "machine identity")
    for tool in TOOLS:
        found = shutil.which(tool)
        valid = bool(found) and not str(Path(found).resolve()).startswith("/nix/")
        check(valid, tool + ": " + (found or "missing"))
    for p in (home / ".zshenv", home / ".zprofile", home / ".zshrc", home / ".gitconfig",
              home / ".ssh/config", config / "ghostty/config", config / "mise/config.toml"):
        check(p.exists(), "configuration: " + str(p))
    check(state.is_dir() and os.access(state, os.W_OK), "writable XDG state directory")
    check(str(bindir) in os.environ.get("PATH", "").split(os.pathsep), "user bin directory in PATH")
    brew = choose_brew()
    if brew:
        env = dict(os.environ, HOMEBREW_NO_AUTO_UPDATE="1")
        for name in ["Brewfile"] + (["Brewfile.vscode"] if (config / "dotfiles/vscode").exists() else []):
            result = command([str(brew), "bundle", "check", "--no-upgrade", "--file=" + str(ROOT / name)], env)
            check(result is not None and result.returncode == 0, name + " packages installed")
    else:
        check(False, "Homebrew installed")
    ssh = command(["/usr/bin/ssh", "-G", "github.com"])
    socket = home / "Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    check(ssh is not None and ssh.returncode == 0 and
          ("identityagent " + str(socket)) in ssh.stdout,
          "SSH selects 1Password for github.com")
    check(socket.is_socket(), "1Password SSH agent socket available")
    java = command(["/usr/libexec/java_home", "-F", "-v", "25"])
    check(java is not None and java.returncode == 0 and "/nix/" not in java.stdout,
          "macOS Java registry provides Java 25")
    for name, cmd in (("Node", ["node", "--version"]), ("Python", ["python3", "--version"]),
                      ("Happy", ["happy", "--help"]), ("1Password CLI", ["op", "--version"])):
        result = command(cmd)
        check(result is not None and result.returncode == 0, name + " launches")
    happy = command(["mise", "where", "npm:happy"])
    native = Path(happy.stdout.strip()) / "node_modules/happy/tools/unpacked" if happy and happy.returncode == 0 else None
    check(native is not None and all((native / name).is_file() for name in
          ("rg", "difft", "ripgrep.node", "happy-capability")), "Happy native macOS tools installed")
    for finding in active_nix_references(home):
        if args.no_nix or args.removed:
            check(False, finding)
        else:
            print("NOTE " + finding)
    if args.removed:
        check(not Path("/nix/nix-installer").exists() and not Path("/nix/store").exists(),
              "Nix installer and store removed")
        check(not list(Path("/Library/LaunchDaemons").glob("*nix*.plist")), "Nix launch daemons removed")
    if args.auth:
        print("NOTE Approve the 1Password desktop sign-in prompt if shown.", flush=True)
        result = command(["op", "signin"])
        check(result is not None and result.returncode == 0, "1Password desktop sign-in")
        result = command(["op", "whoami"])
        check(result is not None and result.returncode == 0, "1Password CLI authentication")
        result = command(["/usr/bin/ssh-add", "-l"], dict(os.environ, SSH_AUTH_SOCK=str(socket)))
        check(result is not None and result.returncode == 0, "1Password offers SSH keys")
    else:
        print("NOTE Verify desktop CLI integration interactively: dot doctor --auth")
    print("{} required check(s) failed.".format(len(failures)))
    return bool(failures)


if __name__ == "__main__":
    sys.exit(main())
