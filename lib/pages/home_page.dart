import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:rubikSolver/pages/home_item.dart';
import 'package:rubikSolver/pages/home_vm.dart';
import 'package:rubikSolver/pages/solver_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final picker = ImagePicker();

  String kociembaUrl = 'https://rubik-solver.herokuapp.com/';

  Dio _dio;

  final viewModel = HomeViewModel();

  final _allSide = ['Top', 'Left', 'Front', 'Right', 'Back', 'Bottom'];

  final filterColorCode =
      FilteringTextInputFormatter.allow(RegExp(r'[ybrgow]'));

  @override
  void initState() {
    _dio = Dio();
    _dio.options.baseUrl = kociembaUrl;
    _dio.options.connectTimeout = 60000;
    _dio.options.receiveTimeout = 60000;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }

  void openSolvePage(List rotations) {
    if (rotations.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolverPage(
          rotations: rotations,
          code: viewModel.kociembaString,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget rubikLoading({double size = 40}) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset("assets/rubik_rotations.gif"),
    );
  }

  launchURL({String url = 'https://pypi.org/project/rubik-solver'}) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar({String text = 'Wrong color pattern'}) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
        action: SnackBarAction(
          label: r'OK',
          textColor: Colors.blue,
          onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  PopupMenu menu;
  final popupKey = GlobalKey();
  String clear = r'Clear';
  String info = r'Info';
  String baseUrl = r'Server';
  String initial = r'Initial';
  String play = 'Play';
  final playUrl = 'https://www.google.com/logos/2014/rubiks/iframe/index.html';
  String algorithm = 'Algorithm';
  final algorithms = ['Kociemba', r'CFOP', 'Beginner'];

  tapOnMoreAction() async {
    if (menu == null) {
      var style = TextStyle(fontSize: 14, color: Colors.white);
      menu = PopupMenu(
          backgroundColor: Colors.blue,
          lineColor: Colors.grey,
          maxColumn: 2,
          items: [
            MenuItem(
              title: clear,
              textStyle: style,
              image: Icon(
                Icons.clear,
                color: Colors.white,
              ),
            ),
            MenuItem(
              title: info,
              textStyle: style,
              image: Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
            ),
            MenuItem(
              title: baseUrl,
              textStyle: style,
              image: Icon(
                Icons.cloud_upload,
                color: Colors.white,
              ),
            ),
            MenuItem(
              title: initial,
              textStyle: style,
              image: Icon(
                Icons.replay,
                color: Colors.white,
              ),
            ),
            MenuItem(
              title: algorithm,
              textStyle: style,
              image: Icon(
                Icons.extension,
                color: Colors.white,
              ),
            ),
            MenuItem(
              title: play,
              textStyle: style,
              image: rubikLoading(size: 16),
            ),
          ],
          onClickMenu: (menu) async {
            if (menu.menuTitle == clear) {
              viewModel.resetAll();
            }

            if (menu.menuTitle == play) {
              launchURL(url: playUrl);
            }

            if (menu.menuTitle == initial) {
              viewModel.initial();
            }

            if (menu.menuTitle == info) {
              launchURL();
            }

            if (menu.menuTitle == algorithm) {
              final algorithm = await showDialog<String>(
                  context: context,
                  builder: (ctx) {
                    List<Widget> children = [Divider()];
                    children.addAll(algorithms.map((a) {
                      return Column(
                        children: <Widget>[
                          FlatButton(
                            onPressed: () => Navigator.pop(context, a),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 24.0,
                              ),
                              child: Center(
                                child: Text(a),
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      );
                    }).toList());
                    return SimpleDialog(
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Algorithm',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      children: children,
                    );
                  });

              if (algorithm != null) {
                viewModel.algorithmChanged(algorithm);
              }
            }

            if (menu.menuTitle == baseUrl) {
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return Dialog(
                      child: TextField(
                        textAlign: TextAlign.left,
                        textInputAction: TextInputAction.done,
                        autofocus: true,
                        controller: TextEditingController(text: kociembaUrl),
                        onSubmitted: (url) {
                          if (url.isNotEmpty) {
                            kociembaUrl = url;
                          }
                          Navigator.pop(context);
                        },
                        decoration: InputDecoration(
                          prefixText: '  ',
                        ),
                      ),
                    );
                  });
            }
          });
    }
    menu.show(widgetKey: popupKey);
  }

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;
    PopupMenu.itemWidth = 90;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Rubik's Cube Solver"),
        actions: [
          IconButton(
            key: popupKey,
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => tapOnMoreAction(),
            tooltip: 'More action',
          ),
        ],
      ),
      body: GridView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 100),
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: List.generate(
          _allSide.length,
          (index) {
            String side = _allSide[index];
            return HomeItem(
              side: side,
              viewModel: viewModel,
              onCapture: () => getImage(side),
              onHandingInput: () => handInputColorCode(side),
              onClear: () => viewModel.resetSide(side),
              onEdit: () => handInputColorCode(side),
            );
          },
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: .68,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: StreamBuilder(
        stream: viewModel.colorCodeStream,
        builder: (ctx, sn) {
          return viewModel.isValid
              ? Container(
                  padding: EdgeInsets.only(bottom: 10),
                  height: 72,
                  width: 72,
                  child: FloatingActionButton(
                    tooltip: "Kociemba Rubik's Cube Solver",
//          backgroundColor: Colors.indigo,
                    child: StreamBuilder<bool>(
                      stream: viewModel.solving.stream,
                      initialData: false,
                      builder: (ctx, snapshot) {
                        if (snapshot.data) {
                          return Container(
                            height: 54,
                            child: rubikLoading(),
                          );
                        }
                        return Text("Solve", style: TextStyle(fontSize: 14));
                      },
                    ),
                    onPressed: _solveCube,
                  ),
                )
              : SizedBox();
        },
      ),
    );
  }

  void _showUploadImageBox(String path, String side) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: StreamBuilder<bool>(
            stream: viewModel.uploadImageStream,
            initialData: true,
            builder: (ctx, snapshot) {
              var box = Container(
                margin: EdgeInsets.all(15),
                height: 300.0,
                width: 300.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: StreamBuilder<String>(
                  stream: viewModel.errorTextStream,
                  builder: (ctx, snapshot) {
                    var errorText = snapshot.data ?? '';
                    var errorWidget = Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorText,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        FlatButton(
                            onPressed: () {
                              viewModel.resetSide(side);
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Try Again",
                              style: TextStyle(color: Colors.blue),
                            ))
                      ],
                    );

                    var matchedColor = Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Colors are matched?",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // viewModel.getCode(side).colorColumn,
                        HomeItem(
                          side: side,
                          viewModel: viewModel,
                          isShowTooltip: false,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FlatButton(
                                onPressed: () {
                                  viewModel.resetSide(side);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Try Again",
                                  style: TextStyle(color: Colors.blue),
                                )),
                            FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Done",
                                style: TextStyle(color: Colors.green),
                              ),
                            )
                          ],
                        )
                      ],
                    );
                    return errorText.isNotEmpty ? errorWidget : matchedColor;
                  },
                ),
              );
              var blank = Container(
                margin: EdgeInsets.all(15),
                height: 300.0,
                width: 300.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  //  color: Colors.red,
                  image: DecorationImage(
                    image: FileImage(File(path)),
                    fit: BoxFit.fitHeight,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black45),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      rubikLoading(),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Image Was Processing...",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              );
              return snapshot.data ? blank : box;
            },
          ),
        );
      },
    );
  }

  ///
  Future getImage(String side) async {
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 1600,
      maxWidth: 1000,
    );

    File croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatioPresets: [],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      iosUiSettings: IOSUiSettings(
        title: 'Cropper',
      ),
    );

    if (croppedFile == null) return;

    _showUploadImageBox(croppedFile.path, side);

    _uploadImage(path: croppedFile.path, side: side);
  }

  void handInputColorCode(String side) {
    String currentCode = viewModel.getCode(side);

    final _controller = TextEditingController(
      text: '$currentCode',
    );
    final _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (currentCode.isNotEmpty && _focusNode.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });

    var textField = SizedBox(
      height: 50,
      child: TextField(
        inputFormatters: [
          filterColorCode,
        ],
        maxLength: 9,
        textAlign: TextAlign.left,
        textInputAction: TextInputAction.done,
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        onSubmitted: (code) {
          if (code.length == 9 && viewModel.checkColor(side, code: code)) {
            viewModel.setCode(side, code: code);
          } else {
            var msg = r'Wrong color pattern';
            if (code.length == 0) msg = 'Colors code is empty';
            showSnackBar(text: msg);
          }
          Navigator.pop(context);
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(width: 1, color: Colors.transparent),
          ),
          prefixText: side + ':  ',
          suffix: InkWell(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.clear,
                size: 20,
                color: Colors.redAccent[700],
              ),
            ),
          ),
        ),
      ),
    );

    var bold = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.black54,
      fontFamily: 'Roboto',
    );
    var normal = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 13,
      color: Colors.black54,
      fontFamily: 'Roboto',
    );

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.transparent,
          child: Container(
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(16.0),
                topRight: const Radius.circular(16.0),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Image.asset('assets/kociemba.png'),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(width: 0.2, color: Colors.grey),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: RichText(
                        maxLines: 10,
                        text: TextSpan(
                          text: 'Kociemba',
                          style: bold,
                          children: <TextSpan>[
                            TextSpan(
                                text:
                                    ' solver needs the following cubes at place: \n',
                                style: normal),
                            TextSpan(text: '4 - ', style: bold),
                            TextSpan(
                                text: 'Y',
                                style:
                                    bold.copyWith(color: Colors.yellow[600])),
                            TextSpan(text: r'ellow, ', style: normal),
                            TextSpan(text: '13 - ', style: bold),
                            TextSpan(
                                text: 'B',
                                style: bold.copyWith(color: Colors.blueAccent)),
                            TextSpan(text: 'lue, ', style: normal),
                            TextSpan(text: '22 - ', style: bold),
                            TextSpan(
                                text: 'R',
                                style: bold.copyWith(color: Colors.red)),
                            TextSpan(text: 'ed, ', style: normal),
                            TextSpan(text: '31 - ', style: bold),
                            TextSpan(
                                text: 'G',
                                style: bold.copyWith(color: Colors.green)),
                            TextSpan(text: r'reen, ', style: normal),
                            TextSpan(text: '40 - ', style: bold),
                            TextSpan(
                                text: 'O',
                                style: bold.copyWith(color: Colors.orange)),
                            TextSpan(text: 'range, ', style: normal),
                            TextSpan(text: '49 - ', style: bold),
                            TextSpan(
                                text: 'W',
                                style: bold.copyWith(color: Colors.grey)),
                            TextSpan(text: r'hite.', style: normal),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: textField,
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ///
  void _solveCube() async {
    if (viewModel.rotations.isNotEmpty) {
      openSolvePage(viewModel.rotations);
      return;
    }

    if (!viewModel.isValid) {
      showSnackBar();
      return;
    }

    String _colorCode = viewModel.kociembaCode;

    try {
      logger.info('color code: $_colorCode');

      viewModel.solving.sink.add(true);
      Response response = await _dio.get('solve', queryParameters: {
        'algorithm': viewModel.algorithm,
        'colors': viewModel.kociembaCode,
      });

      logger.info(response.request.path);
      logger.info(response.request.queryParameters);
      logger.info(response.data);

      var solver = Kociemba.fromJSON(response.data);
      viewModel.solving.sink.add(false);

      if (solver.status == false) {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text('Wrong color pattern, Try again...'),
        ));
      } else {
        viewModel.rotationsChanged(solver.rotations);
        openSolvePage(solver.rotations);
      }
    } catch (e) {
      viewModel.solving.sink.add(false);
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text('Server error, Try again...'),
      ));
    }
  }

  ///
  _uploadImage({String path, String side}) async {
    viewModel.uploadImageStatus(true);
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(path, filename: "rubik.jpeg"),
    });

    try {
      logger.info('side: $side');

      Response response = await _dio.post('/', data: formData);

      logger.info(response.data);

      var rubikSide = RubikSideImage.fromJSON(response.data);

      viewModel.uploadImageStatus(false);

      if (rubikSide.status == false) {
        viewModel.errorTextChanged("Unable to detect colors, try again...");
      } else {
        viewModel.errorTextChanged(null);
        viewModel.setCode(side, code: rubikSide.code.toLowerCase());
      }
    } catch (e) {
      logger.info(e.toString());
      viewModel.uploadImageStatus(false);
      viewModel.errorTextChanged("Server Error");
    }
  }
}
