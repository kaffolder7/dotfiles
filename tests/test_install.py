import contextlib
import io
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import install


class MigrationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles test ")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name) / "home with spaces"
        self.home.mkdir()
        self.env = patch.dict(os.environ, {
            "HOME": str(self.home),
            "XDG_CONFIG_HOME": str(self.home / "config custom"),
            "XDG_STATE_HOME": str(self.home / "state custom"),
            "XDG_BIN_HOME": str(self.home / "bin custom"),
            "XDG_CACHE_HOME": str(self.home / ".cache"),
            "XDG_DATA_HOME": str(self.home / ".local/share"),
            "DOCKER_CONFIG": str(self.home / ".docker"),
        })
        self.env.start()
        self.addCleanup(self.env.stop)

    def activate(self, dry=False):
        actions, state = install.activation_actions(self.home, "mbp", Path("/opt/homebrew"), False)
        with contextlib.redirect_stdout(io.StringIO()):
            return install.apply_actions(actions, state, dry)

    def test_first_install_then_repeat_is_noop(self):
        first = self.activate()
        self.assertTrue(first.backup.exists())
        self.assertEqual((self.home / ".zshrc").resolve(), install.ROOT / "home/.zshrc")
        self.assertIsNone(self.activate().backup)
        self.assertEqual((self.home / "config custom/dotfiles/host").read_text(), "mbp\n")

    def test_dry_run_creates_nothing(self):
        self.activate(dry=True)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_packages_only_does_not_plan_activation(self):
        with patch.object(install, "activation_actions") as plan, \
             patch.object(install, "install_dependencies") as deps, \
             patch("sys.argv", ["install", "--host", "mbp", "--packages-only"]):
            install.main()
        plan.assert_not_called()
        deps.assert_called_once()

    def test_nix_parent_directory_blocks_before_writing(self):
        config = self.home / "config custom"
        config.symlink_to("/nix/store/old-config")
        with self.assertRaises(RuntimeError):
            self.activate()
        self.assertEqual(list(self.home.iterdir()), [config])

    def test_nix_docker_config_becomes_writable_without_data_loss(self):
        target = self.home / "old-docker.json"
        target.write_text('{"currentContext":"orbstack","auths":{}}\n')
        docker = self.home / ".docker/config.json"
        docker.parent.mkdir()
        docker.symlink_to(target)
        is_nix = install.nix_link
        with patch.object(install, "nix_link", side_effect=lambda p: p == docker or is_nix(p)):
            self.activate()
        self.assertFalse(docker.is_symlink())
        self.assertEqual(docker.read_text(), target.read_text())

    def test_jdk_link_backup_keeps_metadata_without_copying_runtime(self):
        target = self.home / "old-jdk"
        target.mkdir()
        (target / "runtime").write_text("large runtime")
        dst = self.home / "Library/Java/JavaVirtualMachines/openjdk-25.jdk"
        dst.parent.mkdir(parents=True)
        dst.symlink_to(target)
        tx = self.activate()
        record = next(r for r in tx.records if r["path"] == str(dst))
        self.assertIsNone(record["content"])
        self.assertEqual(record["link"], str(target))
        tx.rollback()
        self.assertEqual(dst.resolve(), target.resolve())

    def test_conflict_backup_has_bytes_and_link_metadata(self):
        target = self.home / "old-config"
        target.write_text("original content")
        dest = self.home / "managed"
        dest.symlink_to(target)
        tx = install.Activation(self.home / "state")
        tx.link(install.ROOT / "home/.zshrc", dest)
        self.assertEqual(Path(tx.records[0]["content"]).read_text(), "original content")
        self.assertEqual(tx.records[0]["link"], str(target))
        tx.rollback()
        self.assertEqual(dest.read_text(), "original content")
        self.assertEqual(dest.readlink(), target)

    def test_broken_symlink_is_backed_up(self):
        dst = self.home / "broken"
        dst.symlink_to("/nix/store/missing/config")
        tx = install.Activation(self.home / "state")
        tx.write(dst, "replacement")
        self.assertEqual(tx.records[0]["link"], "/nix/store/missing/config")
        tx.rollback()
        self.assertTrue(dst.is_symlink())
        self.assertFalse(dst.exists())

    def test_failed_activation_rolls_back(self):
        original = self.home / "first"
        original.write_text("keep")
        actions = [("write", original, "changed"), ("unknown_operation",)]
        with self.assertRaises(AttributeError):
            install.apply_actions(actions, self.home / "state")
        self.assertEqual(original.read_text(), "keep")

    def test_personal_git_identity_and_helpers_survive(self):
        (self.home / ".gitconfig").write_text(
            '[user]\n name = Kyle\n email = example@example.com\n'
            '[credential "https://github.com"]\n'
            ' helper = !/Users/kyle/.nix-profile/bin/.gh-wrapped auth git-credential\n'
        )
        self.activate()
        content = (self.home / ".gitconfig.local").read_text()
        self.assertIn("name = Kyle", content)
        self.assertIn("!gh auth git-credential", content)
        self.assertNotIn(".nix-profile", content)
        result = subprocess.check_output(["git", "config", "--global", "--includes", "user.email"], text=True)
        self.assertEqual(result.strip(), "example@example.com")

    def test_nix_store_git_helper_rewritten(self):
        text = '[credential "https://github.com"]\n helper = "/nix/store/abc-gh/bin/gh auth git-credential"\n'
        self.assertIn("!gh auth git-credential", install.clean_git(text))

    def test_existing_local_git_override_wins(self):
        (self.home / ".gitconfig").write_text('[user]\n name = Old\n[include]\n path = ~/.gitconfig.local\n')
        (self.home / ".gitconfig.local").write_text('[user]\n name = Current\n')
        self.activate()
        name = subprocess.check_output(["git", "config", "--global", "--includes", "user.name"], text=True).strip()
        self.assertEqual(name, "Current")

    def test_profile_removes_known_nix_blocks_preserves_local_code(self):
        text = (
            'eval "$(/opt/homebrew/bin/brew shellenv)"\n'
            'if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then\n'
            '  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh\nfi\n'
            'if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then\n'
            '  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"\nfi\n'
            'export PROJECT_SETTING=yes\n'
        )
        self.assertEqual(install.clean_profile(text), "export PROJECT_SETTING=yes\n")

    def test_unknown_nix_reference_blocks_before_writing(self):
        (self.home / ".zprofile").write_text("export CUSTOM_TOOL=/nix/store/custom\n")
        with self.assertRaises(RuntimeError):
            self.activate()
        self.assertEqual(list(self.home.iterdir()), [self.home / ".zprofile"])

    def test_noninteractive_zsh_uses_custom_xdg_and_detaches_nix(self):
        self.activate()
        env = {
            "HOME": str(self.home), "ZDOTDIR": str(self.home),
            "PATH": "/nix/store/old/bin:/usr/bin:/bin",
            "JAVA_HOME": "/nix/store/old-java",
            "SSL_CERT_FILE": "/nix/store/old-cert",
            "XDG_CONFIG_HOME": str(self.home / "config custom"),
            "XDG_STATE_HOME": str(self.home / "state custom"),
            "XDG_BIN_HOME": str(self.home / "bin custom"),
        }
        result = subprocess.run(
            ["/bin/zsh", "-d", "-c", 'print -r -- "$DOTFILES_HOST|$XDG_STATE_HOME|$PATH|${SSL_CERT_FILE:-}"'],
            env=env, capture_output=True, text=True, check=True)
        self.assertEqual(result.stderr, "")
        self.assertIn("mbp|", result.stdout)
        self.assertIn(str(self.home / "state custom"), result.stdout)
        self.assertIn(str(self.home / "bin custom"), result.stdout)
        self.assertNotIn("/nix/", result.stdout)

    def test_existing_docker_and_codex_data_untouched(self):
        for name in (".docker/config.json", ".codex/config.toml", ".happy/settings.json"):
            dst = self.home / name
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_text("private data")
        self.activate()
        for name in (".docker/config.json", ".codex/config.toml", ".happy/settings.json"):
            self.assertEqual((self.home / name).read_text(), "private data")

    def test_dependency_failure_never_activates(self):
        (self.home / ".zshrc").write_text("original shell\n")
        with patch.object(install, "ROOT", Path("/durable/repo")), \
             patch.object(install, "activation_actions", return_value=([], self.home / "state")), \
             patch.object(install, "install_dependencies", side_effect=RuntimeError("download failed")), \
             patch.object(install, "apply_actions") as apply, \
             patch("sys.argv", ["install", "--host", "mbp", "--brew", "--yes"]):
            with self.assertRaises(RuntimeError):
                install.main()
        apply.assert_not_called()
        self.assertEqual((self.home / ".zshrc").read_text(), "original shell\n")

    def test_ssh_config_keeps_local_hosts_and_agent(self):
        sshdir = self.home / ".ssh"
        sshdir.mkdir()
        (sshdir / "config").write_text("Host test-host\n  HostName example.invalid\n")
        self.activate()
        self.assertIn("test-host", (sshdir / "config.local").read_text())
        # OpenSSH expands ~ from the OS account, not HOME. Replace it in the test fixture.
        fixture = self.home / "ssh-test-config"
        fixture.write_text((sshdir / "config").read_text().replace("~/", str(self.home) + "/"))
        result = subprocess.check_output(["ssh", "-G", "-F", str(fixture), "test-host"], text=True,
                                         stderr=subprocess.DEVNULL)
        self.assertIn("hostname example.invalid", result)
        self.assertIn("2BUA8C4S2C.com.1password/t/agent.sock", result)


if __name__ == "__main__":
    unittest.main()
