/*
=======================================================================================================================================
Order Detail Screen - The Nook of Welshpool
=======================================================================================================================================
This screen displays detailed information for a specific order including:
- Order items and customisation details
- Delivery/collection information
- Status tracking timeline
- Contact information for order issues
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import '../services/store_info_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderDetail? _order;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _storePhone = '01938 123456';
  bool _isLoadingContactInfo = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
    _loadContactInfo();
  }

  Future<void> _loadOrderDetails() async {
    final user = AuthService.currentUser;
    if (user == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Please log in to view order details';
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await OrderService.getOrderDetails(
        userId: user.id,
        orderId: widget.orderId,
      );
      
      setState(() {
        if (result.success) {
          _order = result.order;
          _hasError = false;
        } else {
          _hasError = true;
          _errorMessage = result.message;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load order details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadContactInfo() async {
    try {
      final phone = await StoreInfoService.getStorePhone();
      setState(() {
        _storePhone = phone;
        _isLoadingContactInfo = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingContactInfo = false;
      });
    }
  }

  Future<void> _refreshOrder() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await _loadOrderDetails();
  }


  Widget _buildStatusTimeline() {
    if (_order == null || _order!.statusHistory.isEmpty) {
      return Container();
    }

    final statusOrder = ['pending', 'preparing', 'ready', 'completed'];
    final currentStatusIndex = statusOrder.indexOf(_order!.orderStatus.toLowerCase());
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C3E50),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          
          // Status timeline
          Column(
            children: statusOrder.asMap().entries.map((entry) {
              final index = entry.key;
              final status = entry.value;
              final isCompleted = index <= currentStatusIndex;
              final isCurrent = index == currentStatusIndex;
              final isLast = index == statusOrder.length - 1;
              
              String statusDisplay;
              switch (status) {
                case 'pending':
                  statusDisplay = 'Order Pending';
                  break;
                case 'preparing':
                  statusDisplay = 'Preparing Your Order';
                  break;
                case 'ready':
                  statusDisplay = 'Ready for ${_order!.deliveryType == 'delivery' ? 'Delivery' : 'Collection'}';
                  break;
                case 'completed':
                  statusDisplay = 'Order Completed';
                  break;
                default:
                  statusDisplay = status.toUpperCase();
              }
              
              // Find matching status history entry
              final historyEntry = _order!.statusHistory.where(
                (h) => h.status.toLowerCase() == status
              ).isNotEmpty ? _order!.statusHistory.firstWhere(
                (h) => h.status.toLowerCase() == status
              ) : null;
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted 
                              ? const Color(0xFF3498DB)
                              : const Color(0xFFE0E6ED),
                          border: Border.all(
                            color: isCurrent 
                                ? const Color(0xFF3498DB)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: isCompleted 
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                      if (!isLast) ...[
                        Container(
                          width: 2,
                          height: 40,
                          color: isCompleted 
                              ? const Color(0xFF3498DB).withValues(alpha: 0.3)
                              : const Color(0xFFE0E6ED),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Status info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusDisplay,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
                            color: isCompleted 
                                ? const Color(0xFF2C3E50)
                                : const Color(0xFF7F8C8D),
                          ),
                        ),
                        if (historyEntry != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm').format(historyEntry.createdAt),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7F8C8D),
                            ),
                          ),
                          if (historyEntry.notes != null && historyEntry.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              historyEntry.notes!,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF7F8C8D),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                        if (!isLast) const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    if (_order == null) return Container();
    
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Information',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C3E50),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          
          // Order details
          _buildInfoRow('Order Number', _order!.orderNumber),
          _buildInfoRow('Date', dateFormat.format(_order!.requestedDate)),
          _buildInfoRow('Time', timeFormat.format(_order!.requestedTime)),
          _buildInfoRow('Type', _order!.deliveryType == 'delivery' ? 'Delivery' : 'Collection'),
          
          if (_order!.deliveryAddress != null && _order!.deliveryAddress!.isNotEmpty) ...[
            _buildInfoRow('Delivery Address', _order!.deliveryAddress!),
          ],
          
          if (_order!.specialInstructions != null && _order!.specialInstructions!.isNotEmpty) ...[
            _buildInfoRow('Special Instructions', _order!.specialInstructions!),
          ],
          
          _buildInfoRow('Total', '£${_order!.totalAmount.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF7F8C8D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? const Color(0xFF2C3E50) : const Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    if (_order == null || _order!.items.isEmpty) return Container();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C3E50),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          
          ..._order!.items.map((item) => _buildItemCard(item)),
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E6ED),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.categoryName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ),
              Text(
                '£${item.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.quantity} ${item.quantity == 1 ? 'item' : 'items'} × £${item.unitPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          
          // Department label
          if (item.departmentLabel != null && item.departmentLabel!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF3498DB).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Department: ${item.departmentLabel}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: const Color(0xFF3498DB),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          
          // Deluxe format
          if (item.deluxeFormat != null && item.deluxeFormat!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF9B59B6).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Format: ${item.deluxeFormat}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: const Color(0xFF9B59B6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          
          // Included items
          if (item.includedItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Included Items:',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.includedItems.map((menuItem) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    menuItem.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: const Color(0xFF27AE60),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need Help?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C3E50),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'If you have any questions about your order, please contact us:',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                color: const Color(0xFF3498DB),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                _isLoadingContactInfo ? 'Loading...' : _storePhone,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Please have your order number (${_order?.orderNumber ?? 'Unknown'}) ready when calling.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7F8C8D),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          _order != null ? 'Order ${_order!.orderNumber}' : 'Order Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _refreshOrder,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF3498DB),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading order details...',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              )
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: const Color(0xFFE74C3C),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Order',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7F8C8D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _refreshOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatusTimeline(),
                        const SizedBox(height: 16),
                        _buildOrderInfo(),
                        const SizedBox(height: 16),
                        _buildOrderItems(),
                        const SizedBox(height: 16),
                        _buildContactInfo(),
                      ],
                    ),
                  ),
      ),
    );
  }
}