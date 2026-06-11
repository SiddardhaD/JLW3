import 'package:flutter/material.dart';
import '../models/order.dart';
import '../widgets/decision_dialog.dart';

const _kPrimaryBlue = Color(0xFF002147);
const _kPrimaryGreen = Color(0xFF16A34D);

class OrderDetailsScreen extends StatelessWidget {
  final ProcurementOrder order;
  final VoidCallback onBack;
  final Function(String orderNo) onApproveOrder;
  final Function(String orderNo) onRejectOrder;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.onBack,
    required this.onApproveOrder,
    required this.onRejectOrder,
  });

  void _triggerOrderDecision(BuildContext context, bool approve) {
    showDialog(
      context: context,
      builder: (dialogCtx) => DecisionDialog(
        title: approve ? "Approve Entire Order" : "Reject Entire Order",
        body: approve
            ? "Are you sure you want to approve Order #${order.orderNo}? This will mark all pending line items as approved."
            : "Are you sure you want to reject Order #${order.orderNo}? Please provide a valid justification below.",
        approve: approve,
        onConfirm: (remarks) {
          if (approve) {
            onApproveOrder(order.orderNo);
          } else {
            onRejectOrder(order.orderNo);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Column(
        children: [
          Container(
            color: _kPrimaryBlue,
            padding: const EdgeInsets.fromLTRB(8, 50, 8, 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                ),
                const Expanded(
                  child: Text(
                    "Order Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onBack,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOrderSummaryCard(),
                const SizedBox(height: 20),
                const Text(
                  "Line Items",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.lines.map(_buildLineItemWidget),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE53935)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _triggerOrderDecision(context, false),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cancel_outlined,
                              color: Color(0xFFE53935), size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Reject",
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimaryGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _triggerOrderDecision(context, true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Approve",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kPrimaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Order No.",
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                      Text(
                        order.orderNo,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kPrimaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.orderType,
                    style: const TextStyle(
                      color: _kPrimaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildMetaRow3(
              "Originator",
              order.originator,
              "Responsible",
              order.responsible,
              "Project",
              order.project,
            ),
            const SizedBox(height: 12),
            _buildMetaRow3(
              "Supplier",
              order.supplier,
              "CO",
              order.companyCode,
              "Order Date",
              order.orderDate,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Color(0xFFE2E8F0), height: 1),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Order Amount",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${order.formattedAmount} ${order.currency}",
                style: const TextStyle(
                  color: _kPrimaryGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemWidget(OrderLine line) {
    final stripeColor = line.status == OrderApprovalStatus.approved
        ? _kPrimaryGreen
        : (line.status == OrderApprovalStatus.rejected
            ? const Color(0xFFE53935)
            : _kPrimaryBlue);

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: stripeColor, width: 5),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Line ${line.number}",
              style: const TextStyle(
                color: _kPrimaryBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLineField("Item Code", line.itemCode),
                _buildLineField("Item Description", line.description, flex: 2),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildLineField("Requested Date", line.requestedDate),
                _buildLineField("Quantity", line.quantity, flex: 2),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildLineField(
                  "Unit Cost",
                  "${line.unitCost.toInt()} ${order.currency}",
                ),
                _buildLineField(
                  "Extended Cost",
                  "${line.extendedCost.toInt()} ${order.currency}",
                  flex: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineField(String label, String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow3(
    String l1,
    String v1,
    String l2,
    String v2,
    String l3,
    String v3,
  ) {
    return Row(
      children: [
        _buildMetaCell(l1, v1),
        _buildMetaCell(l2, v2),
        _buildMetaCell(l3, v3),
      ],
    );
  }

  Widget _buildMetaCell(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
