const fs = require('fs');

const stub = `void setUrl(String url) {}
String getUrl() => '/';
void listenToUrlChanges(Function(String) onUrlChanged) {}
`;

const web = `// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void setUrl(String url) {
  html.window.history.pushState(null, '', url);
}

String getUrl() {
  String hash = html.window.location.hash;
  if (hash.startsWith('#')) {
    hash = hash.substring(1);
  }
  return hash.isEmpty ? '/' : hash;
}

void listenToUrlChanges(Function(String) onUrlChanged) {
  html.window.onPopState.listen((event) {
    onUrlChanged(getUrl());
  });
}
`;

fs.writeFileSync('lib/helpers/url_helper_stub.dart', stub);
fs.writeFileSync('lib/helpers/url_helper_web.dart', web);

let layoutCode = fs.readFileSync('lib/screens/main_layout.dart', 'utf8');

if (!layoutCode.includes('listenToUrlChanges')) {
  layoutCode = layoutCode.replace(
    'super.initState();',
    `super.initState();
    listenToUrlChanges((newUrl) {
      if (newUrl != '/' && newUrl.isNotEmpty) {
        int initialIndex = _routes.entries
            .firstWhere((entry) => entry.value == newUrl, orElse: () => const MapEntry(0, '/dashboard'))
            .key;
        setState(() {
          _selectedIndex = initialIndex;
        });
      }
    });`
  );
  fs.writeFileSync('lib/screens/main_layout.dart', layoutCode);
}
console.log('Updated URL helpers and layout for popstate');
