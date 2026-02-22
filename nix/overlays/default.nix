final: prev: {
  bbrew = prev.callPackage ../pkgs/bbrew.nix { };

  llm-agents = prev.llm-agents // {
    # happy-coder bundles artifacts that can stall in Darwin strip/fixup.
    happy-coder = prev.llm-agents.happy-coder.overrideAttrs (_: {
      dontStrip = true;
    });
  };
}
