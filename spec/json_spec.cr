require "json"
require "spec"

require "../src/track/composition"
require "../src/track/record"
require "../src/release/props"
require "../src/release/disc"
require "../src/id"
require "../src/suggestion"
require "../src/picture"

it "JSON global test" do
  # # TODO: добавить в треках и укрупненных признанках количественные оценки после оптимизации
  # content = File.read("spec/data/suggestion22.json")
  # sug = Suggestion.from_json(content)
  # content2 = sug.to_json
  # sug2 = Suggestion.from_json(content2)
  # content3 = sug2.to_json
  # sug.r.optimize
  # r = sug.r
  # sug2.r.optimize
  # content3.should eq content2
  # sug.app.should eq OnlineDB::MUSICBRAINZ
  # sug.similarity.should eq 0.8453846153846154
  # # assert r.roles == r2.roles
  # r.actors.size.should eq 13
  # d = r.discs[0]
  # d.fmt.attrs.should eq ["Digital", "Media"]
  # d.fmt.media.should eq Media::DIGITAL
  # d.ids.should eq Hash{DiscIdType::DISC_ID => "12345"}
  # d.num.should eq 1
  # r.genres.should eq ["rock", "alternative rock"]
  # r.ids.size.should eq 4
  # # assert r.roles == r2.roles
  # # assert r.actors == r2.actors
  # r.notes.should eq Notes{"test"}
  # pm = r.pictures[0].md
  # r.pictures[0].notes.should eq Notes{"some notes"}
  # r.pictures[0].pict_type.should eq PictType::COVER_FRONT
  # r.pictures[0].url.should eq "http://mysite/1.gif"
  # pm.color_depth.should eq 16
  # pm.colors.should eq 23000
  # pm.height.should eq 500
  # pm.mime.should eq "image/jpeg"
  # pm.width.should eq 500
  # r.pub_ancestor.year.should eq 2006
  # p = r.pub
  # p.countries.should eq ["XW"]
  # la = p.labels[0]
  # la.catnos.should eq Set{"12345"}
  # la.ids.should eq Hash{OnlineDB::MUSICBRAINZ => "c595c289-47ce-4fba-b999-b87503e8cb71"}
  # la.name.should eq "Warner Bros. Records"
  # la.notes.should eq Notes{"test_notes"}
  # p.notes.should eq Notes{"test_notes"}
  # p.year.should eq 2009
  # r.release_origin.should eq 0
  # r.release_remake.should eq 0
  # r.release_repeat.should eq 0
  # r.release_status.should eq ReleaseStatus::OFFICIAL
  # r.release_type.should eq ReleaseType::ALBUM
  # r.title.should eq "Black Holes and Revelations"
  # r.total_discs.should eq 1
  # r.total_tracks.should eq 12
  # t = r.tracks[0]
  # t.position.should eq "01"
  # t.title.should eq "Take a Bow"
  # t.ids.should eq IDs{OnlineDB::MUSICBRAINZ => "29fab063-5ca9-30df-82a6-c3807e22b898"}
  # t.notes.should eq Notes{"some notes"}
  # t.unprocessed.should eq Hash{"test" => "unprocessed"}
  # t.ainfo.avg_bitrate.should eq 1750
  # t.ainfo.channels.should eq 2
  # t.ainfo.samplerate.should eq 44100
  # t.ainfo.samplesize.should eq 16
  # t.finfo.fname.should eq "test_track_name"
  # t.finfo.fsize.should eq 100500
  # t.finfo.mtime.should eq 100500100
  # t.ainfo.duration.seconds.should eq 275
  # t.ainfo.duration.microseconds.should eq 466000
  # # assert t.roles == t2.roles
  # # assert t.record.roles == t2.record.roles
  # # TODO: восстановить строку ниже!
  # # t.record.ids.should eq == RecordIDs{RecordIdType::MUSICBRAINZ => "cccc851d-9214-4d24-9df6-e45f62664dbc"}
  # t.record.moods.should eq Moods{Mood::CALM}
  # t.record.notes.should eq Notes{"test_notes"}
  # c = t.composition
  # # assert c.roles == c2.roles
  # c.ids.should eq CompositionIDs{CompositionIdType::ISWC => "12345"}
  # c.notes.should eq Notes{"test_notes"}
  # c.lyrics.is_synced.should be_true
  # c.lyrics.lng.should eq "en"
  # c.lyrics.text.should eq "bla-bla"
  # r.unprocessed.should eq Unprocessed{"test" => "unprocessed"}
end
