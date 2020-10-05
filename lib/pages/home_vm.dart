import 'package:rxdart/rxdart.dart';

import 'helper.dart';

class HomeViewModel {
  final solving = BehaviorSubject<bool>();
  final _uploadImage = BehaviorSubject<bool>();
  final _uploadError = BehaviorSubject<String>();

  final _rotations = BehaviorSubject<List>();

  final _algorithm = BehaviorSubject<String>();

  Stream<String> get algorithmStream => _algorithm.stream;
  Function(String) get algorithmChanged => _algorithm.sink.add;
  String get algorithm => _algorithm.value;

  Stream<bool> get uploadImageStream => _uploadImage.stream;
  Function(bool) get uploadImageStatus => _uploadImage.sink.add;

  Stream<String> get errorTextStream => _uploadError.stream;
  Function(String) get errorTextChanged => _uploadError.sink.add;

  List get rotations => _rotations.value;
  Stream<List> get rotationsStream => _rotations.stream;
  Function(List) get rotationsChanged => _rotations.sink.add;

  final _rubikColorCode = BehaviorSubject<Map>();
  Stream<Map> get colorCodeStream => _rubikColorCode.stream;
  Function(Map) get colorCodeChanged => _rubikColorCode.sink.add;
  Map get rubikColorCode => _rubikColorCode.value;

  HomeViewModel() {
    rotationsChanged([]);
    _algorithm.sink.add('Kociemba');

    colorCodeStream.listen((code) {
      rotationsChanged([]);
      logger.info('Color code: $code');
    });

    initial();
  }

  void initial() async {
    colorCodeChanged({
      "top": r'oyorywwgg',
      "left": r'wgrwbybwo',
      "front": r'borbrobob',
      "right": r'wgyygyobr',
      "back": r'grggorybr',
      "bottom": r'wwybwryog',
    });
    await Future.delayed(Duration(milliseconds: 300));
    rotationsChanged(["U2", "R", "L2", "B'", "U", "F", "B'", "U", "R", "F2", "D2", "F", "D'", "L2", "D", "B2", "U'", "D2", "F2", "D2"]);
  }

  void resetAll() {
    colorCodeChanged({});
  }

  void scramble() {

  }

  void resetSide(String side) {
    var map = rubikColorCode;
    map[side.toLowerCase()] = '';
    colorCodeChanged(map);
  }

  void setCode(String side, {String code}) {
    var map = rubikColorCode;
    map[side.toLowerCase()] = code;
    colorCodeChanged(map);
  }

  bool checkColor(String side, {String code}) {
    if (code.length != 9) return false;
    String center = code[4];
    switch (side.toLowerCase()) {
      case "top": return center == 'y';
      case "left": return center == 'b';
      case "front": return center == 'r';
      case "right": return center == 'g';
      case "back": return center == 'o';
      case "bottom": return center == 'w';
      default: return false;
    }
  }

  String getCode(String side) {
    final key = side.toLowerCase();
    return (rubikColorCode.containsKey(key)) ? rubikColorCode[key] : '';
  }

  String get kociembaCode {
    var map = rubikColorCode;
    if (map.keys.isEmpty) return '';
    return map["top"] +
        map["left"] +
        map["front"] +
        map["right"] +
        map["back"] +
        map["bottom"];
  }

  bool get isValid => kociembaCode.length == 54;

  void dispose() {
    solving.close();
    _uploadImage.close();
    _uploadError.close();
    _algorithm.close();
    _rotations.close();
    _rubikColorCode.close();
  }
}