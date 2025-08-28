import 'package:upgrader/upgrader.dart';

class MyCustomUpgraderMessages extends UpgraderMessages {
  @override
  String get buttonTitleIgnore => 'Ignore';
  @override
  String get buttonTitleLater => 'Later';
  @override
  String get buttonTitleUpdate => 'Update Now';
  @override
  String get prompt => 'A new version of the app is available. Would you like to update?';
  @override
  String get title => 'Update Available';
}