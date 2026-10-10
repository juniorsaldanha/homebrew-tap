cask "visionft" do
  version "00.03.00.01"
  sha256 :no_check

  url "https://files.fueltech.com.br/visionft/visionft_mac.dmg"
  name "FuelTech Vision"
  desc "Configuration and datalogger software for FuelTech FT470/FT700 ECUs"
  homepage "https://www.fueltech.com.br/pages/software"

  livecheck do
    url :homepage
    regex(/visionft_mac\.dmg.*?Vers[ãa]o:\s*(\d+(?:\.\d+)+)/im)
  end

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "VisionFT.app"

  zap trash: [
    "~/Library/Application Support/FuelTech/FuelTech Vision",
    "~/Library/Caches/FuelTech/FuelTech Vision",
  ]
end
