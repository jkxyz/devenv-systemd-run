{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.systemd-run;

  commands = lib.mapAttrsToList (
    name: process:
    (builtins.concatStringsSep " " [
      "systemd-run"
      "--user"
      "--unit=${config.systemd-run.projectName}-${name}"
      "--slice=${config.systemd-run.slice}"
      "--same-dir"
      "--property=SyslogIdentifier=${name}"
      "direnv exec ${config.devenv.root} bash -c '${process.exec}'"
    ])
  ) config.processes;

  devenv-systemd-run = pkgs.writeShellScriptBin "devenv-systemd-run" ''
    TIME=$(date --rfc-3339=seconds)
    ${builtins.concatStringsSep "\n" commands}
    journalctl --user --unit=${config.systemd-run.slice}.slice --follow --no-hostname --since="$TIME"
  '';

in
{
  options = {
    systemd-run = {
      projectName = lib.mkOption {
        type = lib.types.str;

        default = if config.name != null then config.name else builtins.baseNameOf config.devenv.root;
      };

      slice = lib.mkOption {
        type = lib.types.str;
        default = config.systemd-run.projectName;
      };
    };
  };

  config = {
    packages = [ devenv-systemd-run ];
  };
}
