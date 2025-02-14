import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'firebase_options_dev.dart' as dev;
import 'firebase_options_prod.dart' as prod;

enum Environment {
  development,
  production,
}

class FirebaseConfig {
  static final _log = Logger('FirebaseConfig');
  
  // This will be set during build time
  static const String _buildEnv = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  static Environment get currentEnvironment {
    return _buildEnv == 'production' ? Environment.production : Environment.development;
  }

  static FirebaseOptions get currentConfig {
    _log.info('Current Firebase Environment: $_buildEnv');
    return _buildEnv == 'production' ? prod.firebaseOptions : dev.firebaseOptions;
  }
} 