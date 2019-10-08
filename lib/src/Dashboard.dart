import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'package:server_monitoring/src/Drawer.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class CpuUsage {
  final String label;
  double usage;
  final charts.Color color;

  CpuUsage(this.label, this.usage, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class _DashboardState extends State<Dashboard> {
  Future loadFuture;

  @override
  void initState() {
    super.initState();
  }

  Future<String> getdata() async {
    String url = 'https://dev-tools.prioritas-group.com/stats';

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // print('RETURNING: ' + response.body);
      return response.body;
    } else {
      throw Exception('Failed to load post');
    }
  }

  var currentTime = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    loadFuture = getdata();
    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

    return new Container(
      child: new Stack(
        children: <Widget>[
          Container(
            color: Colors.red,
          ),
          Positioned(
            child: new Container(
              child: new Image.asset(
                'assets/predator_image.png',
                height: 100,
              ),
              color: Colors.red,
            ),
            left: -34,
            top: -15,
          ),
          new Scaffold(
              key: _scaffoldKey,
              drawer: new Drawer(
                child: DrawerUI(),
              ),
              floatingActionButton: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            loadFuture = getdata();
                          });
                        },
                        child: Icon(
                          Icons.refresh,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    )
                  ]),
              appBar: new AppBar(
                leading: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                ),
                centerTitle: true,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "PREDATOR",
                      style: TextStyle(fontSize: 25),
                    ),
                    Text(
                      "Server Monitoring",
                      style: TextStyle(fontSize: 13),
                    )
                  ],
                ),
                backgroundColor: Colors.transparent,
                elevation: 11.0,
              ),
              backgroundColor: Colors.transparent,
              body: new Container(
                color: Color(0xFFF2F2F2),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  // child: Container(
                  //   color: Colors.white,
                  // ),
                  child: MyFuture(
                    future: loadFuture,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

class CardCustom extends StatelessWidget {
  final Widget child;
  final String titleText;

  CardCustom({Key key, this.child, this.titleText = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: new Column(
        children: <Widget>[
          FractionallySizedBox(
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  titleText,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              decoration: const BoxDecoration(
                border: Border(
                  // top: BorderSide(
                  //     width: 1.0, color: Color(0xFFFFFFFFFF)),
                  // left: BorderSide(
                  //     width: 1.0, color: Color(0xFFFFFFFFFF)),
                  // right: BorderSide(
                  //     width: 1.0, color: Color(0xFFFF000000)),
                  bottom: BorderSide(width: 1.0, color: Color(0xFFEEEEEE)),
                ),
              ),
            ),
            widthFactor: 1,
          ),
          child
        ],
      ),
    );
  }
}

class MyFuture extends StatelessWidget {
  final Widget child;
  final Future future;
  MyFuture({Key key, this.child, this.future}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var url = 'https://dev-tools.prioritas-group.com/stats';
    return FutureBuilder(
      future: future,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<dynamic> disk;
          Map json = jsonDecode(snapshot.data);
          double cpu = json['cpu'];
          String uptime = json['uptime'];

          disk = json['disk'];

          double memory_usage = double.parse(json['memory_b']['used']);
          double memory_free = double.parse(json['memory_b']['free']);
          List<Widget> _listView = [];

          _listView.add(CardCustom(
            titleText: "Server Uptime",
            child: Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(uptime),
            ),
          ));
          var series = [
            new charts.Series(
                domainFn: (CpuUsage clickData, _) => clickData.label,
                measureFn: (CpuUsage clickData, _) => clickData.usage,
                colorFn: (CpuUsage clickData, _) => clickData.color,
                labelAccessorFn: (CpuUsage clickData, _) =>
                    clickData.usage.toString(),
                data: {
                  'Usage': CpuUsage('Usage',
                      double.parse(cpu.toStringAsFixed(3)), Colors.red),
                  'Available': CpuUsage(
                      'Available',
                      double.parse((100 - cpu).toStringAsFixed(3)),
                      Colors.green),
                }.values.toList()),
          ];

          var _cpuUsage = PieChart(
            type: 'to_percent',
            series: series,
          );
          _listView.add(
            CardCustom(
                titleText: "CPU Usage",
                child: Container(
                  child: _cpuUsage,
                  height: 200,
                )),
          );

          var _memseries = [
            new charts.Series(
                domainFn: (CpuUsage clickData, _) => clickData.label,
                measureFn: (CpuUsage clickData, _) => clickData.usage,
                colorFn: (CpuUsage clickData, _) => clickData.color,
                labelAccessorFn: (CpuUsage clickData, _) =>
                    clickData.usage.toString(),
                data: {
                  'Usage': CpuUsage('Usage', memory_usage, Colors.red),
                  'Available': CpuUsage('Available', memory_free, Colors.green),
                }.values.toList()),
          ];
          var _memUsage = PieChart(
            type: 'to_mb',
            series: _memseries,
          );
          _listView.add(CardCustom(
              titleText: "Memory Usage",
              child: Container(
                child: _memUsage,
                height: 200,
              )));

          // //DISK CHART
          if (disk != null) {
            // print(disk.length);

            for (var i = 0; i < 10; i++) {
              Map _dataDisk = disk[i];
              // print(_dataDisk['file_sistem']);
              String mounted_on = _dataDisk['mounted_on'];

              if (mounted_on == '/' || mounted_on == '/_DISK') {
                double used = double.parse(_dataDisk['used']);
                double free = double.parse(_dataDisk['avail']);

                var _diskSeries = [
                  new charts.Series(
                      domainFn: (CpuUsage clickData, _) => clickData.label,
                      measureFn: (CpuUsage clickData, _) => clickData.usage,
                      colorFn: (CpuUsage clickData, _) => clickData.color,
                      labelAccessorFn: (CpuUsage clickData, _) =>
                          clickData.usage.toString(),
                      data: {
                        'Usage': CpuUsage('Usage', used, Colors.red),
                        'Available': CpuUsage('Available', free, Colors.green),
                      }.values.toList()),
                ];
                var _diskUsage = PieChart(
                  type: 'to_gb',
                  series: _diskSeries,
                );
                _listView.add(CardCustom(
                    titleText: "Disk Usage (allocated for: " + mounted_on + ")",
                    child: Container(
                      child: _diskUsage,
                      height: 200,
                    )));
              }
            }
          } //End If

          return ListView(children: _listView);
        } else {
          return Container(
            alignment: Alignment.center,
            color: Color(0xFFF2F2F2),
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class PieChart extends StatelessWidget {
  List<charts.Series> series;
  String type;
  PieChart({Key key, this.series, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(
      series,
      animate: true,

      // Add the legend behavior to the chart to turn on legends.
      // This example shows how to optionally show measure and provide a custom
      // formatter.
      behaviors: [
        new charts.DatumLegend(
          // Positions for "start" and "end" will be left and right respectively
          // for widgets with a build context that has directionality ltr.
          // For rtl, "start" and "end" will be right and left respectively.
          // Since this example has directionality of ltr, the legend is
          // positioned on the right side of the chart.
          position: charts.BehaviorPosition.end,
          // By default, if the position of the chart is on the left or right of
          // the chart, [horizontalFirst] is set to false. This means that the
          // legend entries will grow as new rows first instead of a new column.
          horizontalFirst: false,
          // This defines the padding around each legend entry.
          cellPadding: new EdgeInsets.only(right: 30.0, bottom: 4.0),
          // Set [showMeasures] to true to display measures in series legend.
          showMeasures: true,
          // Configure the measure value to be shown by default in the legend.
          legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
          // Optionally provide a measure formatter to format the measure value.
          // If none is specified the value is formatted as a decimal.
          measureFormatter: (num value) {
            if (type == 'to_mb') {
              return value == null
                  ? '-'
                  : '${(value / 1000000).toStringAsFixed(2)} Mb';
            } else if (type == 'to_percent') {
              return value == null ? '-' : '${value}%';
            } else if (type == 'to_gb') {
              return value == null
                  ? '-'
                  : '${(value / 1000000).toStringAsFixed(2)} Gb';
            }
          },
        ),
      ],
    );
  }
}
