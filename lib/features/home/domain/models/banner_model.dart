import 'package:flutter/material.dart';

class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color startColor;
  final Color endColor;
  final IconData icon;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.startColor,
    required this.endColor,
    required this.icon,
  });
}