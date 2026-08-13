import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);
final selectedCategoryProvider = StateProvider<String>((ref) => '全部');
