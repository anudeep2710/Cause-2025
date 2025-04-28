import '../models/product.dart';
import '../models/sale.dart';
import 'api_user.dart';
import 'call.dart';
import 'audio_room.dart';

// Product model for API
class ApiProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String category;
  final String createdAt;
  final String updatedAt;
  final String? imageUrl;
  final Map<String, dynamic>? attributes;

  ApiProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.attributes,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      stockQuantity: json['stockQuantity'],
      category: json['category'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      imageUrl: json['imageUrl'],
      attributes: json['attributes'],
    );
  }

  // Convert API product to BizzyBuddy Product model
  Product toBizzyBuddyProduct() {
    return Product(
      id: id,
      name: name,
      price: price,
      quantity: int.tryParse(stockQuantity.toString()) ?? 0,
      category: category,
      description: description,
      createdAt: DateTime.parse(createdAt),
    );
  }
}

// Sale model for API
class ApiSale {
  final String id;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String date;

  ApiSale({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.date,
  });

  factory ApiSale.fromJson(Map<String, dynamic> json) {
    return ApiSale(
      id: json['id'],
      productId: json['productId'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      date: json['date'],
    );
  }

  // Convert API sale to BizzyBuddy Sale model
  Sale toBizzyBuddySale() {
    return Sale(
      id: id,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      date: DateTime.parse(date),
      createdAt: DateTime.now(),
    );
  }
}

// Analytics model for API
class ApiAnalytics {
  final Map<String, dynamic> salesSummary;
  final Map<String, dynamic> topProducts;
  final List<Map<String, dynamic>> categoryPerformance;
  final Map<String, dynamic> revenueTrend;

  ApiAnalytics({
    required this.salesSummary,
    required this.topProducts,
    required this.categoryPerformance,
    required this.revenueTrend,
  });

  factory ApiAnalytics.fromJson(Map<String, dynamic> json) {
    return ApiAnalytics(
      salesSummary: json['salesSummary'],
      topProducts: json['topProducts'],
      categoryPerformance:
          List<Map<String, dynamic>>.from(json['categoryPerformance']),
      revenueTrend: json['revenueTrend'],
    );
  }
}

// // Alias for AudioRoom to maintain compatibility
// class ApiRoom extends AudioRoom {
//   ApiRoom({
//     required super.id,
//     required super.roomName,
//     required super.host,
//     required super.participants,
//     required super.streamCallId,
//     required super.channelId,
//     required super.settings,
//     required super.status,
//     required super.createdAt,
//   });

//   factory ApiRoom.fromJson(Map<String, dynamic> json) {
//     return ApiRoom(
//       id: json['_id'] as String? ?? '',
//       roomName: json['roomName'] as String? ?? '',
//       host: ApiUser.fromJson(json['host'] as Map<String, dynamic>? ?? {}),
//       participants: (json['participants'] as List?)
//               ?.map((p) => ApiUser.fromJson(p as Map<String, dynamic>? ?? {}))
//               .toList() ??
//           [],
//       streamCallId: json['streamCallId'] as String? ?? '',
//       channelId: json['channelId'] as String? ?? '',
//       settings: RoomSettings.fromJson(
//           json['settings'] as Map<String, dynamic>? ?? {}),
//       status: json['status'] as String? ?? 'active',
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'] as String)
//           : DateTime.now(),
//     );
//   }
// }

// // Alias for ApiUser to maintain compatibility
// class ApiCall extends Call {
//   ApiCall({
//     required super.id,
//     required super.createdBy,
//     required super.participants,
//     required super.status,
//     required super.streamCallId,
//     required super.startedAt,
//     super.endedAt,
//   });

//   factory ApiCall.fromJson(Map<String, dynamic> json) {
//     return ApiCall(
//       id: json['_id'] as String,
//       createdBy: ApiUser.fromJson(json['createdBy'] as Map<String, dynamic>),
//       participants: (json['participants'] as List)
//           .map((p) => CallParticipant.fromJson(p as Map<String, dynamic>))
//           .toList(),
//       status: json['status'] as String,
//       streamCallId: json['streamCallId'] as String,
//       startedAt: DateTime.parse(json['startedAt'] as String),
//       endedAt: json['endedAt'] != null
//           ? DateTime.parse(json['endedAt'] as String)
//           : null,
//     );
//   }
// }
