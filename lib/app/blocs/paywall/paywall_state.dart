import 'package:equatable/equatable.dart';

enum PaywallStatus {
  initial,
  loading,
  ready,
  loadError,
  unavailable,
  purchasing,
  success,
}

/// Store product reduced to display facts. Price strings come from the
/// store and are never composed locally.
class StoreProduct extends Equatable {
  const StoreProduct({
    required this.id,
    required this.price,
    required this.isYearly,
  });

  final String id;
  final String price;
  final bool isYearly;

  @override
  List<Object> get props => [id, price, isYearly];
}

class PaywallState extends Equatable {
  const PaywallState({
    this.status = PaywallStatus.initial,
    this.products = const [],
    this.selectedId,
    this.isPro = false,
    this.isRestoring = false,
    this.errorMessage = '',
    this.verifyEmailRequired = false,
    this.purchasesEnabled = false,
  });

  final PaywallStatus status;
  final List<StoreProduct> products;
  final String? selectedId;
  final bool isPro;
  final bool isRestoring;
  final String errorMessage;

  /// Paid on the store but the server needs a linked email first. The
  /// paywall surfaces the link banner/snackbar until resolved.
  final bool verifyEmailRequired;

  /// Server-derived gate for launching a new billing sheet.
  final bool purchasesEnabled;

  StoreProduct? get selected {
    for (final product in products) {
      if (product.id == selectedId) return product;
    }
    return products.isEmpty ? null : products.first;
  }

  PaywallState copyWith({
    PaywallStatus? status,
    List<StoreProduct>? products,
    String? selectedId,
    bool? isPro,
    bool? isRestoring,
    String? errorMessage,
    bool? verifyEmailRequired,
    bool? purchasesEnabled,
  }) {
    return PaywallState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedId: selectedId ?? this.selectedId,
      isPro: isPro ?? this.isPro,
      isRestoring: isRestoring ?? this.isRestoring,
      errorMessage: errorMessage ?? this.errorMessage,
      verifyEmailRequired: verifyEmailRequired ?? this.verifyEmailRequired,
      purchasesEnabled: purchasesEnabled ?? this.purchasesEnabled,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        selectedId,
        isPro,
        isRestoring,
        errorMessage,
        verifyEmailRequired,
        purchasesEnabled,
      ];
}
