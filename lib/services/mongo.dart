import 'package:mongo_dart/mongo_dart.dart';

class MongoDBService {
  static final MongoDBService _instance = MongoDBService._internal();

  late Db _db;
  bool _connected = false;

  factory MongoDBService() {
    return _instance;
  }

  MongoDBService._internal();

  Future<void> connect() async {
    _db = await Db.create(
        'YOU_MONGO_URI');
    await _db.open();
    _connected = true;
  }

  Future<void> close() async {
    await _db.close();
    _connected = false;
  }

  Future<List<Map<String, dynamic>>> getData(String collectionName) async {
    if (!_connected) {
      throw StateError('Not connected to the database');
    }

    var collection = _db.collection(collectionName);
    var cursor = collection.find();
    var data = <Map<String, dynamic>>[];

    await cursor.forEach((document) {
      data.add(Map<String, dynamic>.from(document));
    });

    return data;
  }

  Future<List<Map<String, dynamic>>> getDatByWhere(
      String collectionName, value) async {
    if (!_connected) {
      throw StateError('Not connected to the database');
    }

    final query = where.eq('key', value).sortBy('createdAt', descending: true);

    var collection = _db.collection(collectionName);
    var cursor = collection.find(query);
    var data = <Map<String, dynamic>>[];

    await cursor.forEach((document) {
      data.add(Map<String, dynamic>.from(document));
    });

    return data;
  }
}
