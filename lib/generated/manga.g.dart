// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaAdapter extends TypeAdapter<Manga> {
  @override
  final int typeId = 0;

  @override
  Manga read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Manga(
      url: fields[0] as String,
      latestChapter: fields[6] as String,
      title: fields[1] as String,
      rating: fields[2] as String,
      totalChapters: fields[3] as int,
      urlImage: fields[4] as String,
      status: fields[5] as String,
      totalChapterRead: fields[10] as int,
      synopsis: fields[7] as String,
      isFavourite: fields[8] as bool,
      chapters: (fields[9] as List).cast<Chapter>(),
      boxName: fields[11] as String,
      image: fields[12] as Uint8List,
      genres: (fields[13] as List).cast<String>(),
    )
      ..topDown = fields[14] as bool
      ..showUnread = fields[15] as bool
      ..showRead = fields[16] as bool;
  }

  @override
  void write(BinaryWriter writer, Manga obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.totalChapters)
      ..writeByte(4)
      ..write(obj.urlImage)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.latestChapter)
      ..writeByte(7)
      ..write(obj.synopsis)
      ..writeByte(8)
      ..write(obj.isFavourite)
      ..writeByte(9)
      ..write(obj.chapters)
      ..writeByte(10)
      ..write(obj.totalChapterRead)
      ..writeByte(11)
      ..write(obj.boxName)
      ..writeByte(12)
      ..write(obj.image)
      ..writeByte(13)
      ..write(obj.genres)
      ..writeByte(14)
      ..write(obj.topDown)
      ..writeByte(15)
      ..write(obj.showUnread)
      ..writeByte(16)
      ..write(obj.showRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
