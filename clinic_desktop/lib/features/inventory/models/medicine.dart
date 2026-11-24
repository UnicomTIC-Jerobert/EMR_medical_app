class Medicine {
  final int id;
  final String brandName;
  final String genericName;
  int stockQty;
  final double unitPrice;
  final String category;
  final List<String> symptoms;

  Medicine({
    required this.id,
    required this.brandName,
    required this.genericName,
    required this.stockQty,
    required this.unitPrice,
    required this.category,
    required this.symptoms,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandName': brandName,
        'genericName': genericName,
        'stockQty': stockQty,
        'unitPrice': unitPrice,
        'category': category,
        'symptoms': symptoms,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json['id'] as int,
        brandName: json['brandName'] as String,
        genericName: json['genericName'] as String,
        stockQty: json['stockQty'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        category: json['category'] as String,
        symptoms: List<String>.from(json['symptoms'] ?? []),
      );
}
