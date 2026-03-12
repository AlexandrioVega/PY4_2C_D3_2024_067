import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel {
  @HiveField(0)
  final String? id; 

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String date;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String authorId; 

  @HiveField(6)
  final String teamId;

  @HiveField(7)
  final bool isPublic; 

  LogModel({
    this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
    required this.authorId,
    required this.teamId,
    this.isPublic = false, 
  });

  
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: (map['_id'] as ObjectId?)?.oid, 
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Software',
      authorId: map['authorId'] ?? 'unknown_user', 
      teamId: map['teamId'] ?? 'no_team',
      isPublic: map['isPublic'] ?? false, 
    );
  }

 
  Map<String, dynamic> toMap() {
    return {
      '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'title': title,
      'date': date,
      'description': description,
      'category': category,
      'authorId': authorId,
      'teamId': teamId,
      'isPublic': isPublic,
    };
  }
}