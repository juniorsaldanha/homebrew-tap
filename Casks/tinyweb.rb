cask "tinyweb" do
  version "27.3.0,130"
  sha256 "d597a5961e80acb5c0926031bfa5c64ffbe2b8145a78bcd955177da55185967a"

  url "https://files.tinyweb.so/macos/#{version.csv.second}/TinyWeb.dmg"
  name "TinyWeb"
  desc "Tiny HTTP request client"
  homepage "https://tinyweb.so/"

  livecheck do
    url "https://tinyweb.so/osx/version.xml"
    strategy :sparkle
  end

  auto_updates true
  depends_on macos: :monterey

  app "TinyWeb.app"

  zap trash: [
    "~/Library/Application Support/com.tableplus.TinyWeb",
    "~/Library/Caches/com.tableplus.TinyWeb",
    "~/Library/HTTPStorages/com.tableplus.TinyWeb",
    "~/Library/Preferences/com.tableplus.TinyWeb.plist",
    "~/Library/Saved Application State/com.tableplus.TinyWeb.savedState",
  ]
end
