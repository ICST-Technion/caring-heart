abstract class AuthServiceI {
  String? name;
  String? uid;
  String? userEmail;
  Future<bool> isUserRemembered();
  Future<String?> signInWithEmailPassword(String email, String password);
  Future<String> signOut();
}
