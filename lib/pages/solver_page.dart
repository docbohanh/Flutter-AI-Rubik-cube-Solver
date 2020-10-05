import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rubikSolver/pages/helper.dart';

class SolverPage extends StatefulWidget {
  final String code;
  final List rotations;

  const SolverPage({this.rotations, this.code});

  @override
  _SolverPageState createState() => _SolverPageState();
}

class _SolverPageState extends State<SolverPage> {
  final _scrollController = ScrollController();

  pw.Document doc;

  bool isMakingPDF = false;

  Widget rubikLoading({double size = 24}) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset("assets/rubik_rotations.gif"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf9f9f9),
      appBar: AppBar(
        title: Text("Kociemba ${widget.rotations.length} rotations"),
        actions: [
          IconButton(
            onPressed: () => _makePDF(),
            icon: isMakingPDF
                ? rubikLoading()
                : Icon(Icons.picture_as_pdf, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) => tooltipView(),
                      childCount: 1,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    floating: true,
                    delegate: ContestTabHeader(
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Center(
                            child: Text(
                              '${widget.code}',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      height: 30,
                    ),
                  ),
                ];
              },
              body: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      initialView(),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: widget.rotations.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                          height: 2,
                          color: Colors.black54,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return rotation(index, widget.rotations[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tooltipView() {
    return Container(
      color: Color(0xFFf9f9f9),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/kociemba.png"),
          Divider(
            height: 2,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget initialView() {
    return Container(
      height: 320,
      color: Color(0xFFf9f9f9),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "*2 - Turn two times",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              )),
          Text(
            "Initial View",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Image.asset("assets/initial.png", height: 250),
          Divider(
            height: 2,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget rotation(index, turn) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Step ${index + 1}: $turn",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 12,
          ),
          Image.asset(
            "assets/$turn.png",
            height: 220,
          )
        ],
      ),
    );
  }

  var index = 0;

  void _makePDF() async {
    logger.info('index $index');
    if (!isMakingPDF) {
      setState(() => isMakingPDF = true);
    }

    if (index > widget.rotations.length - 1) {
      setState(() => isMakingPDF = false);
      _sharePDF();
    } else {
      if (doc == null) {
        doc = pw.Document();
      }

      if (index == 0) {
        final imageProvider = AssetImage('assets/initial.png');
        final image = await pdfImageFromImageProvider(
          pdf: doc.document,
          image: imageProvider,
        );

        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a5,
            build: (pw.Context context) {
              return pw.Column(children: [
                pw.SizedBox(height: 10),
                pw.Container(
                    child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      "${widget.code}",
                      maxLines: 3,
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          "*2 - Turn two times",
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    pw.Text(
                      "Initial view",
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Image(image),
                  ],
                )),
              ]); // Center
            },
          ),
        );
      }

      var turn = widget.rotations[index];
      var step = index + 1;
      final imageProvider = AssetImage('assets/$turn.png');
      final image = await pdfImageFromImageProvider(
        pdf: doc.document,
        image: imageProvider,
      );

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          build: (pw.Context context) {
            return pw.Center(
                child: pw.Container(
              width: 500,
              height: 500,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    "Step $step: $turn",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Container(width: 500, height: 500, child: pw.Image(image)),
                ],
              ),
            ));
          },
        ),
      );

      await Future.delayed(Duration(milliseconds: 250));
      index++;
      _makePDF();
    }
  }

  void _sharePDF() async {
    try {
      await Printing.sharePdf(
        bytes: doc.save(),
        filename: '${widget.code}.pdf',
      );
    } catch (e) {
      logger.info(e.toString());
    }
  }
}

class ContestTabHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  ContestTabHeader({this.child = const SizedBox(), this.height = 52.0});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
