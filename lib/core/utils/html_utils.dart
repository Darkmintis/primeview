import 'package:html_unescape/html_unescape.dart';

final _htmlUnescape = HtmlUnescape();

String htmlDecode(String text) {
  return _htmlUnescape.convert(text);
}
