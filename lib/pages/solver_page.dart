import 'package:flutter/material.dart';

class SolverPage extends StatefulWidget {
  final List rotations;

  const SolverPage({this.rotations});

  @override
  _SolverPageState createState() => _SolverPageState();
}

class _SolverPageState extends State<SolverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Kociemba ${widget.rotations.length} rotations"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            initialView(),
            Divider(
              height: 3,
              color: Colors.black,
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: widget.rotations.length,
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 3,
                color: Colors.black,
              ),
              itemBuilder: (BuildContext context, int index) {
                return rotation(index, widget.rotations[index]);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget initialView() {
    return Container(
      height: 320,
      color: Colors.grey[300],
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
            "Inital View",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 12,
          ),
          Image.asset(
            "assets/initial.png",
            height: 250,
          )
        ],
      ),
    );
  }

  Widget rotation(index, turn) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
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
