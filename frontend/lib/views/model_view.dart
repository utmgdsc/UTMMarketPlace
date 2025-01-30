// Template model view file for creating new model views
import 'package:flutter/material.dart';
import 'package:utm_marketplace/models/model.dart';

class ModelView extends StatelessWidget {
  final Model model;

  const ModelView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Attribute 1: ${model.attribute1}',
            style: TextStyle(fontSize: 18.0),
          ),
          Text(
            'Attribute 2: ${model.attribute2}',
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    ),);
  }
}