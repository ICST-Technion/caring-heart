abstract class AuthServiceI {
  Future<bool> isUserRemembered();
  Future<String?> signInWithEmailPassword(String email, String password);
  Future<String> signOut();
}
