import 'package:flutter/material.dart';

// ==========================================================================
// FLUTTER PRODUCTION REFERENCE: ORDER APPROVAL WORKFLOW
// Can be placed directly in any Flutter project's lib/main.dart
// Supports both Android and iOS out-of-the-box using the Material 3 guidelines.
// ==========================================================================

void main() {
  runApp(const OrderApprovalApp());
}

class OrderApprovalApp extends StatelessWidget {
  const OrderApprovalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Approvals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF021733),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF021733),
          primary: const Color(0xFF021733),
          secondary: const Color(0xFF1E3A5F),
          background: const Color(0xFFF6F8FB),
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainRouterScreen(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================

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

// ==========================================
// APPLICATION THEME COLORS
// ==========================================

class AppColors {
  static const Color deepBlue = Color(0xFF021733);
  static const Color accentBlue = Color(0xFF1E3A5F);
  static const Color customLightGray = Color(0xFFF6F8FB);
  static const Color accentGreen = Color(0xFF1CB55C);
  static const Color alertRed = Color(0xFFE53935);
  static const Color borderGray = Color(0xFFE2E8F0);
  static const Color labelGray = Color(0xFF64748B);
  static const Color darkText = Color(0xFF0F172A);
  static const Color statusIndicatorBlue = Color(0xFF1976D2);
}

// ==========================================
// MAIN ROUTER & STATE ENGINE
// ==========================================

enum ActiveView { login, ordersQueue, orderDetails }

class MainRouterScreen extends StatefulWidget {
  const MainRouterScreen({super.key});

  @override
  State<MainRouterScreen> createState() => _MainRouterScreenState();
}

class _MainRouterScreenState extends State<MainRouterScreen> {
  ActiveView _currentView = ActiveView.login;
  String? _selectedOrderNo;
  String _searchQuery = "";
  String _selectedCategory = "All";

  // Form Fields Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // In-memory data replication
  late List<ProcurementOrder> _orders;

  @override
  void initState() {
    super.initState();
    _orders = [
      ProcurementOrder(
        orderNo: "2323135",
        companyCode: "00200",
        supplier: "James O'Malley",
        originator: "Anubhav",
        responsible: "Nitya",
        orderType: "OP",
        orderDate: "10 Jun 2026",
        amount: 200020202.0,
        formattedAmount: "200,020,202",
        project: "M30",
        lines: [
          OrderLine(
            number: 1,
            itemCode: "210",
            description: "Desc1 + Description 2",
            requestedDate: "10-06-2026",
            quantity: "31 KG",
            unitCost: 10.0,
            extendedCost: 1000.0,
          ),
          OrderLine(
            number: 2,
            itemCode: "215",
            description: "Desc3 + Spare Materials",
            requestedDate: "10-06-2026",
            quantity: "50 Units",
            unitCost: 40.0,
            extendedCost: 2000.0,
          )
        ],
      ),
      ProcurementOrder(
        orderNo: "2323136",
        companyCode = "00200",
        supplier: "James O'Malley",
        originator: "Hiten",
        responsible: "Nitya",
        orderType: "OP",
        orderDate: "10 Jun 2026",
        amount: 250000000.0,
        formattedAmount: "250,000,000",
        project: "M30",
        lines: [
          OrderLine(
            number = 1,
            itemCode: "310",
            description: "Bulk Raw materials type A",
            requestedDate: "10-06-2026",
            quantity: "200 Liters",
            unitCost: 15.0,
            extendedCost = 3000.0,
          )
        ],
      ),
      ProcurementOrder(
        orderNo: "2323137",
        companyCode = "00100",
        supplier: "Global Components Corp",
        originator: "James Bond",
        responsible: "Moneypenny",
        orderType: "OP",
        orderDate: "11 Jun 2026",
        amount = 450000.0,
        formattedAmount = "450,000",
        project: "M30",
        lines: [
          OrderLine(
            number = 1,
            itemCode: "500",
            description = "Secure communications payload hardware config",
            requestedDate = "11-06-2026",
            quantity: "2 Units",
            unitCost: 225000.0,
            extendedCost: 450000.0,
          )
        ],
      )
    ];
  }

  void _navigateTo(ActiveView view) {
    setState(() {
      _currentView = view;
    });
  }

  void _viewOrderDetails(String orderNo) {
    setState(() {
      _selectedOrderNo = orderNo;
      _currentView = ActiveView.orderDetails;
    });
  }

  // Business Action updates
  void _approveOrder(String orderNo) {
    setState(() {
      _orders = _orders.map((o) {
        if (o.orderNo == orderNo) {
          return o.copyWith(
            status: OrderApprovalStatus.approved,
            lines: o.lines.map((l) => l.copyWith(status: OrderApprovalStatus.approved)).toList(),
          );
        }
        return o;
      }).toList();
    });
  }

  void _rejectOrder(String orderNo) {
    setState(() {
      _orders = _orders.map((o) {
        if (o.orderNo == orderNo) {
          return o.copyWith(
            status: OrderApprovalStatus.rejected,
            lines: o.lines.map((l) => l.copyWith(status: OrderApprovalStatus.rejected)).toList(),
          );
        }
        return o;
      }).toList();
    });
  }

  void _approveLine(String orderNo, int lineNo) {
    setState(() {
      _orders = _orders.map((o) {
        if (o.orderNo == orderNo) {
          final updatedLines = o.lines.map((l) {
            if (l.number == lineNo) {
              return l.copyWith(status: OrderApprovalStatus.approved);
            }
            return l;
          }).toList();

          final allApproved = updatedLines.every((l) => l.status == OrderApprovalStatus.approved);
          final anyRejected = updatedLines.any((l) => l.status == OrderApprovalStatus.rejected);
          final cumStatus = allApproved
              ? OrderApprovalStatus.approved
              : (anyRejected ? OrderApprovalStatus.rejected : OrderApprovalStatus.pending);

          return o.copyWith(status: cumStatus, lines: updatedLines);
        }
        return o;
      }).toList();
    });
  }

  void _rejectLine(String orderNo, int lineNo) {
    setState(() {
      _orders = _orders.map((o) {
        if (o.orderNo == orderNo) {
          final updatedLines = o.lines.map((l) {
            if (l.number == lineNo) {
              return l.copyWith(status: OrderApprovalStatus.rejected);
            }
            return l;
          }).toList();

          final allApproved = updatedLines.every((l) => l.status == OrderApprovalStatus.approved);
          final anyRejected = updatedLines.any((l) => l.status == OrderApprovalStatus.rejected);
          final cumStatus = allApproved
              ? OrderApprovalStatus.approved
              : (anyRejected ? OrderApprovalStatus.rejected : OrderApprovalStatus.pending);

          return o.copyWith(status: cumStatus, lines: updatedLines);
        }
        return o;
      }).toList();
    });
  }

  List<ProcurementOrder> get _getFilteredOrders {
    return _orders.filter((order) {
      final matchesCategory = when (_selectedCategory) {
        "High Value" => order.amount >= 1000000.0,
        "Today" => order.orderDate.contains("11 Jun") || order.orderNo == "2323137",
        "Pending" => order.status == OrderApprovalStatus.pending,
        _ => true,
      };

      final matchesQuery = _searchQuery.isEmpty ||
          order.orderNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.supplier.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.originator.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentView) {
      case ActiveView.login:
        return FlutterLoginScreen(
          usernameController: _usernameController,
          passwordController: _passwordController,
          onLogin: () => _navigateTo(ActiveView.ordersQueue),
        );
      case ActiveView.ordersQueue:
        return FlutterOrdersListScreen(
          orders: _getFilteredOrders,
          selectedCategory: _selectedCategory,
          onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
          onSearchChanged: (query) => setState(() => _searchQuery = query),
          onSelectOrder: _viewOrderDetails,
          onLogout: () {
            setState(() {
              _usernameController.clear();
              _passwordController.clear();
              _currentView = ActiveView.login;
            });
          },
        );
      case ActiveView.orderDetails:
        final order = _orders.firstWhere((o) => o.orderNo == _selectedOrderNo);
        return FlutterOrderDetailsScreen(
          order: order,
          onBack: () => _navigateTo(ActiveView.ordersQueue),
          onApproveOrder: (oNo, r) {
            _approveOrder(oNo);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Order $oNo Approved Successfully!')),
            );
          },
          onRejectOrder: (oNo, r) {
            _rejectOrder(oNo);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Order $oNo Rejected!')),
            );
          },
          onApproveLine: (oNo, lNo, r) {
            _approveLine(oNo, lNo);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Line $lNo Approved!')),
            );
          },
          onRejectLine: (oNo, lNo, r) {
            _rejectLine(oNo, lNo);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Line $lNo Rejected!')),
            );
          },
        );
    }
  }
}

// Extension to mimic list filtering effortlessly
extension IterableFilter<E> on Iterable<E> {
  Iterable<E> filter(bool Function(E element) test) {
    final List<E> result = <E>[];
    for (final E element in this) {
      if (test(element)) {
        result.add(element);
      }
    }
    return result;
  }
}

// ==========================================
// FLUTTER SCREEN 1: LOGIN (VISUAL COPIER)
// ==========================================

class FlutterLoginScreen extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  const FlutterLoginScreen({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.onLogin,
  });

  @override
  State<FlutterLoginScreen> createState() => _FlutterLoginScreenState();
}

class _FlutterLoginScreenState extends State<FlutterLoginScreen> {
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved Wave Custom Painter
            Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 250),
                  painter: CurvedHeaderPainter(),
                ),
                Positioned(
                  top: 50,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Login to continue",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.labelGray,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Username input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "User Name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: widget.usernameController,
                        decoration: InputDecoration(
                          hintText: "Enter your user name",
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.labelGray),
                          filled: true,
                          fillColor: AppColors.customLightGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.borderGray),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.deepBlue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Password input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: widget.passwordController,
                        obscureText: _isPasswordHidden,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.labelGray),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.labelGray,
                            ),
                            onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                          ),
                          filled: true,
                          fillColor: AppColors.customLightGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.borderGray),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.deepBlue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Large Login Action
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: widget.onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Divider
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: Divider(color: AppColors.borderGray)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("OR", style: TextStyle(color: AppColors.labelGray, fontSize: 13)),
                      ),
                      Expanded(child: Divider(color: AppColors.borderGray)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Biometrics Action rows
                  _buildBiometricButton(
                    onPressed: widget.onLogin,
                    icon: Icons.face_retouching_natural_outlined,
                    label: "Login with Face ID",
                  ),
                  const SizedBox(height: 12),
                  _buildBiometricButton(
                    onPressed: widget.onLogin,
                    icon: Icons.fingerprint,
                    label: "Login with Fingerprint",
                  ),

                  const SizedBox(height: 32),

                  // Security Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: AppColors.accentGreen, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Secure • Fast • Reliable",
                        style: TextStyle(color: AppColors.labelGray, fontSize: 12, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderGray),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.labelGray, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: AppColors.darkText, fontSize: 14, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

// Wave Custom background shape
class CurvedHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.deepBlue, Color(0xFF03224B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    final Path path = Path()
      ..lineTo(0, size.height * 0.85)
      ..cubicTo(
        size.width * 0.35,
        size.height * 1.05,
        size.width * 0.65,
        size.height * 0.75,
        size.width,
        size.height * 0.90,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// FLUTTER SCREEN 2: ORDERS LIST
// ==========================================

class FlutterOrdersListScreen extends StatelessWidget {
  final List<ProcurementOrder> orders;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSelectOrder;
  final VoidCallback onLogout;

  const FlutterOrdersListScreen({
    super.key,
    required this.orders,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSearchChanged,
    required this.onSelectOrder,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.customLightGray,
      body: Column(
        children: [
          // Blue Curved header stack containing approver details
          Container(
            color: AppColors.deepBlue,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {},
                    ),
                    const Expanded(
                      child: Text(
                        "Orders Awaiting Approval",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.white),
                          onPressed: () {},
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
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
                      onPressed: onLogout,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      _buildHeaderMeta("APPROVER ID", "1234567"),
                      _buildHeaderMeta("PROJECT", "M30"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filters UI
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
                          border: Border.all(color: AppColors.borderGray),
                        ),
                        child: TextField(
                          onChanged: onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: "Search by Order No., Supplier...",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: AppColors.labelGray),
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
                        color: AppColors.deepBlue,
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

                // Category chips filter
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ["All", "High Value", "Today", "Pending"].map((category) {
                      final bool isSelected = category == selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => onCategoryChanged(category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.deepBlue : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected ? null : Border.all(color: AppColors.borderGray),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.labelGray,
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

          // Core Scrollable List
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text("No templates match the filters."))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final o = orders[index];
                      return _buildOrderCardItem(context, o);
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderMeta(String label, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.labelGray.withOpacity(0.8), fontSize = 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _buildOrderCardItem(BuildContext context, ProcurementOrder o) {
    final Color badgeColor = o.status == OrderApprovalStatus.approved
        ? AppColors.accentGreen
        : (o.status == OrderApprovalStatus.rejected
            ? AppColors.alertRed
            : (o.orderNo == "2323135" ? AppColors.accentBlue : AppColors.accentGreen));

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom = 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onSelectOrder(o.orderNo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top specs row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                    child: const Icon(Icons.description_outlined, color: Colors.white, size = 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Order No.", style: TextStyle(color: AppColors.labelGray, fontSize: 10)),
                        Text(o.orderNo, style: const TextStyle(color: AppColors.darkText, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Amount", style: TextStyle(color: AppColors.labelGray, fontSize: 10)),
                      Text("${o.formattedAmount} ${o.currency}", style: TextStyle(color: badgeColor, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 14),

              // Grid parameters
              _buildMetaGridLine("Originator", o.originator, "Order Type", o.orderType),
              const SizedBox(height = 8),
              _buildMetaGridLine("CO", o.companyCode, "Order Date", o.orderDate),
              const SizedBox(height: 8),
              _buildMetaGridLine("Responsible", o.responsible, "Supplier", o.supplier),

              const SizedBox(height: 14),
              const Divider(color: AppColors.borderGray, height: 1),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.labelGray, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      o.orderDate,
                      style: const TextStyle(color: AppColors.labelGray, fontSize = 11),
                    ),
                  ),
                  if (o.status != OrderApprovalStatus.pending)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: o.status == OrderApprovalStatus.approved
                            ? AppColors.accentGreen.withOpacity(0.15)
                            : AppColors.alertRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        o.status.name.toUpperCase(),
                        style: TextStyle(
                          color: o.status == OrderApprovalStatus.approved ? AppColors.accentGreen : AppColors.alertRed,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Icon(Icons.arrow_right_alt_outlined, color: AppColors.labelGray, size: 18),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaGridLine(String label1, String val1, String label2, String val2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: const TextStyle(color: AppColors.labelGray, fontSize: 11)),
              Text(val1, style: const TextStyle(color: AppColors.darkText, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: const TextStyle(color: AppColors.labelGray, fontSize: 11)),
              Text(val2, style: const TextStyle(color: AppColors.darkText, fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ],
          ),
        )
      ],
    );
  }
}

// ==========================================
// FLUTTER SCREEN 3: SPEC DETAILED WORKFLOW
// ==========================================

class FlutterOrderDetailsScreen extends StatelessWidget {
  final ProcurementOrder order;
  final VoidCallback onBack;
  final Function(String, String) onApproveOrder;
  final Function(String, String) onRejectOrder;
  final Function(String, int, String) onApproveLine;
  final Function(String, int, String) onRejectLine;

  const FlutterOrderDetailsScreen({
    super.key,
    required this.order,
    required this.onBack,
    required this.onApproveOrder,
    required this.onRejectOrder,
    required this.onApproveLine,
    required this.onRejectLine,
  });

  // Modal dialog trigger for decision confirming
  void _showConfirmationPopup({
    required BuildContext context,
    required String title,
    required String body,
    required bool approve,
    required Function(String remarks) onConfirm,
  }) {
    final remarksController = TextEditingController();
    final Color actionColor = approve ? AppColors.accentGreen : AppColors.alertRed;
    final String label = approve ? "Confirm Approval" : "Confirm Rejection";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: actionColor.withOpacity(0.15), shape: BoxShape.circle),
                      child: Icon(approve ? Icons.check_circle : Icons.cancel, color: actionColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize = 17, color: AppColors.darkText),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.labelGray, size = 20),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.borderGray, height: 1),
                const SizedBox(height: 14),

                Text(body, style: const TextStyle(color: AppColors.darkText, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4)),
                const SizedBox(height: 14),

                TextField(
                  controller: remarksController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: approve ? "Remarks (e.g. Budget codes approved)" : "Reason for rejection (MANDATORY)",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: AppColors.customLightGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderGray)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: actionColor)),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderGray),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel", style: TextStyle(color: AppColors.labelGray, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width = 10),
                    Expanded(
                      child: SizedBox(
                        height = 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actionColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (!approve && remarksController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('A justification is required for rejection.')),
                              );
                              return;
                            }
                            Navigator.of(context).pop();
                            onConfirm(remarksController.text);
                          },
                          child: Text(
                            label,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize = 12),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.customLightGray,
      body: Column(
        children: [
          // AppBar Header
          Container(
            color: AppColors.deepBlue,
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // General Specs Card
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
                              decoration: const BoxDecoration(color: AppColors.accentBlue, shape: BoxShape.circle),
                              child: const Icon(Icons.description, color: Colors.white, size = 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Order No.", style: TextStyle(color: AppColors.labelGray, fontSize: 10)),
                                  Text(order.orderNo, style: const TextStyle(color: AppColors.darkText, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.accentGreen),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(order.orderType, style: const TextStyle(color: AppColors.accentGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Specs Grid Column
                        _buildGridDataLine3("Originator", order.originator, "Responsible", order.responsible, "Project", order.project),
                        const SizedBox(height: 12),
                        _buildGridDataLine3("Supplier", order.supplier, "CO", order.companyCode, "Order Date", order.orderDate),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Amount Centered card
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
                        const Text("Order Amount", style: TextStyle(color: AppColors.labelGray, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(order.formattedAmount, style: const TextStyle(color: AppColors.accentGreen, fontSize: 24, fontWeight: FontWeight.black)),
                            Text("  ${order.currency}", style: const TextStyle(color: AppColors.accentGreen, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height = 16),

                // Line Items Title Section
                Row(
                  children: [
                    const Text("Line Items", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.deepBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text("${order.lines.length} item(s)", style: const TextStyle(color: AppColors.deepBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 12),

                // Map specific Line Spec Cards
                ...order.lines.map((l) => _buildLineItemCard(context, l)).toList(),
              ],
            ),
          ),

          // Bottom decision actions block
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.alertRed),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          _showConfirmationPopup(
                            context: context,
                            title: "Reject Order No. ${order.orderNo}",
                            body: "Specify why you are rejecting procurement Order No. ${order.orderNo}:",
                            approve = false,
                            onConfirm: (remarks) => onRejectOrder(order.orderNo, remarks),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.cancel_outlined, color: AppColors.alertRed, size: 18),
                            Text("  Reject", style: TextStyle(color: AppColors.alertRed, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 13,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F9D58),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _showConfirmationPopup(
                            context: context,
                            title: "Approve Order No. ${order.orderNo}",
                            body: "You are about to authorize the full amount of Order No. ${order.orderNo}. Please confirm your action.",
                            approve: true,
                            onConfirm: (remarks) => onApproveOrder(order.orderNo, remarks),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_outline, color: Colors.white, size = 18),
                            Text("  Approve", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGridDataLine3(String l1, String v1, String l2, String v2, String l3, String v3) {
    return Row(
      children: [
        Expanded(child: _buildCell(l1, v1)),
        Expanded(child: _buildCell(l2, v2)),
        Expanded(child: _buildCell(l3, v3)),
      ],
    );
  }

  Widget _buildCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.labelGray, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.darkText, fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildLineItemCard(BuildContext context, OrderLine line) {
    final stripeColor = line.status == OrderApprovalStatus.approved
        ? AppColors.accentGreen
        : (line.status == OrderApprovalStatus.rejected ? AppColors.alertRed : AppColors.statusIndicatorBlue);

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation = 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.values[1], // IntrinsicHeight mock
          children: [
            Container(
              width: 6,
              height: 156, // Fixed height for alignment similarity
              color: stripeColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Line ${line.number}", style: const TextStyle(color: AppColors.statusIndicatorBlue, fontSize: 14, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (line.status == OrderApprovalStatus.pending)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.cancel, color: AppColors.alertRed, size: 20),
                                iconSize = 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _showConfirmationPopup(
                                    context: context,
                                    title: "Reject Line ${line.number}",
                                    body: "Specify why you are declining purchase Line ${line.number}:",
                                    approve = false,
                                    onConfirm: (remarks) => onRejectLine(order.orderNo, line.number, remarks),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 20),
                                iconSize = 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _showConfirmationPopup(
                                    context: context,
                                    title: "Approve Line ${line.number}",
                                    body: "You are about to single-line approve Item code line ${line.number}.",
                                    approve: true,
                                    onConfirm: (remarks) => onApproveLine(order.orderNo, line.number, remarks),
                                  );
                                },
                              )
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: line.status == OrderApprovalStatus.approved
                                  ? AppColors.accentGreen.withOpacity(0.15)
                                  : AppColors.alertRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              line.status.name.toUpperCase(),
                              style: TextStyle(
                                color: line.status == OrderApprovalStatus.approved ? AppColors.accentGreen : AppColors.alertRed,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: AppColors.borderGray, height: 1),
                    const SizedBox(height: 10),

                    // Metal details
                    _buildLineGridRow("Item Code", line.itemCode, "Item Description", line.description),
                    const SizedBox(height: 10),
                    _buildLineGridRow("Requested Date", line.requestedDate, "Quantity", line.quantity),
                    const SizedBox(height: 10),
                    _buildLineGridRow("Unit Cost", "${line.unitCost.toInt()} AED", "Extended Cost", "${line.extendedCost.toInt()} AED"),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLineGridRow(String label1, String val1, String label2, String val2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: const TextStyle(color: AppColors.labelGray, fontSize: 11)),
              Text(val1, style: const TextStyle(color: AppColors.darkText, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          flex: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: const TextStyle(color: AppColors.labelGray, fontSize: 11)),
              Text(val2, style: const TextStyle(color: AppColors.darkText, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ],
          ),
        )
      ],
    );
  }
}
