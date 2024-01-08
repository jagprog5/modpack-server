# Listener

Listens for get requests on a port and starts up the minecraft server.

To build:

```bash
cargo build --release
```

A systemctl service file is provided. Modify the ExecStart path and install it appropriately.
