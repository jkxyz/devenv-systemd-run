# devenv-systemd-run

Launch [devenv](https://devenv.sh/) processes as transient systemd user units using `systemd-run`.

## Motivation

With many development process managers such as Foreman and Process Compose, I too often find myself having to do manual cleanup after unexpected failures (like `pkill -f postgres`).
I also want to be able to run my dev processes so that they survive editor and terminal crashes.

systemd is super robust at managing processes, and the `systemd-run` command makes it easy to start transient services that can be managed with the usual `systemctl` commands, and monitored using `journalctl`.

## Prerequisites

Currently assumes that you have [`direnv`](https://direnv.net/) installed and an `.envrc` configured to activate the shell.

## Options

* `systemd-run.enable` (`lib.types.bool`)

  Default: `false`
  
  Enable this module. This provides the `devenv-systemd-run` script and configures `devenv up` to use it.

* `systemd-run.useAsProcessManager` (`lib.types.bool`)

  Default: `true`

  If set to `false` then `devenv up` will use the default implementation. The `devenv-system-run` script can still be used.

## Setup

### Importing

#### `devenv.yaml`

Update `devenv.yaml` to include this repo as an input and import it:

```
inputs:
  # ... your inputs here
  devenv-systemd-run:
    url: github:jkxyz/devenv-systemd-run

imports:
  - devenv-systemd-run
```

#### Flakes

Add this repo to your Flake inputs:

```
inputs.devenv-systemd-run.url = "github:jkxyz/devenv-systemd-run";
```

Add the `devenv-systemd-run.devenvModules.devenv-systemd-run` input to your modules:

```
devenv.lib.mkShell {
  inherit inputs pkgs;

  modules = [ 
    devenv-systemd-run.devenvModules.devenv-systemd-run 
    # ... your modules here
  ];
}
```

### Enabling

Once the module is imported, add the option `systemd-run.enable = true` to your config.

## Usage

* Start processes with `devenv up` or `devenv-systemd-run`
* The output of all processes is shown using `journalctl`
* After pressing `Ctrl-C`, the services are still running as systemd units
* View logs of all processes with `journalctl --user --unit=foo.slice`, where foo is the project name
* Restart a single process with `systemctl --user restart foo-app.service`, where app is the name of a process
* Stop all the processes with `systemctl --user stop foo.slice`
