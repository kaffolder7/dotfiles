#!/usr/bin/env python3
"""Print migration inventory without credential values or file contents."""
import json
import os
from pathlib import Path
import platform
import shutil

from doctor import TOOLS, active_nix_references
from install import choose_brew


def main():
    home = Path.home()
    print("Machine:", platform.node(), platform.machine())
    print("Repository:", Path(__file__).resolve().parent.parent)
    print("\nCommand lookup")
    for tool in TOOLS + ("nix", "home-manager"):
        print("{}: {}".format(tool, shutil.which(tool) or "missing"))
    print("\nActive Home Manager-owned paths")
    source = home / ".local/state/nix/profiles/home-manager/home-files"
    if source.exists():
        print("Generation:", source.parent.resolve())
        for folder, dirs, files in os.walk(source):
            for name in dirs + files:
                p = Path(folder) / name
                if p.is_symlink():
                    print(p.relative_to(source))
    print("\nExplicit Homebrew installs")
    brew = choose_brew()
    if brew:
        prefix = brew.parent.parent
        for p in sorted((prefix / "Cellar").glob("*/*/INSTALL_RECEIPT.json")):
            data = json.loads(p.read_text())
            if data.get("installed_on_request"):
                print(p.parent.parent.name, p.parent.name)
        print("Casks:", ", ".join(p.name for p in sorted((prefix / "Caskroom").glob("*"))))
    print("\nNix references")
    for line in active_nix_references(home):
        print(line)
    receipt = Path("/nix/receipt.json")
    if receipt.exists():
        data = json.loads(receipt.read_text())
        print("Installer receipt:", data.get("version"), data.get("planner", {}).get("planner"))
    print("\nAudit only. No settings changed.")


if __name__ == "__main__":
    main()
