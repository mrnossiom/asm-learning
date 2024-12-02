# ASM Learning

# How to run

Enter a nix shell with `nix develop` to access the required tools.

Using `just`, you can use the following commands to run a sub-project:

- `just run <project>` for an asm sub-project
- `just runc <project>` for a C sub-project

# Sub-projects

- `more_or_less` : the game of the same name

# Setup

You should add a local IDE override to use real tabs. For example, helix is

```toml
[editor]
smart-tab.enable = false
```

