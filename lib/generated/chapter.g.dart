// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChapterAdapter extends TypeAdapter<Chapter> {
  @override
  final int typeId = 1;

  @override
  Chapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chapter(
      url: fields[0] as String,
      name: fields[1] as String,
      isRead: fields[2] as bool,
      imageUrls: (fields[4] as List).cast<String>(),
      imagePaths: (fields[3] as List).cast<String>(),
      height: (fields[5] as List).cast<int>(),
      width: (fields[6] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Chapter obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isRead)
      ..writeByte(3)
      ..write(obj.imagePaths)
      ..writeByte(4)
      ..write(obj.imageUrls)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.width);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
