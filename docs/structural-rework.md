# Structural Rework

Infrastructure work is becoming burdensome. The architecture of this flake configuration is far too complex and bloated as it stands right now (as of 2026-10-09). New features are
difficult for me to add by myself without the use of AI assistance, which is the exact opposite of what was intended when I designed the dual-export system and other quirks of this
flake's architecture.

I have a few ideas about different structures that could work, but I'm not sure yet which one would result in the ultimate goal: making the NixOS system administrator's life easier
by simplifying and expediting processes like adding new hosts, creating new users, assigning permissions to certain users, etc.

Ideally, `flake.nix` should be pretty simple and should contain easy-to-read, easy-to-write syntax. The goal of the top-level `flake.nix` file is simply to connect the hosts and their
users and set sensible defaults that a given admin or user is still able to override with their own preferences.

Brainstorm w/ incomplete sentences & free-flow thought:

- Pull plumbing out into a different flake (like `flake-wizard`, but rewritten for the new structure)
    - Plumbing enables the following:
        - easy creation of `roles`, `types`, etc. with custom options definitions and their corresponding configurations
        - easy creation & assignment of users, hosts, programs, packages, etc.
        - helper functions & templates
    - The ultimate goal is to make it as simple as possible to add new users, hosts, features, etc. while retaining maximum flexibility
        - Examples:
            - Admin wants to add a new program to the package list, but only for Wizards and only on machines with type `laptop` or `desktop`
                - The plumbing should make this as easy as possible to do without requiring a bunch of `lib.mkIf` or `lib.attrs` wiring in the file that adds the new program
    - Conditional logic should be braindead-easy to implement on the admin's side at all times

- Nested `flake.nix` files?
    - The top-level flake connects the fleet together
    - Each machine has its own flake
    - Each user has their own flake
    - Allows for separate repositories in the case that one user wants their configuration to be private while another wants to use theirs in their portfolio (?)
    - Enables certain inputs to only be needed for flake evaluation if the input is actually used on the given machine (?)
        - example: host `artemis` doesn't use the `medialib` input because user `ash` is only assigned to `hephaestus`, but `nix flake check` breaks when run from
        `artemis` because the `medialib` input points to a directory that only exists on `hephaestus`
    - Is this possible?
