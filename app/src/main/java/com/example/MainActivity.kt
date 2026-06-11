package com.example

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.ui.theme.MyApplicationTheme

// ==========================================
// DATA MODELS
// ==========================================

enum class OrderApprovalStatus {
    PENDING, APPROVED, REJECTED
}

data class OrderLine(
    val number: Int,
    val itemCode: String,
    val description: String,
    val requestedDate: String,
    val quantity: String,
    val unitCost: Double,
    val extendedCost: Double,
    var status: OrderApprovalStatus = OrderApprovalStatus.PENDING
)

data class Order(
    val orderNo: String,
    val companyCode: String,
    val supplier: String,
    val originator: String,
    val responsible: String,
    val orderType: String,
    val orderDate: String,
    val amount: Double,
    val currency: String = "AED",
    val formattedAmount: String,
    val status: OrderApprovalStatus = OrderApprovalStatus.PENDING,
    val project: String = "M30",
    val lines: List<OrderLine>
)

// ==========================================
// VIEWMODEL FOR STATE MANAGEMENT
// ==========================================

enum class AppScreen {
    LOGIN, INSTANT_LIST, ORDER_DETAILS
}

sealed class DialogState {
    object Dismissed : DialogState()
    data class ConfirmOrder(val orderNo: String, val approve: Boolean) : DialogState()
    data class ConfirmLine(val orderNo: String, val lineNo: Int, val approve: Boolean) : DialogState()
}

class OrderViewModel : ViewModel() {
    var currentScreen by mutableStateOf(AppScreen.LOGIN)
        private set

    var selectedOrderNo by mutableStateOf<String?>(null)
        private set

    var searchQuery by mutableStateOf("")
    var selectedFilterCategory by mutableStateOf("All") // All, High Value, Today, Pending
    var activeDialog by mutableStateOf<DialogState>(DialogState.Dismissed)

    var userNameInput by mutableStateOf("")
    var passwordInput by mutableStateOf("")
    var authenticatedUser by mutableStateOf<String?>(null)

    // In-memory local order data
    var ordersList by mutableStateOf(
        listOf(
            Order(
                orderNo = "2323135",
                companyCode = "00200",
                supplier = "James O''Malley",
                originator = "Anubhav",
                responsible = "Nitya",
                orderType = "OP",
                orderDate = "10 Jun 2026",
                amount = 200020202.0,
                formattedAmount = "200,020,202",
                project = "M30",
                lines = listOf(
                    OrderLine(
                        number = 1,
                        itemCode = "210",
                        description = "Desc1 + Description 2",
                        requestedDate = "10-06-2026",
                        quantity = "31 KG",
                        unitCost = 10.0,
                        extendedCost = 1000.0
                    ),
                    OrderLine(
                        number = 2,
                        itemCode = "215",
                        description = "Desc3 + Spare Materials",
                        requestedDate = "10-06-2026",
                        quantity = "50 Units",
                        unitCost = 40.0,
                        extendedCost = 2000.0
                    )
                )
            ),
            Order(
                orderNo = "2323136",
                companyCode = "00200",
                supplier = "James O''Malley",
                originator = "Hiten",
                responsible = "Nitya",
                orderType = "OP",
                orderDate = "10 Jun 2026",
                amount = 250000000.0,
                formattedAmount = "250,000,000",
                project = "M30",
                lines = listOf(
                    OrderLine(
                        number = 1,
                        itemCode = "310",
                        description = "Bulk Raw materials type A",
                        requestedDate = "10-06-2026",
                        quantity = "200 Liters",
                        unitCost = 15.0,
                        extendedCost = 3000.0
                    )
                )
            ),
            Order(
                orderNo = "2323137",
                companyCode = "00100",
                supplier = "Global Components Corp",
                originator = "James Bond",
                responsible = "Moneypenny",
                orderType = "OP",
                orderDate = "11 Jun 2026",
                amount = 450000.0,
                formattedAmount = "450,000",
                project = "M30",
                lines = listOf(
                    OrderLine(
                        number = 1,
                        itemCode = "500",
                        description = "Secure communications payload hardware config",
                        requestedDate = "11-06-2026",
                        quantity = "2 Units",
                        unitCost = 225000.0,
                        extendedCost = 450000.0
                    )
                )
            )
        )
    )

    fun navigateTo(screen: AppScreen) {
        currentScreen = screen
    }

    fun viewOrderDetails(orderNo: String) {
        selectedOrderNo = orderNo
        navigateTo(AppScreen.ORDER_DETAILS)
    }

    fun tryLogin() {
        authenticatedUser = if (userNameInput.isNotBlank()) userNameInput else "Guest Approver"
        navigateTo(AppScreen.INSTANT_LIST)
    }

    fun logout() {
        authenticatedUser = null
        userNameInput = ""
        passwordInput = ""
        navigateTo(AppScreen.LOGIN)
    }

    fun getFilteredOrders(): List<Order> {
        return ordersList.filter { order ->
            val matchesCategory = when (selectedFilterCategory) {
                "High Value" -> order.amount >= 1000000.0
                "Today" -> order.orderDate.contains("11 Jun") || order.orderNo == "2323137"
                "Pending" -> order.status == OrderApprovalStatus.PENDING
                else -> true
            }

            val matchesQuery = if (searchQuery.isBlank()) {
                true
            } else {
                order.orderNo.contains(searchQuery, ignoreCase = true) ||
                        order.supplier.contains(searchQuery, ignoreCase = true) ||
                        order.originator.contains(searchQuery, ignoreCase = true)
            }

            matchesCategory && matchesQuery
        }
    }

    fun getSelectedOrder(): Order? {
        return ordersList.find { it.orderNo == selectedOrderNo }
    }

    fun processOrderDecision(orderNo: String, approve: Boolean, remarks: String) {
        ordersList = ordersList.map { order ->
            if (order.orderNo == orderNo) {
                val nextStatus = if (approve) OrderApprovalStatus.APPROVED else OrderApprovalStatus.REJECTED
                order.copy(
                    status = nextStatus,
                    lines = order.lines.map { it.copy(status = nextStatus) }
                )
            } else {
                order
            }
        }
        activeDialog = DialogState.Dismissed
    }

    fun processLineDecision(orderNo: String, lineNo: Int, approve: Boolean, remarks: String) {
        ordersList = ordersList.map { order ->
            if (order.orderNo == orderNo) {
                val updatedLines = order.lines.map { line ->
                    if (line.number == lineNo) {
                        line.copy(status = if (approve) OrderApprovalStatus.APPROVED else OrderApprovalStatus.REJECTED)
                    } else {
                        line
                    }
                }
                
                val allApproved = updatedLines.all { it.status == OrderApprovalStatus.APPROVED }
                val anyRejected = updatedLines.any { it.status == OrderApprovalStatus.REJECTED }
                val cumulativeStatus = when {
                    allApproved -> OrderApprovalStatus.APPROVED
                    anyRejected -> OrderApprovalStatus.REJECTED
                    else -> OrderApprovalStatus.PENDING
                }

                order.copy(status = cumulativeStatus, lines = updatedLines)
            } else {
                order
            }
        }
        activeDialog = DialogState.Dismissed
    }
}

// ==========================================
// MAIN COMPOSITION ENTRYPOINT
// ==========================================

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                Scaffold(
                    modifier = Modifier
                        .fillMaxSize()
                        .testTag("main_scaffold"),
                    contentWindowInsets = WindowInsets.safeDrawing
                ) { innerPadding ->
                    val viewModel: OrderViewModel = viewModel()
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerPadding)
                    ) {
                        Crossfade(targetState = viewModel.currentScreen, label = "ScreenTransition") { screen ->
                            when (screen) {
                                AppScreen.LOGIN -> LoginScreen(viewModel)
                                AppScreen.INSTANT_LIST -> OrdersListScreen(viewModel)
                                AppScreen.ORDER_DETAILS -> OrderDetailsScreen(viewModel)
                            }
                        }
                        DecisionConfirmationDialog(viewModel)
                    }
                }
            }
        }
    }
}

// ==========================================
// COLOR PALETTE
// ==========================================

object AppThemeColors {
    val DeepBlue = Color(0xFF021733)
    val AccentBlue = Color(0xFF1E3A5F)
    val CustomLightGray = Color(0xFFF6F8FB)
    val AccentGreen = Color(0xFF1CB55C)
    val AlertRed = Color(0xFFE53935)
    val BorderGray = Color(0xFFE2E8F0)
    val LabelGray = Color(0xFF64748B)
    val DarkText = Color(0xFF0F172A)
}

// ==========================================
// SCREEN 1: LOGIN SCREEN
// ==========================================

@Composable
fun LoginScreen(viewModel: OrderViewModel) {
    var isPassVisible by remember { mutableStateOf(false) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .verticalScroll(rememberScrollState())
    ) {
        // Curve background wave
        Canvas(
            modifier = Modifier
                .fillMaxWidth()
                .height(260.dp)
        ) {
            val wavePath = Path().apply {
                moveTo(0f, 0f)
                lineTo(0f, size.height * 0.85f)
                cubicTo(
                    size.width * 0.35f, size.height * 1.05f,
                    size.width * 0.65f, size.height * 0.75f,
                    size.width, size.height * 0.90f
                )
                lineTo(size.width, 0f)
                close()
            }
            drawPath(
                path = wavePath,
                brush = Brush.verticalGradient(
                    colors = listOf(AppThemeColors.DeepBlue, Color(0xFF03224B))
                )
            )
        }

        IconButton(
            onClick = { },
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(20.dp)
        ) {
            Icon(
                imageVector = Icons.Default.Close,
                contentDescription = "Dismiss app",
                tint = Color.White
            )
        }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 200.dp)
                .clip(RoundedCornerShape(topStart = 32.dp, topEnd = 32.dp))
                .background(Color.White)
                .padding(horizontal = 24.dp, vertical = 28.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Welcome Back",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = AppThemeColors.DeepBlue
            )

            Text(
                text = "Login to continue",
                color = AppThemeColors.LabelGray,
                fontSize = 15.sp,
                modifier = Modifier.padding(top = 4.dp, bottom = 28.dp)
            )

            // User Name Label & Input
            Column(modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp)) {
                Text(
                    text = "User Name",
                    color = AppThemeColors.DarkText,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 14.sp,
                    modifier = Modifier.padding(bottom = 6.dp)
                )
                OutlinedTextField(
                    value = viewModel.userNameInput,
                    onValueChange = { viewModel.userNameInput = it },
                    placeholder = { Text("Enter your user name", color = Color.Gray) },
                    leadingIcon = {
                        Icon(imageVector = Icons.Default.Person, contentDescription = null, tint = AppThemeColors.LabelGray)
                    },
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = AppThemeColors.CustomLightGray,
                        unfocusedContainerColor = AppThemeColors.CustomLightGray,
                        focusedBorderColor = AppThemeColors.DeepBlue,
                        unfocusedBorderColor = AppThemeColors.BorderGray
                    ),
                    modifier = Modifier.fillMaxWidth().testTag("username_input")
                )
            }

            // Password Label & Input
            Column(modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp)) {
                Text(
                    text = "Password",
                    color = AppThemeColors.DarkText,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 14.sp,
                    modifier = Modifier.padding(bottom = 6.dp)
                )
                OutlinedTextField(
                    value = viewModel.passwordInput,
                    onValueChange = { viewModel.passwordInput = it },
                    placeholder = { Text("Enter your password", color = Color.Gray) },
                    leadingIcon = {
                        Icon(imageVector = Icons.Default.Lock, contentDescription = null, tint = AppThemeColors.LabelGray)
                    },
                    trailingIcon = {
                        IconButton(onClick = { isPassVisible = !isPassVisible }) {
                            Icon(
                                imageVector = if (isPassVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                contentDescription = null,
                                tint = AppThemeColors.LabelGray
                            )
                        }
                    },
                    visualTransformation = if (isPassVisible) VisualTransformation.None else PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = AppThemeColors.CustomLightGray,
                        unfocusedContainerColor = AppThemeColors.CustomLightGray,
                        focusedBorderColor = AppThemeColors.DeepBlue,
                        unfocusedBorderColor = AppThemeColors.BorderGray
                    ),
                    modifier = Modifier.fillMaxWidth().testTag("password_input")
                )
            }

            Button(
                onClick = { viewModel.tryLogin() },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 28.dp, bottom = 24.dp)
                    .height(54.dp)
                    .testTag("login_button"),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = AppThemeColors.DeepBlue)
            ) {
                Text("Login", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            }

            Row(
                modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                HorizontalDivider(modifier = Modifier.weight(1f), color = AppThemeColors.BorderGray, thickness = 1.dp)
                Text(
                    text = "OR",
                    color = AppThemeColors.LabelGray,
                    fontSize = 13.sp,
                    modifier = Modifier.padding(horizontal = 16.dp)
                )
                HorizontalDivider(modifier = Modifier.weight(1f), color = AppThemeColors.BorderGray, thickness = 1.dp)
            }

            OutlinedButton(
                onClick = { viewModel.tryLogin() },
                modifier = Modifier.fillMaxWidth().padding(vertical = 6.dp).height(52.dp),
                shape = RoundedCornerShape(12.dp),
                border = BorderStroke(1.dp, AppThemeColors.BorderGray),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = AppThemeColors.DarkText)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.Face, contentDescription = null, tint = AppThemeColors.LabelGray, modifier = Modifier.size(20.dp))
                    Text("  Login with Face ID", fontWeight = FontWeight.Medium, fontSize = 14.sp)
                }
            }

            OutlinedButton(
                onClick = { viewModel.tryLogin() },
                modifier = Modifier.fillMaxWidth().padding(vertical = 6.dp).height(52.dp),
                shape = RoundedCornerShape(12.dp),
                border = BorderStroke(1.dp, AppThemeColors.BorderGray),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = AppThemeColors.DarkText)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.Fingerprint, contentDescription = null, tint = AppThemeColors.LabelGray, modifier = Modifier.size(20.dp))
                    Text("  Login with Fingerprint", fontWeight = FontWeight.Medium, fontSize = 14.sp)
                }
            }

            Spacer(modifier = Modifier.height(28.dp))

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                Icon(imageVector = Icons.Default.CheckCircle, contentDescription = null, tint = AppThemeColors.AccentGreen, modifier = Modifier.size(16.dp))
                Text("  Secure • Fast • Reliable", color = AppThemeColors.LabelGray, fontSize = 12.sp, fontWeight = FontWeight.Medium)
            }
        }
    }
}

// ==========================================
// SCREEN 2: AWAITING APPROVAL QUEUE
// ==========================================

@Composable
fun OrdersListScreen(viewModel: OrderViewModel) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppThemeColors.CustomLightGray)
    ) {
        // App header bar
        Surface(color = AppThemeColors.DeepBlue) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 14.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(onClick = {}) {
                        Icon(imageVector = Icons.Default.Menu, contentDescription = "Menu drawer", tint = Color.White)
                    }
                    Text(
                        text = "Orders Awaiting Approval",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        modifier = Modifier.weight(1f).padding(horizontal = 6.dp),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Box {
                        IconButton(onClick = {}) {
                            Icon(imageVector = Icons.Default.Notifications, contentDescription = "Alerts", tint = Color.White)
                        }
                        Box(
                            modifier = Modifier
                                .size(9.dp)
                                .clip(CircleShape)
                                .background(Color(0xFFFF9800))
                                .align(Alignment.TopEnd)
                                .offset(x = (-6).dp, y = 6.dp)
                        )
                    }
                    IconButton(onClick = { viewModel.logout() }) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "Exit", tint = Color.White)
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                Row(modifier = Modifier.fillMaxWidth().padding(horizontal = 10.dp)) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("APPROVER ID", color = AppThemeColors.LabelGray.copy(alpha = 0.8f), fontSize = 11.sp, fontWeight = FontWeight.Bold)
                        Text("1234567", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 2.dp))
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text("PROJECT", color = AppThemeColors.LabelGray.copy(alpha = 0.8f), fontSize = 11.sp, fontWeight = FontWeight.Bold)
                        Text("M30", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 2.dp))
                    }
                }
                Spacer(modifier = Modifier.height(6.dp))
            }
        }

        // Filters UI
        Column(modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 12.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                OutlinedTextField(
                    value = viewModel.searchQuery,
                    onValueChange = { viewModel.searchQuery = it },
                    placeholder = { Text("Search by Order No., Supplier...", color = Color.Gray, fontSize = 14.sp) },
                    leadingIcon = { Icon(imageVector = Icons.Default.Search, contentDescription = null, tint = AppThemeColors.LabelGray) },
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = Color.White,
                        unfocusedContainerColor = Color.White,
                        focusedBorderColor = AppThemeColors.BorderGray,
                        unfocusedBorderColor = AppThemeColors.BorderGray
                    ),
                    modifier = Modifier.weight(1f).height(52.dp).testTag("search_input"),
                    singleLine = true
                )
                Spacer(modifier = Modifier.width(10.dp))
                Box(
                    modifier = Modifier
                        .size(52.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(AppThemeColors.DeepBlue)
                        .clickable {}
                        .testTag("filter_button"),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(imageVector = Icons.Default.FilterList, contentDescription = null, tint = Color.White)
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            val categoryTabs = listOf("All", "High Value", "Today", "Pending")
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(categoryTabs) { item ->
                    val isTabSelected = viewModel.selectedFilterCategory == item
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(20.dp))
                            .background(if (isTabSelected) AppThemeColors.DeepBlue else Color.White)
                            .border(1.dp, if (isTabSelected) Color.Transparent else AppThemeColors.BorderGray, RoundedCornerShape(20.dp))
                            .clickable { viewModel.selectedFilterCategory = item }
                            .padding(horizontal = 18.dp, vertical = 8.dp)
                            .testTag("chip_$item")
                    ) {
                        Text(
                            text = item,
                            color = if (isTabSelected) Color.White else AppThemeColors.LabelGray,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }

        // List display
        val filteredList = viewModel.getFilteredOrders()
        if (filteredList.isEmpty()) {
            Box(modifier = Modifier.fillMaxWidth().weight(1f), contentAlignment = Alignment.Center) {
                Text("No pending approvals found.", color = AppThemeColors.LabelGray)
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxWidth().weight(1f),
                contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(filteredList) { order ->
                    OrderCardItem(order = order, onSelect = { viewModel.viewOrderDetails(order.orderNo) })
                }
            }
        }
    }
}

// ==========================================
// ORDER SUMMARY LIST ITEM
// ==========================================

@Composable
fun OrderCardItem(order: Order, onSelect: () -> Unit) {
    val statusColor = when (order.status) {
        OrderApprovalStatus.APPROVED -> AppThemeColors.AccentGreen
        OrderApprovalStatus.REJECTED -> AppThemeColors.AlertRed
        OrderApprovalStatus.PENDING -> if (order.orderNo == "2323135") AppThemeColors.AccentBlue else AppThemeColors.AccentGreen
    }

    Card(
        modifier = Modifier.fillMaxWidth().clickable { onSelect() }.testTag("order_card_${order.orderNo}"),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier.size(44.dp).clip(CircleShape).background(statusColor),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(imageVector = Icons.Default.Description, contentDescription = null, tint = Color.White, modifier = Modifier.size(20.dp))
                }
                Spacer(modifier = Modifier.width(10.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text("Order No.", color = AppThemeColors.LabelGray, fontSize = 10.sp)
                    Text(order.orderNo, color = AppThemeColors.DarkText, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                }
                Column(horizontalAlignment = Alignment.End) {
                    Text("Amount", color = AppThemeColors.LabelGray, fontSize = 10.sp)
                    Text("${order.formattedAmount} ${order.currency}", color = statusColor, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            Column(modifier = Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Row(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Originator", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text(order.originator, color = AppThemeColors.DarkText, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Order Type", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text(order.orderType, color = AppThemeColors.DarkText, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                    }
                }
                Row(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("CO", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text(order.companyCode, color = AppThemeColors.DarkText, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Order Date", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text(order.orderDate, color = AppThemeColors.DarkText, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                    }
                }
                Row(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Responsible", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text(order.responsible, color = AppThemeColors.DarkText, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Supplier", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text(order.supplier, color = AppThemeColors.DarkText, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    }
                }
            }

            Spacer(modifier = Modifier.height(14.dp))
            HorizontalDivider(color = AppThemeColors.BorderGray, thickness = 1.dp)
            Spacer(modifier = Modifier.height(10.dp))

            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = Icons.Default.CalendarToday, contentDescription = null, tint = AppThemeColors.LabelGray, modifier = Modifier.size(14.dp))
                Text("  ${order.orderDate}", color = AppThemeColors.LabelGray, fontSize = 11.sp, modifier = Modifier.weight(1f))

                if (order.status != OrderApprovalStatus.PENDING) {
                    Box(
                        modifier = Modifier
                            .padding(end = 8.dp)
                            .clip(RoundedCornerShape(4.dp))
                            .background(if (order.status == OrderApprovalStatus.APPROVED) AppThemeColors.AccentGreen.copy(alpha = 0.15f) else AppThemeColors.AlertRed.copy(alpha = 0.15f))
                            .padding(horizontal = 8.dp, vertical = 2.dp)
                    ) {
                        Text(order.status.name, color = if (order.status == OrderApprovalStatus.APPROVED) AppThemeColors.AccentGreen else AppThemeColors.AlertRed, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                    }
                }

                Icon(imageVector = Icons.Default.ArrowRight, contentDescription = null, tint = AppThemeColors.LabelGray, modifier = Modifier.size(16.dp))
            }
        }
    }
}

// ==========================================
// SCREEN 3: SPECIFIC ORDER SPECS DETAILS
// ==========================================

@Composable
fun OrderDetailsScreen(viewModel: OrderViewModel) {
    val order = viewModel.getSelectedOrder() ?: return

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppThemeColors.CustomLightGray)
    ) {
        Surface(color = AppThemeColors.DeepBlue) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = { viewModel.navigateTo(AppScreen.INSTANT_LIST) }) {
                    Icon(imageVector = Icons.Default.ArrowBack, contentDescription = null, tint = Color.White)
                }
                Text(
                    text = "Order Details",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    modifier = Modifier.weight(1f).padding(horizontal = 8.dp)
                )
                IconButton(onClick = { viewModel.navigateTo(AppScreen.INSTANT_LIST) }) {
                    Icon(imageVector = Icons.Default.Close, contentDescription = null, tint = Color.White)
                }
            }
        }

        LazyColumn(
            modifier = Modifier.fillMaxWidth().weight(1f),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                modifier = Modifier.size(44.dp).clip(CircleShape).background(AppThemeColors.AccentBlue),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(imageVector = Icons.Default.Description, contentDescription = null, tint = Color.White, modifier = Modifier.size(20.dp))
                            }
                            Spacer(modifier = Modifier.width(12.dp))
                            Column(modifier = Modifier.weight(1f)) {
                                Text("Order No.", color = AppThemeColors.LabelGray, fontSize = 10.sp)
                                Text(order.orderNo, color = AppThemeColors.DarkText, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                            }
                            Box(
                                modifier = Modifier
                                    .border(1.dp, AppThemeColors.AccentGreen, RoundedCornerShape(6.dp))
                                    .padding(horizontal = 10.dp, vertical = 4.dp)
                            ) {
                                Text(order.orderType, color = AppThemeColors.AccentGreen, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                            }
                        }

                        Spacer(modifier = Modifier.height(18.dp))

                        Column(modifier = Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                            Row(modifier = Modifier.fillMaxWidth()) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("Originator", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                                    Text(order.originator, color = AppThemeColors.DarkText, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                                }
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("Responsible", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                                    Text(order.responsible, color = AppThemeColors.DarkText, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                                }
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("Project", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                                    Text(order.project, color = AppThemeColors.DarkText, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                            Row(modifier = Modifier.fillMaxWidth()) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("Supplier", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                                    Text(order.supplier, color = AppThemeColors.DarkText, fontSize = 14.sp, fontWeight = FontWeight.Bold, maxLines = 1, overflow = TextOverflow.Ellipsis)
                                }
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("CO", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                                    Text(order.companyCode, color = AppThemeColors.DarkText, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                                }
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("Order Date", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                                    Text(order.orderDate, color = AppThemeColors.DarkText, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                        }
                    }
                }
            }

            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("Order Amount", color = AppThemeColors.LabelGray, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        Spacer(modifier = Modifier.height(4.dp))
                        Row(verticalAlignment = Alignment.Bottom) {
                            Text(order.formattedAmount, color = AppThemeColors.AccentGreen, fontSize = 24.sp, fontWeight = FontWeight.Black)
                            Text("  ${order.currency}", color = AppThemeColors.AccentGreen, fontSize = 15.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(bottom = 2.dp))
                        }
                    }
                }
            }

            item {
                Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text("Line Items", fontSize = 16.sp, fontWeight = FontWeight.Black, color = AppThemeColors.DarkText, modifier = Modifier.weight(1f))
                    Box(
                        modifier = Modifier.clip(RoundedCornerShape(10.dp)).background(AppThemeColors.DeepBlue.copy(alpha = 0.1f)).padding(horizontal = 8.dp, vertical = 2.dp)
                    ) {
                        Text("${order.lines.size} item(s)", color = AppThemeColors.DeepBlue, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }

            items(order.lines) { line ->
                LineItemCard(orderNo = order.orderNo, line = line, viewModel = viewModel)
            }
        }

        Surface(color = Color.White, shadowElevation = 12.dp, border = BorderStroke(1.dp, AppThemeColors.BorderGray)) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 14.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                OutlinedButton(
                    onClick = { viewModel.activeDialog = DialogState.ConfirmOrder(order.orderNo, approve = false) },
                    modifier = Modifier.weight(1f).height(50.dp).testTag("reject_order_button"),
                    shape = RoundedCornerShape(12.dp),
                    border = BorderStroke(1.dp, AppThemeColors.AlertRed),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = AppThemeColors.AlertRed)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(imageVector = Icons.Default.Cancel, contentDescription = null, tint = AppThemeColors.AlertRed, modifier = Modifier.size(18.dp))
                        Text("  Reject", fontSize = 14.sp, fontWeight = FontWeight.Bold)
                    }
                }

                Button(
                    onClick = { viewModel.activeDialog = DialogState.ConfirmOrder(order.orderNo, approve = true) },
                    modifier = Modifier.weight(1.3f).height(50.dp).testTag("approve_order_button"),
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF0F9D58))
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(imageVector = Icons.Default.CheckCircle, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                        Text("  Approve", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    }
                }
            }
        }
    }
}

// ==========================================
// LINE SPEC CARD COMPONENT WITH BLUE STRIPE
// ==========================================

@Composable
fun LineItemCard(orderNo: String, line: OrderLine, viewModel: OrderViewModel) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(modifier = Modifier.fillMaxWidth().height(IntrinsicSize.Min)) {
            // Visual left border stripe
            val stripeColor = when (line.status) {
                OrderApprovalStatus.APPROVED -> AppThemeColors.AccentGreen
                OrderApprovalStatus.REJECTED -> AppThemeColors.AlertRed
                OrderApprovalStatus.PENDING -> Color(0xFF1976D2)
            }
            Box(
                modifier = Modifier
                    .width(6.dp)
                    .fillMaxHeight()
                    .background(stripeColor)
            )

            Column(modifier = Modifier.weight(1f).padding(14.dp)) {
                Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text("Line ${line.number}", color = Color(0xFF1976D2), fontSize = 14.sp, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))

                    if (line.status == OrderApprovalStatus.PENDING) {
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            IconButton(onClick = { viewModel.activeDialog = DialogState.ConfirmLine(orderNo, line.number, approve = false) }, modifier = Modifier.size(24.dp)) {
                                Icon(imageVector = Icons.Default.Cancel, contentDescription = null, tint = AppThemeColors.AlertRed, modifier = Modifier.size(18.dp))
                            }
                            IconButton(onClick = { viewModel.activeDialog = DialogState.ConfirmLine(orderNo, line.number, approve = true) }, modifier = Modifier.size(24.dp)) {
                                Icon(imageVector = Icons.Default.CheckCircle, contentDescription = null, tint = AppThemeColors.AccentGreen, modifier = Modifier.size(18.dp))
                            }
                        }
                    } else {
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(if (line.status == OrderApprovalStatus.APPROVED) AppThemeColors.AccentGreen.copy(alpha = 0.15f) else AppThemeColors.AlertRed.copy(alpha = 0.15f))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text(line.status.name, color = if (line.status == OrderApprovalStatus.APPROVED) AppThemeColors.AccentGreen else AppThemeColors.AlertRed, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))
                HorizontalDivider(color = AppThemeColors.BorderGray, thickness = 1.dp)
                Spacer(modifier = Modifier.height(10.dp))

                Row(modifier = Modifier.fillMaxWidth().padding(bottom = 10.dp)) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Item Code", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text(line.itemCode, color = AppThemeColors.DarkText, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                    Column(modifier = Modifier.weight(1.8f)) {
                        Text("Item Description", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text(line.description, color = AppThemeColors.DarkText, fontSize = 12.sp, fontWeight = FontWeight.Bold, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    }
                }

                Row(modifier = Modifier.fillMaxWidth().padding(bottom = 10.dp)) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Requested Date", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text(line.requestedDate, color = AppThemeColors.DarkText, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                    Column(modifier = Modifier.weight(1.8f)) {
                        Text("Quantity", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text(line.quantity, color = AppThemeColors.DarkText, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                }

                Row(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Unit Cost", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text("${line.unitCost.toInt()} AED", color = AppThemeColors.DarkText, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                    Column(modifier = Modifier.weight(1.8f)) {
                        Text("Extended Cost", color = AppThemeColors.LabelGray, fontSize = 11.sp)
                        Text("${line.extendedCost.toInt()} AED", color = AppThemeColors.DarkText, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

// ==========================================
// CENTRAL PROCEDURAL ACTION MODAL POPUP
// ==========================================

@Composable
fun DecisionConfirmationDialog(viewModel: OrderViewModel) {
    val dialogState = viewModel.activeDialog
    if (dialogState == DialogState.Dismissed) return

    val context = LocalContext.current
    var remarks by remember { mutableStateOf("") }

    val isApprove = when (dialogState) {
        is DialogState.ConfirmOrder -> dialogState.approve
        is DialogState.ConfirmLine -> dialogState.approve
        else -> false
    }

    val titleText = when (dialogState) {
        is DialogState.ConfirmOrder -> if (isApprove) "Approve Order No. ${dialogState.orderNo}" else "Reject Order No. ${dialogState.orderNo}"
        is DialogState.ConfirmLine -> if (isApprove) "Approve Line ${dialogState.lineNo}" else "Reject Line ${dialogState.lineNo}"
        else -> ""
    }

    val bodyMsg = when (dialogState) {
        is DialogState.ConfirmOrder -> if (isApprove) "You are about to authorize the full amount of Order No. ${dialogState.orderNo}. Please confirm your action." else "Specify why you are rejecting procurement Order No. ${dialogState.orderNo}:"
        is DialogState.ConfirmLine -> if (isApprove) "You are about to single-line approve Item code line ${dialogState.lineNo}." else "Specify why you are declining purchase Line ${dialogState.lineNo}:"
        else -> ""
    }

    val actionThemeColor = if (isApprove) AppThemeColors.AccentGreen else AppThemeColors.AlertRed
    val actionLabel = if (isApprove) "Confirm Approval" else "Confirm Rejection"

    Dialog(
        onDismissRequest = { viewModel.activeDialog = DialogState.Dismissed },
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.5f))
                .clickable { viewModel.activeDialog = DialogState.Dismissed },
            contentAlignment = Alignment.Center
        ) {
            Card(
                modifier = Modifier.fillMaxWidth(0.9f).clickable(enabled = false) {},
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Column(modifier = Modifier.padding(20.dp)) {
                    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier.size(36.dp).clip(CircleShape).background(actionThemeColor.copy(alpha = 0.15f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = if (isApprove) Icons.Default.CheckCircle else Icons.Default.Cancel,
                                contentDescription = null,
                                tint = actionThemeColor,
                                modifier = Modifier.size(20.dp)
                            )
                        }
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(text = titleText, fontSize = 17.sp, fontWeight = FontWeight.Bold, color = AppThemeColors.DarkText, modifier = Modifier.weight(1f))
                        IconButton(onClick = { viewModel.activeDialog = DialogState.Dismissed }, modifier = Modifier.size(24.dp)) {
                            Icon(imageVector = Icons.Default.Close, contentDescription = null, tint = AppThemeColors.LabelGray)
                        }
                    }

                    Spacer(modifier = Modifier.height(14.dp))
                    HorizontalDivider(color = AppThemeColors.BorderGray, thickness = 1.dp)
                    Spacer(modifier = Modifier.height(14.dp))

                    Text(text = bodyMsg, color = AppThemeColors.DarkText, fontSize = 14.sp, fontWeight = FontWeight.Medium, lineHeight = 20.sp)
                    Spacer(modifier = Modifier.height(12.dp))

                    OutlinedTextField(
                        value = remarks,
                        onValueChange = { remarks = it },
                        placeholder = {
                            Text(
                                if (isApprove) "Remarks (e.g. Budget codes approved, matches RFQ)" else "Reason for rejection (MANDATORY)",
                                color = Color.Gray,
                                fontSize = 13.sp
                            )
                        },
                        minLines = 3,
                        maxLines = 4,
                        shape = RoundedCornerShape(10.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedContainerColor = AppThemeColors.CustomLightGray,
                            unfocusedContainerColor = AppThemeColors.CustomLightGray,
                            focusedBorderColor = actionThemeColor,
                            unfocusedBorderColor = AppThemeColors.BorderGray
                        ),
                        modifier = Modifier.fillMaxWidth().testTag("dialog_remarks_input")
                    )

                    Spacer(modifier = Modifier.height(20.dp))

                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        OutlinedButton(
                            onClick = { viewModel.activeDialog = DialogState.Dismissed },
                            modifier = Modifier.weight(1f).height(46.dp).testTag("dialog_cancel_button"),
                            shape = RoundedCornerShape(10.dp),
                            border = BorderStroke(1.dp, AppThemeColors.BorderGray),
                            colors = ButtonDefaults.outlinedButtonColors(contentColor = AppThemeColors.LabelGray)
                        ) {
                            Text("Cancel", fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        }

                        Button(
                            onClick = {
                                if (!isApprove && remarks.isBlank()) {
                                    Toast.makeText(context, "A justification reason is required for rejection.", Toast.LENGTH_SHORT).show()
                                } else {
                                    when (dialogState) {
                                        is DialogState.ConfirmOrder -> {
                                            viewModel.processOrderDecision(dialogState.orderNo, isApprove, remarks)
                                            val act = if (isApprove) "Approved" else "Rejected"
                                            Toast.makeText(context, "Order ${dialogState.orderNo} $act!", Toast.LENGTH_SHORT).show()
                                        }
                                        is DialogState.ConfirmLine -> {
                                            viewModel.processLineDecision(dialogState.orderNo, dialogState.lineNo, isApprove, remarks)
                                            val act = if (isApprove) "Approved" else "Rejected"
                                            Toast.makeText(context, "Line ${dialogState.lineNo} $act!", Toast.LENGTH_SHORT).show()
                                        }
                                        else -> {}
                                    }
                                }
                            },
                            modifier = Modifier.weight(1.3f).height(46.dp).testTag("dialog_confirm_button"),
                            shape = RoundedCornerShape(10.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = actionThemeColor)
                        ) {
                            Text(text = actionLabel, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    }
                }
            }
        }
    }
}
