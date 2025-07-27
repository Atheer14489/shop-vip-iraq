enum CouponType { percentage, fixed }

class Coupon {
  final String code;
  final CouponType type;
  final double value;
  Coupon({
    required this.code,
    required this.type,
    required this.value,
  });
}
