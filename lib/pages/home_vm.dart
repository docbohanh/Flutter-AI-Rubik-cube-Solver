import 'package:rxdart/rxdart.dart';

import 'helper.dart';

class HomeViewModel {
  final solving = BehaviorSubject<bool>();
  final _uploadImage = BehaviorSubject<bool>();
  final _uploadError = BehaviorSubject<String>();

  final _rotations = BehaviorSubject<List>();

  final top = BehaviorSubject<String>();
  final left = BehaviorSubject<String>();
  final front = BehaviorSubject<String>();
  final right = BehaviorSubject<String>();
  final back = BehaviorSubject<String>();
  final bottom = BehaviorSubject<String>();

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

  Stream<String> get colorCode => Rx.combineLatest6(
    top.stream,
    left.stream,
    front.stream,
    right.stream,
    back.stream,
    bottom.stream, (a, b, c, d, e, f) => a + b + c + d + e + f,
  );

  HomeViewModel() {
    initial();

    rotationsChanged([]);
    _algorithm.sink.add('Kociemba');

    colorCode.listen((code) {
      rotationsChanged([]);
      logger.info('Color code: $code');
    });

    // rotationsChanged(["U2", "R", "L2", "B'", "U", "F", "B'", "U", "R", "F2", "D2", "F", "D'", "L2", "D", "B2", "U'", "D2", "F2", "D2"]);
  }

  void initial() {
    //
    top.sink.add(r'oyorywwgg');
    left.sink.add(r'wgrwbybwo');
    front.sink.add(r'borbrobob');
    right.sink.add(r'wgyygyobr');
    back.sink.add(r'grggorybr');
    bottom.sink.add(r'wwybwryog');
  }

  void resetAll() {
    top.sink.add(r'');
    left.sink.add(r'');
    front.sink.add(r'');
    right.sink.add(r'');
    back.sink.add(r'');
    bottom.sink.add(r'');
  }
  void scramble() {

  }

  void resetSide(String side) {
    switch (side.toLowerCase()) {
      case "top": top.sink.add(r''); break;
      case "left": left.sink.add(r''); break;
      case "front": front.sink.add(r''); break;
      case "right": right.sink.add(r''); break;
      case "back": back.sink.add(r''); break;
      case "bottom": bottom.sink.add(r''); break;
      default: break;
    }
  }

  void setCode(String side, {String code}) {
    switch (side.toLowerCase()) {
      case "top": top.sink.add(code); break;
      case "left": left.sink.add(code); break;
      case "front": front.sink.add(code); break;
      case "right": right.sink.add(code); break;
      case "back": back.sink.add(code); break;
      case "bottom": bottom.sink.add(code); break;
      default: break;
    }
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
    switch (side.toLowerCase()) {
      case "top": return top.value; break;
      case "left": return left.value; break;
      case "front": return front.value; break;
      case "right": return right.value; break;
      case "back": return back.value; break;
      case "bottom": return bottom.value; break;
      default: return '';
    }
  }

  Stream<String> getStream(String side) {
    switch (side.toLowerCase()) {
      case "top": return top.stream; break;
      case "left": return left.stream; break;
      case "front": return front.stream; break;
      case "right": return right.stream; break;
      case "back": return back.stream; break;
      case "bottom": return bottom.stream; break;
      default: return null;
    }
  }

  String get kociembaCode => top.value + left.value + front.value + right.value + back.value + bottom.value;

  bool get isValid => kociembaCode.length == 54;

  void dispose() {
    solving.close();
    _uploadImage.close();
    _uploadError.close();
    top.close();
    left.close();
    front.close();
    right.close();
    back.close();
    bottom.close();
    _algorithm.close();
    _rotations.close();
  }
}