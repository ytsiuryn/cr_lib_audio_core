require "spec"
require "json"

require "../src/suggestion"

describe "Suggestion JSON Serialization/Deserialization" do
  it "correctly deserializes Suggestion from JSON" do
    suggestion = Suggestion.from_json(File.read("spec/data/suggestion22.json"))

    # Проверка полей Suggestion
    suggestion.app.should eq OnlineDB::MUSICBRAINZ
    suggestion.similarity.should eq 0.845_384_615_384_615_4

    # Проверка вложенного Release
    release = suggestion.r
    release.title.should eq "Black Holes and Revelations"
    release.total_discs.should eq 1
    release.discs.size.should eq 1
    release.total_tracks.should eq 12
    release.tracks.size.should eq 12

    # Проверка флагов
    release.origin.should eq ReleaseOrigin::STUDIO
    release.remake.should eq ReleaseRemake::REMASTERED
    release.repeat.should eq ReleaseRepeat::REISSUE
    release.status.should eq ReleaseStatus::OFFICIAL
    release.type.should eq ReleaseType::ALBUM

    # Проверка discs
    release.discs.size.should eq 1
    disc = release.discs[0]
    disc.num.should eq 1
    disc.fmt.media.should eq Media::CD
    disc.fmt.attrs.should contain "Digital"
    disc.fmt.attrs.should contain "Media"
    disc.ids[DiscIdType::DISC_ID].should eq "12345"

    # Проверка tracks
    track = release.tracks[0]
    track.position.should eq "01"
    track.title.should eq "Take a Bow"
    track.ainfo.duration.should eq 275_000
    track.record.ids[RecordIdType::MUSICBRAINZ].should eq "cccc851d-9214-4d24-9df6-e45f62664dbc"

    # Проверка publishing
    release.issues.size.should eq 2
    release.issues.ancestor.year.should eq 2006
    lbl = release.issues.actual.labels[0]
    lbl.name.should eq "Warner Bros. Records"
    lbl.catnos.should contain "12345"
    lbl.notes.should contain "test_notes"
    release.issues.actual.countries.should contain "XW"
    release.issues.actual.notes.should contain "test_notes"
    release.issues.actual.year.should eq 2009

    release.genres.should contain "rock"
    release.ids.size.should eq 4
    release.ids[ReleaseIdType::MUSICBRAINZ].should eq "aefcf53b-5980-463b-b03d-a6c8da6a9432"
    release.notes.should contain "test"
    release.unprocessed["test"].should eq "unprocessed"

    # Проверка pictures
    release.pictures.size.should eq 1
    picture = release.pictures[0]
    picture.pict_type.should eq PictType::COVER_FRONT
    picture.notes.should contain "some notes"
    picture.url.should eq "http://mysite/1.gif"
    picture.md.width.should eq 500
    picture.md.mime.should eq "image/jpeg"
    picture.md.colors.should eq 23000

    # Проверка actors и roles
    release.actors.size.should eq 13
    release.actors["Matt Bellamy"][OnlineDB::MUSICBRAINZ].should eq "00fc124e-6645-4530-8d0b-7def83c5ee25"
    release.roles["Muse"].should eq Set{"performer"}
  end

  it "correctly serializes Suggestion to JSON" do
    # Создаем тестовый объект Suggestion
    suggestion = Suggestion.new
    suggestion.app = OnlineDB::MUSICBRAINZ
    suggestion.similarity = 0.845_384_615_384_615_4

    # Заполняем вложенный Release
    release = suggestion.r
    release.title = "Album Title"

    # Добавляем диск
    disc = Disc.new(1)
    disc.fmt.media = Media::CD
    disc.fmt.attrs << "HDCD"
    disc.ids[DiscIdType::DISC_ID] = "123456789"
    release.discs << disc

    # Добавляем трек
    track = Track.new("01", 0)
    track.title = "Track Title"
    track.ainfo = AudioInfo.new(duration: 237_000)
    track.record.ids[RecordIdType::ISRC] = "USABC1234567"
    release.tracks << track

    # Добавляем publishing
    edition = Issue.new
    label = Label.new("Label Name")
    label.catnos << "ABC-123"
    label.ids[OnlineDB::DISCOGS] = "12345"
    edition.labels << label
    edition.year = 2020
    release.issues.actual = edition

    # Добавляем картинку
    picture = PictureInAudio.new(PictType::COVER_FRONT)
    picture.url = "http://example.com/cover.jpg"
    picture.md.width = 500
    picture.md.height = 500
    release.pictures << picture

    # Добавляем актора
    release.actors["Artist Name"] = IDs.new
    release.actors["Artist Name"][OnlineDB::DISCOGS] = "123456"
    release.add_role("Artist Name", "performer")

    # Сериализуем в JSON
    json = suggestion.to_json

    # Проверяем ключевые поля в JSON
    json.should contain %("app":"MUSICBRAINZ")
    json.should contain %("similarity":0.8453846153846154)
    json.should contain %("title":"Album Title")
    json.should contain %("media":"CD")
    json.should contain %("duration":237000)

    # Десериализуем обратно и проверяем целостность
    parsed_suggestion = Suggestion.from_json(json)
    parsed_suggestion.r.title.should eq "Album Title"
    parsed_suggestion.r.tracks[0].title.should eq "Track Title"
  end
end
