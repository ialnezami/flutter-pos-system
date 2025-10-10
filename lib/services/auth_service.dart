class AuthService {
  static bool _isLoggedIn = false;
  static String? _currentUser;
  
  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUser => _currentUser;
  
  static bool login(String username, String password) {
    if (username == 'admin' && password == 'admin') {
      _isLoggedIn = true;
      _currentUser = username;
      return true;
    }
    return false;
  }
  
  static void logout() {
    _isLoggedIn = false;
    _currentUser = null;
  }
}
