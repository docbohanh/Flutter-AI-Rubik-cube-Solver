import 'package:rubikSolver/pages/home_vm.dart';
import 'helper.dart';
import 'package:flutter/material.dart';

class HomeItem extends StatelessWidget {
  final String side;
  final Function onCapture;
  final Function onHandingInput;
  final Function onClear;
  final Function onEdit;
  final HomeViewModel viewModel;
  final bool isShowTooltip;

  const HomeItem({
    this.side,
    this.onCapture,
    this.onHandingInput,
    this.viewModel,
    this.onClear,
    this.onEdit,
    this.isShowTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    var stream = viewModel.getStream(side);
    if (stream == null) return SizedBox();

    return StreamBuilder<String>(
      stream: stream,
      builder: (ctx, snapshot) {
        var code = snapshot.data ?? '';
        Widget widget = SizedBox();
        if (code.length == 9) {
          widget = code.colorContainer;
        } else {
          widget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => onCapture(),
                icon: Icon(
                  Icons.add_a_photo,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () => onHandingInput(),
                icon: Icon(
                  Icons.text_fields,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
            ],
          );
        }

        return Container(
          width: 160,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isShowTooltip ? '  $side' : '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  (code.isNotEmpty && isShowTooltip)
                      ? Row(
                        children: [
                          InkWell(
                            onTap: () => this.onEdit(),
                            child: Container(
                              margin: EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          InkWell(
                              onTap: () => this.onClear(),
                              child: Icon(
                                Icons.clear,
                                size: 24,
                                color: Colors.redAccent[700],
                              ),
                            ),
                          SizedBox(width: 5),
                        ],
                      )
                      : Container(
                    margin: EdgeInsets.all(4),
                    child: Container(
                      height: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300],
                ),
                width: 160,
                height: 160,
                child: Center(child: widget),
              ),
              isShowTooltip
                  ? Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Center must be:  ",
                              style: TextStyle(fontSize: 12)),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: side.color,
                              border: Border.all(
                                color: Colors.grey[300],
                                width: 2,
                              ),
                            ),
                            width: 16,
                            height: 16,
                          )
                        ],
                      ),
                  )
                  : Container(),
              (code.isNotEmpty && isShowTooltip)
                  ? Text('($code)', style: TextStyle(fontSize: 11))
                  : SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
