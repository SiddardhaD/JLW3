import 'package:flutter/material.dart';
import 'models/order.dart';
import 'screens/login_screen.dart';
import 'screens/orders_list_screen.dart';
import 'screens/order_details_screen.dart';

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

enum AppActiveScreen { login, ordersList, orderDetails }

class MainRouterScreen extends StatefulWidget {
  const MainRouterScreen({super.key});

  @override
  State<MainRouterScreen> createState() => _MainRouterScreenState();
}

class _MainRouterScreenState extends State<MainRouterScreen> {
  AppActiveScreen _activeScreen = AppActiveScreen.login;
  String? _selectedOrderNo;
  String? _authenticatedUser;

  // In-memory replicated procurement orders database
  late List<ProcurementOrder> _ordersList;

  @override
  void initState() {
    super.initState();
    _resetOrders();
  }

  void _resetOrders() {
    _ordersList = [
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
        companyCode: "00200",
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
            number: 1,
            itemCode: "310",
            description: "Bulk Raw materials type A",
            requestedDate: "10-06-2026",
            quantity: "200 Liters",
            unitCost: 15.0,
            extendedCost: 3000.0,
          )
        ],
      ),
      ProcurementOrder(
        orderNo: "2323137",
        companyCode: "00100",
        supplier: "Global Components Corp",
        originator: "James Bond",
        responsible: "Moneypenny",
        orderType: "OP",
        orderDate: "11 Jun 2026",
        amount: 450000.0,
        formattedAmount: "450,000",
        project: "M30",
        lines: [
          OrderLine(
            number: 1,
            itemCode: "500",
            description: "Secure communications payload hardware config",
            requestedDate = "11-06-2026",
            quantity: "2 Units",
            unitCost: 225000.0,
            extendedCost: 450000.0,
          )
        ],
      )
    ];
  }

  void _handleLoginSuccess(String name) {
    setState(() {
      _authenticatedUser = name;
      _activeScreen = AppActiveScreen.ordersList;
    });
  }

  void _handleLogout() {
    setState(() {
      _authenticatedUser = null;
      _activeScreen = AppActiveScreen.login;
    });
  }

  void _handleSelectOrder(String orderNo) {
    setState(() {
      _selectedOrderNo = orderNo;
      _activeScreen = AppActiveScreen.orderDetails;
    });
  }

  void _handleApproveOrder(String orderNo) {
    setState(() {
      _ordersList = _ordersList.map((o) {
        if (o.orderNo == orderNo) {
          final approvedLines = o.lines.map((l) => l.copyWith(status: OrderApprovalStatus.approved)).toList();
          return o.copyWith(status: OrderApprovalStatus.approved, lines: approvedLines);
        }
        return o;
      }).toList();
      _activeScreen = AppActiveScreen.ordersList;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order $orderNo Approved successfully!"),
        backgroundColor: const Color(0xFF1CB55C),
      ),
    );
  }

  void _handleRejectOrder(String orderNo) {
    setState(() {
      _ordersList = _ordersList.map((o) {
        if (o.orderNo == orderNo) {
          final rejectedLines = o.lines.map((l) => l.copyWith(status: OrderApprovalStatus.rejected)).toList();
          return o.copyWith(status: OrderApprovalStatus.rejected, lines: rejectedLines);
        }
        return o;
      }).toList();
      _activeScreen = AppActiveScreen.ordersList;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order $orderNo Rejected!"),
        backgroundColor: const Color(0xFFE53935),
      ),
    );
  }

  void _handleApproveLine(String orderNo, int lineNo) {
    setState(() {
      _ordersList = _ordersList.map((o) {
        if (o.orderNo == orderNo) {
          final updatedLines = o.lines.map((l) {
            if (l.number == lineNo) {
              return l.copyWith(status: OrderApprovalStatus.approved);
            }
            return l;
          }).toList();

          final allApproved = updatedLines.every((l) => l.status == OrderApprovalStatus.approved);
          final anyRejected = updatedLines.any((l) => l.status == OrderApprovalStatus.rejected);
          final statusResult = allApproved
              ? OrderApprovalStatus.approved
              : (anyRejected ? OrderApprovalStatus.rejected : OrderApprovalStatus.pending);

          return o.copyWith(status: statusResult, lines: updatedLines);
        }
        return o;
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Line item approved successfully!"),
        backgroundColor: Color(0xFF1CB55C),
      ),
    );
  }

  void _handleRejectLine(String orderNo, int lineNo) {
    setState(() {
      _ordersList = _ordersList.map((o) {
        if (o.orderNo == orderNo) {
          final updatedLines = o.lines.map((l) {
            if (l.number == lineNo) {
              return l.copyWith(status: OrderApprovalStatus.rejected);
            }
            return l;
          }).toList();

          final allApproved = updatedLines.every((l) => l.status == OrderApprovalStatus.approved);
          final anyRejected = updatedLines.any((l) => l.status == OrderApprovalStatus.rejected);
          final statusResult = allApproved
              ? OrderApprovalStatus.approved
              : (anyRejected ? OrderApprovalStatus.rejected : OrderApprovalStatus.pending);

          return o.copyWith(status: statusResult, lines: updatedLines);
        }
        return o;
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Line item rejected successfully."),
        backgroundColor: Color(0xFFE53935),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_activeScreen) {
      case AppActiveScreen.login:
        return LoginScreen(onLoginSuccess: _handleLoginSuccess);
      case AppActiveScreen.ordersList:
        return OrdersListScreen(
          orders: _ordersList,
          onLogout: _handleLogout,
          onSelectOrder: _handleSelectOrder,
        );
      case AppActiveScreen.orderDetails:
        final order = _ordersList.firstWhere((o) => o.orderNo == _selectedOrderNo);
        return OrderDetailsScreen(
          order: order,
          onBack: () => setState(() => _activeScreen = AppActiveScreen.ordersList),
          onApproveOrder: _handleApproveOrder,
          onRejectOrder: _handleRejectOrder,
          onApproveLine: _handleApproveLine,
          onRejectLine: _handleRejectLine,
        );
    }
  }
}
