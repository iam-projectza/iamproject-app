// lib/src/widgets/order_confirmation_modal.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/colors.dart';
import '../utils/app_constants.dart';
import '../utils/dimensions.dart';
import '../widgets/big_text.dart';
import '../widgets/small_text.dart';

class OrderConfirmationModal extends StatefulWidget {
  final double subtotal;
  final Function(bool acceptDeliveryCost, String deliveryType) onConfirm;

  const OrderConfirmationModal({
    Key? key,
    required this.subtotal,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<OrderConfirmationModal> createState() => _OrderConfirmationModalState();
}

class _OrderConfirmationModalState extends State<OrderConfirmationModal> {
  bool _acceptDeliveryCost = false;
  String _selectedDeliveryType = 'standard'; // 'standard' or 'express'
  bool _understandTerms = false;

  double get deliveryCost {
    if (widget.subtotal >= AppConstants.FREE_DELIVERY_THRESHOLD) {
      return 0.0;
    }
    return _selectedDeliveryType == 'express'
        ? AppConstants.EXPRESS_DELIVERY_COST
        : AppConstants.STANDARD_DELIVERY_COST;
  }

  double get totalAmount {
    return widget.subtotal + deliveryCost;
  }

  bool get isEligibleForFreeDelivery {
    return widget.subtotal >= AppConstants.FREE_DELIVERY_THRESHOLD;
  }

  void _launchDeliveryInfo() async {
    const url = 'https://your-website.com/delivery-information'; // Replace with your actual URL
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar(
        'Error',
        'Could not open delivery information',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width20 = Dimensions.width20 ?? 20.0;
    final height15 = Dimensions.height15 ?? 15.0;
    final height10 = Dimensions.height10 ?? 10.0;
    final radius20 = Dimensions.radius20 ?? 20.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius20),
      ),
      child: Container(
        padding: EdgeInsets.all(width20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: BigText(
                  text: 'Confirm Your Order',
                  size: 22,
                  color: AppColors.mainBlackColor,
                ),
              ),
              SizedBox(height: height15),

              // Order Summary
              _buildOrderSummary(),
              SizedBox(height: height15),

              // Delivery Options
              _buildDeliveryOptions(),
              SizedBox(height: height15),

              // Delivery Cost Acceptance
              _buildDeliveryCostAcceptance(),
              SizedBox(height: height15),

              // Terms and Conditions
              _buildTermsAndConditions(),
              SizedBox(height: 20),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(Dimensions.width15 ?? 15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(Dimensions.radius15 ?? 15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallText(text: 'Subtotal:'),
              SmallText(text: 'R${widget.subtotal.toStringAsFixed(2)}'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallText(text: 'Delivery:'),
              SmallText(
                text: deliveryCost == 0
                    ? 'FREE'
                    : 'R${deliveryCost.toStringAsFixed(2)}',
                color: deliveryCost == 0 ? Colors.green : AppColors.mainBlackColor,

              ),
            ],
          ),
          Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BigText(
                text: 'Total:',
                size: 18,
                color: AppColors.mainBlackColor,
              ),
              BigText(
                text: 'R${totalAmount.toStringAsFixed(2)}',
                size: 18,
                color: AppColors.mainColor,
              ),
            ],
          ),
          if (isEligibleForFreeDelivery) ...[
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_shipping, color: Colors.green, size: 16),
                  SizedBox(width: 6),
                  SmallText(
                    text: 'Free Delivery Applied!',
                    color: Colors.green,

                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BigText(
          text: 'Delivery Option',
          size: 16,
          color: AppColors.mainBlackColor,
        ),
        SizedBox(height: 10),

        // Standard Delivery
        _buildDeliveryOption(
          value: 'standard',
          title: 'Standard Delivery',
          cost: isEligibleForFreeDelivery ? 0.0 : AppConstants.STANDARD_DELIVERY_COST,
          time: AppConstants.STANDARD_DELIVERY_TIME,
          isSelected: _selectedDeliveryType == 'standard',
        ),
        SizedBox(height: 10),

        // Express Delivery
        _buildDeliveryOption(
          value: 'express',
          title: 'Express Delivery',
          cost: isEligibleForFreeDelivery ? 0.0 : AppConstants.EXPRESS_DELIVERY_COST,
          time: AppConstants.EXPRESS_DELIVERY_TIME,
          isSelected: _selectedDeliveryType == 'express',
        ),

        // Delivery Info Link
        GestureDetector(
          onTap: _launchDeliveryInfo,
          child: Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: AppColors.iSecondaryColor, size: 16),
                SizedBox(width: 6),
                SmallText(
                  text: 'Learn more about our delivery options',
                  color: AppColors.iSecondaryColor,

                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryOption({
    required String value,
    required String title,
    required double cost,
    required String time,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliveryType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15 ?? 15),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.iSecondaryColor!.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(Dimensions.radius15 ?? 15),
          border: Border.all(
            color: isSelected ? AppColors.iSecondaryColor! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.iSecondaryColor! : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.iSecondaryColor,
                  ),
                ),
              )
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainBlackColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              cost == 0 ? 'FREE' : 'R${cost.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cost == 0 ? Colors.green : AppColors.mainBlackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCostAcceptance() {
    return Container(
      padding: EdgeInsets.all(Dimensions.width15 ?? 15),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(Dimensions.radius15 ?? 15),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _acceptDeliveryCost,
            onChanged: (value) {
              setState(() {
                _acceptDeliveryCost = value ?? false;
              });
            },
            activeColor: AppColors.iSecondaryColor,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'I understand and accept the delivery cost',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainBlackColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This cost covers fuel, vehicle maintenance, and delivery personnel.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: _understandTerms,
          onChanged: (value) {
            setState(() {
              _understandTerms = value ?? false;
            });
          },
          activeColor: AppColors.iSecondaryColor,
        ),
        Expanded(
          child: Text(
            'I agree to the Terms & Conditions and Privacy Policy',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    bool canProceed = _acceptDeliveryCost && _understandTerms;

    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Get.back();
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius15 ?? 15),
              ),
              side: BorderSide(color: Colors.grey),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ),
        SizedBox(width: 10),

        // Confirm Order Button
        Expanded(
          child: ElevatedButton(
            onPressed: canProceed
                ? () {
              // Close modal and return the selection
              Get.back();
              widget.onConfirm(_acceptDeliveryCost, _selectedDeliveryType);
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canProceed ? AppColors.iSecondaryColor : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius15 ?? 15),
              ),
            ),
            child: Text('Confirm Order'),
          ),
        ),
      ],
    );
  }
}