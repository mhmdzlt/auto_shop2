import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/offline_orders_service.dart';

final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((list) => list.first);
});

final syncOnConnectProvider = Provider.autoDispose((ref) {
  ref.listen(connectivityStreamProvider, (prev, curr) {
    curr.when(
      data: (result) {
        if (result != ConnectivityResult.none) {
          OfflineOrdersService().syncAll();
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  });
});
