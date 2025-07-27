require "spec"
require "../src/core/picture"

describe PictureInAudio do
  it "#file_reference?" do
    PictureInAudio.file_reference?("https://content.discogs.com/media/The-Fix-Vengeance.jpeg").should be_true
    PictureInAudio.file_reference?("folder.jpg").should be_true
    PictureInAudio.file_reference?("abcde").should be_false
  end
end
