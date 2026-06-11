import 'package:flutter/material.dart';
import '../models/order.dart';

class OrdersListScreen extends StatefulWidget {
  final List<ProcurementOrder> orders;
  final VoidCallback onLogout;
  final Function(String orderNo) onSelectOrder;

  const OrdersListScreen({
    super.key,
    required this.orders,
    required this.onLogout,
    required this.onSelectOrder,
  });

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";

  List<ProcurementOrder> get _filteredOrders {
    return widget.orders.where((order) {
      final matchesCategory = _selectedCategory == "All" ||
          (_selectedCategory == "High Value" && order.amount >= 1000000.0) ||
          (_selectedCategory == "Today" && (order.orderDate.contains("11 Jun") || order.orderNo == "2323137")) ||
          (_selectedCategory == "Pending" && order.status == OrderApprovalStatus.pending);

      final query = _searchQuery.toLowerCase().trim();
      final matchesQuery = query.isEmpty ||
          order.orderNo.toLowerCase().contains(query) ||
          order.supplier.toLowerCase().contains(query) ||
          order.originator.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Column(
        children: [
          // App Header
          Container(
            color: const Color(0xFF021733),
            padding: const EdgeInsets.only(top: 54, bottom: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {},
                      ),
                      const Expanded(
                        child: Text(
                          "Orders Awaiting Approval",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () {},
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: widget.onLogout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "APPROVER ID",
                              style: TextStyle(color: Color(0xCC64748B), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "1234567",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "PROJECT",
                              style: TextStyle(color: Color(0xCC64748B), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "M30",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: const InputDecoration(
                            hintText: "Search by Order No., Supplier...",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF021733),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 14),

                // Horizontal list of chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ["All", "High Value", "Today", "Pending"].map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF021733) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Orders List
          Expanded(
            child: _filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      "No pending approvals found.",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return _buildOrderCardItem(order);
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildOrderCardItem(ProcurementOrder order) {
    final Color badgeColor = order.status == OrderApprovalStatus.approved
        ? const Color(0xFF1CB55C)
        : (order.status == OrderApprovalStatus.rejected
            ? const Color(0xFFE53935)
            : (order.orderNo == "2323135" ? const Color(0xFF1E3A5F) : const Color(0xFF1CB55C)));

    return Card(
      color: Colors.white,
      shadowColor: const Color(0x33000000),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onSelectOrder(order.orderNo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                    child: const Icon(Icons.description_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Order No.", style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                        Text(
                          order.orderNo,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Amount", style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                      Text(
                        "${order.formattedAmount} ${order.currency}",
                        style: TextStyle(color: badgeColor, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 14),

              // Details Grid
              _buildGridRow("Originator", order.originator, "Order Type", order.orderType),
              const SizedBox(height: 8),
              _buildGridRow("CO", order.companyCode, "Order Date", order.orderDate),
              const SizedBox(height: 8),
              _buildGridRow("Responsible", order.responsible, "Supplier", order.supplier),

              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B), size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.orderDate,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ),
                  if (order.status != OrderApprovalStatus.pending)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: order.status == OrderApprovalStatus.approved
                            ? const Color(0xFF1CB55C).withOpacity(0.12)
                            : const Color(0xFFE53935).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.status.name.toUpperCase(),
                        style: TextStyle(
                          color: order.status == OrderApprovalStatus.approved
                              ? const Color(0xFF1CB55C)
                              : const Color(0xFFE53935),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Icon(Icons.arrow_right_alt_outlined, color: Color(0xFF64748B), size: 16),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridRow(String label1, String val1, String label2, String val2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              Text(
                val1,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              Text(
                val2,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
      ],
    );
  }
}
