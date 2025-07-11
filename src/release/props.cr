require "../json"

# Статус релиза.
enum ReleaseStatus
  UNKNOWN
  OFFICIAL
  CONTRAFACT
  BOOTLEG
  DEMONSTRATION
  PROMOTION
  SAMPLER
  UPCOMING
  OUTTAKE
end

# Тип релиза.
enum ReleaseType
  UNKNOWN
  SINGLE
  MAXISINGLE
  MINIALBUM
  ALBUM
end

# Причина переиздания альбома.
enum ReleaseRepeat
  UNKNOWN
  REPRESS
  REISSUE
  COMPILATION
  DISCOGRAPHY
  REMAKE
end

# Изменения, внесенные в оригинальную композицию.
enum ReleaseRemake
  UNKNOWN
  REMASTERED
  TRIBUTE
  COVER
  REMIX
end

# Способ и место записи релиза.
enum ReleaseOrigin
  UNKNOWN
  STUDIO
  LIVE
  REHEARSAL
  HOME
  FIELD_RECORDING
  RADIO
  TV
end

json_serializable_enum ReleaseStatus, ReleaseType, ReleaseRepeat, ReleaseRemake, ReleaseOrigin
