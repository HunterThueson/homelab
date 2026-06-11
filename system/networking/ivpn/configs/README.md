# IVPN OpenVPN configs

Each `<name>.ovpn` here is referenced from a user's
`userSettings.networking.privacy.vpn.server = "<name>"` field.

## Adding a server

1. Sign in at https://www.ivpn.net/account/login
2. Go to the OpenVPN downloads section and pick a server (e.g. "US, New York")
3. Download the `.ovpn` file
4. Place it here renamed as `<server-slug>.ovpn` (e.g. `us-nyc.ovpn`)
5. Reference it from `flake.nix`:
   `networking.privacy.vpn.server = "us-nyc";`

## Notes

- These files are **not secret** — they contain server hostnames and IVPN's
  CA cert, which IVPN distributes publicly. Commit them to the repo.
- Your account credentials are separate, stored encrypted in
  `system/security/secrets/secrets.yaml` under the `ivpn-auth` key.
- Until a real `.ovpn` is placed here, `us-nyc.ovpn` is a placeholder that
  will let the NixOS build succeed but cause `ivpn.service` to fail at
  runtime (openvpn will refuse the empty config). Replace it before
  running `vpn-up`.
