cask "pico-key-manager" do
  version "0.2.0"
  sha256 "a6dbf8063f62c47ced56a45e61f68c6bbdc163e7bc84ec52809f664dc6054887"

  url "https://github.com/juniorsaldanha/picokeys-app/releases/download/v#{version}/Pico.Key.Manager_#{version}_universal.dmg"
  name "Pico Key Manager"
  desc "Manage Pico FIDO, OpenPGP and HSM security keys"
  homepage "https://github.com/juniorsaldanha/picokeys-app"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Pico Key Manager.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/Pico Key Manager.app"],
        writable_paths: ["Pico Key Manager.app"],
        writable_base:  :appdir
  end

  # Not ~/.pico-key-manager: it holds flash backups and the secure-boot signing key.
  zap trash: [
    "~/Library/Caches/io.github.picokeymanager",
    "~/Library/WebKit/io.github.picokeymanager",
  ]

  caveats <<~EOS
    Pico Key Manager isn't code-signed (no paid Apple Developer account
    behind this tap yet), so this cask clears the Gatekeeper quarantine
    bit on install. If you ever see "Apple could not verify Pico Key
    Manager is free of malware", run:
      xattr -dr com.apple.quarantine "/Applications/Pico Key Manager.app"

    Your keys' flash backups and recovery files stay in ~/.pico-key-manager
    after uninstalling (even with --zap); delete them yourself if wanted.
  EOS
end
