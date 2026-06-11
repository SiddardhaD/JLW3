enum OrderApprovalStatus { pending, approved, rejected }

class OrderLine {
  final int number;
  final String itemCode;
  final String description;
  final String requestedDate;
  final String quantity;
  final double unitCost;
  final double extendedCost;
  OrderApprovalStatus status;

  OrderLine({
    required this.number,
    required this.itemCode,
    required this.description,
    required this.requestedDate,
    required this.quantity,
    required this.unitCost,
    required this.extendedCost,
    this.status = OrderApprovalStatus.pending,
  });

  OrderLine copyWith({OrderApprovalStatus? status}) {
    return OrderLine(
      number: number,
      itemCode: itemCode,
      description: description,
      requestedDate: requestedDate,
      quantity: quantity,
      unitCost: unitCost,
      extendedCost: extendedCost,
      status: status ?? this.status,
    );
  }
}

class ProcurementOrder {
  final String orderNo;
  final String companyCode;
  final String supplier;
  final String originator;
  final String responsible;
  final String orderType;
  final String orderDate;
  final double amount;
  final String currency;
  final String formattedAmount;
  final String project;
  final List<OrderLine> lines;
  OrderApprovalStatus status;

  ProcurementOrder({
    required this.currency,
    required this.orderNo,
    required this.companyCode,
    required this.supplier,
    required this.originator,
    required this.responsible,
    required this.orderType,
    required this.orderDate,
    required this.amount,
    required this.formattedAmount,
    required this.project,
    required this.lines,
    this.status = OrderApprovalStatus.pending,
  });

  ProcurementOrder copyWith({
    OrderApprovalStatus? status,
    List<OrderLine>? lines,
  }) {
    return ProcurementOrder(
      currency: currency,
      orderNo: orderNo,
      companyCode: companyCode,
      supplier: supplier,
      originator: originator,
      responsible: responsible,
      orderType: orderType,
      orderDate: orderDate,
      amount: amount,
      formattedAmount: formattedAmount,
      project: project,
      lines: lines ?? this.lines,
      status: status ?? this.status,
    );
  }
}
