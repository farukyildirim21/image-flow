// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processing_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProcessingRecordModelAdapter extends TypeAdapter<ProcessingRecordModel> {
  @override
  final int typeId = 0;

  @override
  ProcessingRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProcessingRecordModel()
      ..id = fields[0] as String
      ..type = fields[1] as String
      ..processedAt = fields[2] as DateTime
      ..resultPath = fields[3] as String
      ..originalPath = fields[4] as String?
      ..fileSizeBytes = fields[5] as int
      ..extractedText = fields[6] as String?
      ..thumbnailPath = fields[7] as String?;
  }

  @override
  void write(BinaryWriter writer, ProcessingRecordModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.processedAt)
      ..writeByte(3)
      ..write(obj.resultPath)
      ..writeByte(4)
      ..write(obj.originalPath)
      ..writeByte(5)
      ..write(obj.fileSizeBytes)
      ..writeByte(6)
      ..write(obj.extractedText)
      ..writeByte(7)
      ..write(obj.thumbnailPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessingRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
