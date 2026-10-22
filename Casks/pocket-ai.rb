cask "pocket-ai" do
  version :latest
  sha256 :no_check

  url "https://releases.heypocketai.com/Pocket_universal.dmg"
  name "Pocket"
  desc "AI personal assistant and meeting recorder (desktop beta)"
  homepage "https://heypocket.com/"

  depends_on macos: :ventura

  app "Pocket.app"
end
