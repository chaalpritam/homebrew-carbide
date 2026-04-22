# homebrew-carbide

Homebrew tap for the Carbide Network storage provider node. The formula
builds `carbide-node` from source, installs the `carbide-provider`,
`carbide-discovery`, and `carbide-client` binaries, writes a default
provider configuration, and wires up a launchd service so the provider
runs in the background on boot.

## Quick start (Mac mini)

```sh
brew tap chaalpritam/carbide https://github.com/chaalpritam/homebrew-carbide
brew install --HEAD chaalpritam/carbide/carbide-node
brew services start carbide-node
```

The provider then runs under launchd as the current user and rejoins
the network on every reboot.

### Tap from a local path

If you want to install straight from a clone on disk (for example,
while developing the formula):

```sh
brew tap-new chaalpritam/carbide
cp Formula/carbide-node.rb "$(brew --repo chaalpritam/carbide)/Formula/"
brew install --HEAD chaalpritam/carbide/carbide-node
```

## What gets installed

| Path                                 | Purpose                          |
| ------------------------------------ | -------------------------------- |
| `$(brew --prefix)/bin/carbide-*`     | `carbide-provider`, `carbide-discovery`, `carbide-client` |
| `$(brew --prefix)/etc/carbide/provider.toml` | Provider configuration        |
| `$(brew --prefix)/var/carbide/storage`       | Default storage root          |
| `$(brew --prefix)/var/log/carbide/`          | Provider logs                 |

## Configure before starting

Edit `$(brew --prefix)/etc/carbide/provider.toml` to set your storage
allocation, price, and region, then start or restart the service:

```sh
brew services restart carbide-node
```

## Managing the provider

```sh
brew services start carbide-node     # start
brew services stop  carbide-node     # stop
brew services restart carbide-node   # apply config changes
brew services list | grep carbide    # show status
carbide-provider status --endpoint http://localhost:8080
```

Logs:

```sh
tail -f "$(brew --prefix)/var/log/carbide/provider.out.log"
tail -f "$(brew --prefix)/var/log/carbide/provider.err.log"
```

## Uninstall

```sh
brew services stop carbide-node
brew uninstall carbide-node
brew untap chaalpritam/carbide
```

Storage, logs, and config under `$(brew --prefix)/var/carbide` and
`$(brew --prefix)/etc/carbide` remain; remove them manually when you
no longer need the data.

## License

MIT
