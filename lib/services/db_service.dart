import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<bool> loginUser(String email, String password) async {
    final query =
        await _db
            .collection('users')
            .where('email', isEqualTo: email)
            .where('password', isEqualTo: password)
            .get();

    return query.docs.isNotEmpty;
  }

  static Future<bool> registerUser(
    String email,
    String password,
    String name,
  ) async {
    final existing =
        await _db.collection('users').where('email', isEqualTo: email).get();

    if (existing.docs.isNotEmpty) return false;

    await _db.collection('users').add({
      'email': email,
      'password': password,
      'name': name,
    });

    return true;
  }
}
