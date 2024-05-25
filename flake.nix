{
  outputs = { self, ... }: {
    devenvModules.devenv-systemd-run = import ./devenv.nix;
    devenvModules.default = self.devenvModules.devenv-systemd-run;
  };
}
