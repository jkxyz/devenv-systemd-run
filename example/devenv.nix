{ pkgs, lib, config, inputs, ... }:

{
  systemd-run.enable = true;

  processes.hello.exec = "echo Hello World";

  services.postgres.enable = true;
}
