# Tightener

## Preliminary Set Up

## Mac

In the Finder, right-click `./install.command`, and select 'Open'.

This updates your `~/.zshenv` and `~/.profile`

Modify `${TIGHTENER_SYSCONFIG_ROOT}editFile` to use your preferred text editor

Start a new Terminal window and run 

```
copyConfig
```

to create a customized copy of `Config/config.ini` in `${TIGHTENER_SYSCONFIG_ROOT}`

Run

```
editConfig
```

to edit the config

## Linux

In a Terminal window, run `./install.command`. 

This updates your `~/.bashrc` and `~/.profile`.

Modify `${TIGHTENER_SYSCONFIG_ROOT}editFile` to use your preferred text editor

Start a new Terminal window and run 

```
copyConfig
```

to create a customized copy of `Config/config.ini` in `${TIGHTENER_SYSCONFIG_ROOT}`

Run

```
editConfig
```

to edit the config

## Windows

Double-click `install.bat`

Verify it worked by opening a new CMD window and running 

```
ECHO %PATH%
```

Modify `%TIGHTENER_SYSCONFIG_ROOT%editFile.bat` to use your preferred text editor

Start a new CMD window and run 

```
copyConfig
```

to create a customized copy of `config.ini` in `%TIGHTENER_SYSCONFIG_ROOT%`

Run

```
editConfig
```

to edit the customized config

