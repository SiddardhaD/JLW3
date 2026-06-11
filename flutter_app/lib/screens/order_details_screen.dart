import 'package:flutter/material.dart';
import '../models/order.dart';
import '../widgets/decision_dialog.dart';

class OrderDetailsScreen extends StatelessWidget {
  final ProcurementOrder order;
  final VoidCallback onBack;
  final Function(String orderNo) onApproveOrder;
  final Function(String orderNo) onRejectOrder;
  final Function(String orderNo, int lineNo) onApproveLine;
  final Function(String orderNo, int lineNo) onRejectLine;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.onBack,
    required this.onApproveOrder,
    required this.onRejectOrder,
    required this.onApproveLine,
    required this.onRejectLine,
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

  void _triggerLineDecision(BuildContext context, int lineNo, bool approve) {
    showDialog(
      context: context,
      builder: (dialogCtx) => DecisionDialog(
        title: approve ? "Approve Line Item" : "Reject Line Item",
        body: approve
            ? "Are you sure you want to approve Line #$lineNo for Order #${order.orderNo}?"
            : "Are you sure you want to reject Line #$lineNo for Order #${order.orderNo}? Please provide a valid justification below.",
        approve: approve,
        onConfirm: (remarks) {
          if (approve) {
            onApproveLine(order.orderNo, lineNo);
          } else {
            onRejectLine(order.orderNo, lineNo);
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
          // AppBar Custom
          Container(
            color: const Color(0xFF021733),
            padding: const EdgeInsets.fromLTRB(8, 50, 8, 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                ),
                const Expanded(
                  child: Text(
                    "Order Details",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onBack,
                ),
              ],
            ),
          ),

          // Scrollable specifications
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // General properties
                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(color: Color(0xFF1E3A5F), shape: BoxShape.circle),
                              child: const Icon(Icons.description, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Order No.", style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF1CB55C)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                order.orderType,
                                style: const TextStyle(
                                  color: Color(0xFF1CB55C),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 18),

                        _buildMetaRow3("Originator", order.originator, "Responsible", order.responsible, "Project", order.project),
                        const SizedBox(height: 12),
                        _buildMetaRow3("Supplier", order.supplier, "CO", order.companyCode, "Order Date", order.orderDate),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Amount visual
                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Order Amount",
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              order.formattedAmount,
                              style: const TextStyle(
                                color: Color(0xFF1CB55C),
                                fontSize: 24,
                                fontWeight: FontWeight.black,
                              ),
                            ),
                            Text(
                              "  ${order.currency}",
                              style: const TextStyle(
                                color: Color(0xFF1CB55C),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Line items section
                Row(
                  children: [
                    const Text(
                      "Line Items",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF021733).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${order.lines.length} item(s)",
                        style: const TextStyle(
                          color: Color(0xFF021733),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),

                // Line details maps
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.lines.length,
                  itemBuilder: (context, idx) {
                    final line = order.lines[idx];
                    return _buildLineItemWidget(context, line);
                  },
                ),
              ],
            ),
          ),

          // Master actions block
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE53935)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _triggerOrderDecision(context, false),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cancel_outlined, color: Color(0xFFE53935), size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Reject",
                            style: TextStyle(color: Color(0xFFE53935), fontSize: 14, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1CB55C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _triggerOrderDecision(context, true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Approve",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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

  Widget _buildLineItemWidget(BuildContext context, OrderLine line) {
    final Color stripeColor = line.status == OrderApprovalStatus.approved
        ? const Color(0xFF1CB55C)
        : (line.status == OrderApprovalStatus.rejected
            ? const Color(0xFFE53935)
            : const Color(0xFF1976D2));

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 6, color: stripeColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Line ${line.number}",
                        style: const TextStyle(
                          color: Color(0xFF1976D2),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (line.status == OrderApprovalStatus.pending)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Color(0xFFE53935), size: 18),
                              onPressed: () => _triggerLineDecision(context, line.number, false),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Color(0xFF1CB55C), size: 18),
                              onPressed: () => _triggerLineDecision(context, line.number, true),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: line.status == OrderApprovalStatus.approved
                                ? const Color(0xFF1CB55C).withOpacity(0.12)
                                : const Color(0xFFE53935).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            line.status.name.toUpperCase(),
                            style: TextStyle(
                              color: line.status == OrderApprovalStatus.approved
                                  ? const Color(0xFF1CB55C)
                                  : const Color(0xFFE53935),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Item Code", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            Text(
                              line.itemCode,
                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Item Description", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            Text(
                              line.description,
                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Requested Date", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            Text(
                              line.requestedDate,
                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Quantity", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            Text(
                              line.quantity,
                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Unit Cost", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            Text(
                              "${line.unitCost.toInt()} ${order.currency}",
                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Extended Cost", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            Text(
                              "${line.extendedCost.toInt()} ${order.currency}",
                              style: const TextStyle(color: Color(0xFF021733), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetaRow3(
    String l1, String v1,
    String l2, String v2,
    String l3, String v3,
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
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
