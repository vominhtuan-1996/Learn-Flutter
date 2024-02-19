class SalesData {
  SalesData(this.date, this.conntry, this.y, this.y1, this.y2, this.y3, this.y4);
  final DateTime? date;
  final String? conntry;
  final double? y;
  final double y1;
  final double y2;
  final double y3;
  final double y4;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    return map;
  }

  List<Object?> get props => [];
}
