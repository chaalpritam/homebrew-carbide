class CarbideNode < Formula
  desc "Carbide Network storage provider node - earn rewards for contributing storage"
  homepage "https://carbide.network"
  license "MIT"
  version "1.0.0"

  head "https://github.com/chaalpritam/carbide-node.git", branch: "master"

  stable do
    url "https://github.com/chaalpritam/carbide-node/archive/refs/tags/v1.0.0.tar.gz"
    # sha256 is intentionally empty for the initial release; users should install with --HEAD
    # until the first tagged tarball is published.
    sha256 ""
  end

  depends_on "rust" => :build
  depends_on "pkg-config" => :build

  uses_from_macos "llvm" => :build

  def install
    ENV["CARGO_TARGET_DIR"] = buildpath/"target"

    system "cargo", "build", "--release",
                    "--bin", "carbide-provider",
                    "--bin", "carbide-discovery",
                    "--bin", "carbide-client",
                    "--manifest-path", buildpath/"Cargo.toml"

    bin.install "target/release/carbide-provider"
    bin.install "target/release/carbide-discovery"
    bin.install "target/release/carbide-client"

    (etc/"carbide").mkpath
    (var/"carbide/storage").mkpath
    (var/"log/carbide").mkpath

    default_config = etc/"carbide/provider.toml"
    unless default_config.exist?
      default_config.write provider_toml_template
    end
  end

  def provider_toml_template
    <<~EOS
      # Carbide Network storage provider configuration.
      # Edit values below, then restart the service:
      #   brew services restart carbide-node

      [provider]
      name            = "#{ENV.fetch("USER", "mac-mini")}-carbide-provider"
      tier            = "Home"            # Home | Professional | Enterprise
      region          = "NorthAmerica"
      port            = 8080
      storage_path    = "#{var}/carbide/storage"
      max_storage_gb  = 100

      [network]
      discovery_endpoint  = "https://discovery.carbide.network"
      advertise_address   = "127.0.0.1:8080"

      [pricing]
      price_per_gb_month  = 0.005

      [logging]
      level   = "info"
      file    = "#{var}/log/carbide/provider.log"

      [reputation]
      enable_reporting        = true
      health_check_interval   = 300

      # On-chain registration (optional). Leave `registry_address` empty to
      # skip self-publishing to CarbideRegistry. When set, also expose
      # CARBIDE_WALLET_PASSWORD in the service environment so the provider
      # can unlock its wallet and sign the register/update transaction.
      [wallet]
      chain_id            = 421614                         # Arbitrum Sepolia
      rpc_url             = "https://sepolia-rollup.arbitrum.io/rpc"
      registry_address    = ""
      escrow_address      = ""
      usdc_address        = ""
    EOS
  end

  service do
    run [opt_bin/"carbide-provider", "--config", etc/"carbide/provider.toml"]
    keep_alive true
    run_type :immediate
    working_dir var/"carbide"
    log_path var/"log/carbide/provider.out.log"
    error_log_path var/"log/carbide/provider.err.log"
    environment_variables CARBIDE_LOG_FORMAT: "json"
  end

  def caveats
    <<~EOS
      Carbide Network provider node is installed.

      Configuration:   #{etc}/carbide/provider.toml
      Storage root:    #{var}/carbide/storage
      Logs:            #{var}/log/carbide/

      Start the provider as a background service:
        brew services start carbide-node

      Stop or restart:
        brew services stop carbide-node
        brew services restart carbide-node

      Check status manually:
        carbide-provider status --endpoint http://localhost:8080

      Before you start, edit #{etc}/carbide/provider.toml to set:
        * max_storage_gb - how much disk you want to contribute
        * price_per_gb_month - your asking price
        * region - your provider region

      Optional: to self-publish on the on-chain CarbideRegistry set
      `wallet.registry_address` in provider.toml and export the wallet
      password in the service environment:

        launchctl setenv CARBIDE_WALLET_PASSWORD "<your-wallet-password>"
        brew services restart carbide-node
    EOS
  end

  test do
    assert_match "carbide-provider", shell_output("#{bin}/carbide-provider --help")
    assert_match "carbide-discovery", shell_output("#{bin}/carbide-discovery --help")
    assert_match "carbide-client", shell_output("#{bin}/carbide-client --help")
  end
end
