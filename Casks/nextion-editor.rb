cask "nextion-editor" do
  version "1.68.1"
  sha256 "7daa9dbcf9b41c55ab5d487c30f87511f838113bb948beda0ac7794cb902988d"

  # 1.68.1 -> "nextion-setup-v1-68-1.exe"
  url "https://nextion.tech/download/nextion-setup-v#{version.dots_to_hyphens}.exe"
  name "Nextion Editor"
  desc "HMI editor for Nextion touch displays (Windows app, run under Wine)"
  homepage "https://nextion.tech/nextion-editor/"

  # Cannot self-update through brew.
  auto_updates false
  # Windows-only .NET 3.5 app, so we need Wine + winetricks to set up the runtime.
  depends_on cask: "wine-stable"
  depends_on formula: "winetricks"
  # ---------------------------------------------------------------------------
  # A dedicated 32-bit Wine prefix under Application Support, so we never touch
  # the user's default ~/.wine. NOTE: the "Wine Stable.app" bin path below is
  # where the CLI lives for the current wine-stable cask — verify it on your
  # machine (ls "/Applications/Wine Stable.app/Contents/Resources/wine/bin")
  # and adjust if the layout differs in your Wine version.
  # ---------------------------------------------------------------------------
  bootstrap = <<~SH
    #!/usr/bin/env bash
    set -euo pipefail

    export WINEPREFIX="$HOME/Library/Application Support/nextion-editor/wineprefix"
    export WINEARCH=win32
    export WINEDLLOVERRIDES="mscoree="   # skip the Mono prompt; we install real .NET 3.5
    export PATH="/Applications/Wine Stable.app/Contents/Resources/wine/bin:$PATH"

    mkdir -p "$WINEPREFIX"
    wineboot --init
    wineserver -w

    # The runtime Nextion Editor requires.
    winetricks -q dotnet35

    # Run the (MSI-based) installer. Silent flags are unreliable for this
    # bootstrapper, so it runs interactively — click through the wizard once,
    # keeping the default install path (C:\\Program Files\\Nextion Editor).
    wine "$INSTALLER_EXE"
  SH

  launcher = <<~SH
    #!/usr/bin/env bash
    export WINEPREFIX="$HOME/Library/Application Support/nextion-editor/wineprefix"
    export WINEARCH=win32
    export PATH="/Applications/Wine Stable.app/Contents/Resources/wine/bin:$PATH"
    exec wine "$WINEPREFIX/drive_c/Program Files/Nextion Editor/Nextion Editor.exe"
  SH

  plist = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>CFBundleExecutable</key><string>nextion-editor</string>
        <key>CFBundleName</key><string>Nextion Editor</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleSignature</key><string>NEXT</string>
        <key>NSHighResolutionCapable</key><true/>
      </dict>
    </plist>
  XML

  depends_on :macos

  # Drop the launcher into /Applications.
  app "Nextion Editor.app"
  # Create the prefix, install .NET, run the installer.
  installer script: {
    executable:   "bootstrap.sh",
    must_succeed: true,
  }

  # Build a thin .app wrapper + the bootstrap script in the staged dir.
  preflight do
    bin = "#{staged_path}/Nextion Editor.app/Contents/MacOS"
    res = "#{staged_path}/Nextion Editor.app/Contents/Resources"
    FileUtils.mkdir_p bin
    FileUtils.mkdir_p res

    File.write "#{bin}/nextion-editor", launcher
    FileUtils.chmod 0755, "#{bin}/nextion-editor"
    File.write "#{res}/Info.plist", plist

    # Bake the resolved installer path into the bootstrap script.
    script = bootstrap.sub("$INSTALLER_EXE",
                           "#{staged_path}/nextion-setup-v#{version.dots_to_hyphens}.exe")
    File.write "#{staged_path}/bootstrap.sh", script
    FileUtils.chmod 0755, "#{staged_path}/bootstrap.sh"
  end

  uninstall delete: "~/Library/Application Support/nextion-editor"

  zap trash: "~/Library/Application Support/nextion-editor"
end
