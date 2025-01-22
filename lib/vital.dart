import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Example data class for Blood Pressure (BP) data
class BPData {
  final DateTime dateTime;
  final double value; // Assuming value is a double

  BPData(this.dateTime, this.value);
}

class VitalPage extends StatelessWidget {
  const VitalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vital Signs'),
      ),
      body: FutureBuilder<List<BPData>>(
        future: _fetchBPData(), // Fetching BP data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return _buildChart(snapshot.data!); // Building chart
          }
        },
      ),
    );
  }

  Future<List<BPData>> _fetchBPData() async {
    // Replace with your Firebase logic to fetch BP data
    List<BPData> bpDataList = [];
    final firestore = FirebaseFirestore.instance;

    // Assuming you have a collection named 'vitalSigns' with a document structure
    final snapshot = await firestore.collection('vitalSigns').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      bpDataList.add(
        BPData(
          (data['dateTime'] as Timestamp).toDate(), // Convert Timestamp to DateTime
          (data['value'] as num).toDouble(), // Assuming value is stored as a number
        ),
      );
    }
    return bpDataList;
  }

  Widget _buildChart(List<BPData> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: charts.TimeSeriesChart(
        _createChartSeries(data),
        animate: true,
        behaviors: [
          charts.SeriesLegend(),
          charts.ChartTitle('Date',
              behaviorPosition: charts.BehaviorPosition.bottom,
              titleOutsideJustification: charts.OutsideJustification.middle,
              innerPadding: 18),
          charts.ChartTitle('Blood Pressure Value',
              behaviorPosition: charts.BehaviorPosition.start,
              titleOutsideJustification: charts.OutsideJustification.middle,
              innerPadding: 18),
        ],
      ),
    );
  }

  List<charts.Series<BPData, DateTime>> _createChartSeries(List<BPData> data) {
    return [
      charts.Series<BPData, DateTime>(
        id: 'BPData',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (BPData bpData, _) => bpData.dateTime,
        measureFn: (BPData bpData, _) => bpData.value,
        data: data,
      ),
    ];
  }
}
