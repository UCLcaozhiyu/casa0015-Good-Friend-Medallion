import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 获取当前用户ID
  String? get currentUserId => _auth.currentUser?.uid;

  // 匿名登录
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Anonymous auth error: $e');
      rethrow;
    }
  }

  // 检查并确保用户已登录
  Future<String> ensureLoggedIn() async {
    if (_auth.currentUser == null) {
      await signInAnonymously();
    }
    return _auth.currentUser!.uid;
  }

  // 登出
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 监听认证状态变化
  Stream<User?> get authStateChanges => _auth.authStateChanges();
} 