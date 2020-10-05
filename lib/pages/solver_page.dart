import 'package:flutter/material.dart';

class SolverPage extends StatefulWidget {
  final String code;
  final List rotations;

  const SolverPage({this.rotations, this.code});

  @override
  _SolverPageState createState() => _SolverPageState();
}

class _SolverPageState extends State<SolverPage> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf9f9f9),
      appBar: AppBar(
        title: Text("Kociemba ${widget.rotations.length} rotations"),
        actions: [
          IconButton(
            onPressed: () {
              // Share.shareFiles([]);
            },
            icon: Icon(Icons.launch, color: Colors.white),
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
                        child: Center(
                          child: Text(
                            '${widget.code}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      height: 40,
                    ),
                  ),
                ];
              },
              body: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                color: Colors.white,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: widget.rotations.length,
                  separatorBuilder: (BuildContext context, int index) => Divider(
                    height: 2,
                    color: Colors.black54,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return rotation(index, widget.rotations[index]);
                  },
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
                      color: Colors.brown),
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