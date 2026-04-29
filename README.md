# homebrew-carbide

Homebrew tap for the Carbide Network storage provider node. The formula
builds `carbide-node` from source, installs the `carbide-provider`,
`carbide-discovery`, and `carbide-client` binaries, writes a default
provider configuration, and wires up a launchd service so the provider
runs in the background on boot.

## Production install (the one users run)

```sh
brew tap chaalpritam/carbide https://github.com/chaalpritam/homebrew-carbide
brew install --HEAD chaalpritam/carbide/carbide-node
brew services start carbide-node
```

`--HEAD` builds from the latest commit on `chaalpritam/carbide-node`'s
`master` branch. Once a tagged release exists, drop `--HEAD` to install
the stable tarball pinned in `Formula/carbide-node.rb`.

The provider then runs under launchd as the current user and rejoins
the network on every reboot.

## Working on the formula locally

If you're editing `Formula/carbide-node.rb` itself, iterate against
your on-disk clone — no need to push to GitHub between attempts.

```sh
# One-time: create a local tap inside Homebrew's prefix
brew tap-new chaalpritam/carbide

# Each iteration: copy the formula in and reinstall
cp Formula/carbide-node.rb "$(brew --repo chaalpritam/carbide)/Formula/"
brew uninstall carbide-node 2>/dev/null
brew install --HEAD chaalpritam/carbide/carbide-node
```

`brew --repo chaalpritam/carbide` resolves to the on-disk tap directory
(usually `$(brew --prefix)/Library/Taps/chaalpritam/homebrew-carbide`).
Anything you `cp` there is what `brew install` actually consumes.

### Lint and audit before opening a PR

```sh
brew style Formula/carbide-node.rb
brew audit --new-formula --strict --online Formula/carbide-node.rb
brew test carbide-node    # runs the formula's `test do` block
```

`--online` exercises the URL/SHA in the `stable do` block; it will
warn until a real tagged tarball is in place.

### Cutting a release

1. Tag and push a release on `chaalpritam/carbide-node` (e.g. `v1.1.0`).
2. Update `version` and `sha256` inside `stable do` of
   `Formula/carbide-node.rb` to point at the new tarball.
3. `brew audit --strict --online` to confirm.
4. Commit and push to `chaalpritam/homebrew-carbide`.
5. `brew install chaalpritam/carbide/carbide-node` (without `--HEAD`)
   should now resolve to the new release.

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
