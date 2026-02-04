.PHONY: install update doctor switch

install:
	./install.sh --brew

update:
	brew bundle --file=Brewfile
	brew upgrade

doctor:
	./bin/dot-doctor

# Nix/HM route
switch-macmini:
	home-manager switch --flake .#macmini

switch-mbp:
	home-manager switch --flake .#mbp
```

---

### 14. **Ghostty Config: Use Conditional Includes**

Your Ghostty config has `config-file = ?config.local` which is good, but consider also checking for host-specific configs:
```
config-file = ?config.local
config-file = ?config.$(hostname -s)
