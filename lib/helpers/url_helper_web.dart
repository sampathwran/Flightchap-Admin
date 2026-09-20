// ignore: avoid_web_libraries_in_flutter
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
