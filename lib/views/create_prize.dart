import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/prize.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';

enum PrizeType { amount, percentage }

class CreatePrize extends StatefulWidget {
  const CreatePrize({super.key});

  @override
  State<CreatePrize> createState() => _CreatePrizeState();
}

class _CreatePrizeState extends State<CreatePrize> {
  late final TextEditingController _amountController;
  late final TextEditingController _percentageController;
  late final TextEditingController _placeNameController;
  late final TextEditingController _placeNumberController;
  final _formKey = GlobalKey<FormState>();
  var _groupValue = PrizeType.values.first;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _percentageController = TextEditingController();
    _placeNameController = TextEditingController();
    _placeNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _percentageController.dispose();
    _placeNameController.dispose();
    _placeNumberController.dispose();
    super.dispose();
  }

  void _createPrize() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prize = Prize.fromStrings(
        id: '-1',
        amount: _amountController.text,
        percentage: _percentageController.text,
        placeName: _placeNameController.text,
        placeNumber: _placeNumberController.text,
      );
      final createdPrize = await GlobalConfig.connection.createPrize(prize);
      if (!mounted) return;
      Navigator.pop(context, createdPrize);
    }
  }

  String? _validateAmount(String? value) {
    if (value != null) {
      final amount = Decimal.tryParse(value);
      if (value.isEmpty || amount == null || amount < Decimal.zero) {
        return 'Please enter a positive decimal number';
      }
    }
    return null;
  }

  String? _validatePercentage(String? value) {
    if (value != null) {
      final percentage = double.tryParse(value);
      if (value.isEmpty || percentage == null || percentage < 0) {
        return 'Please enter a positive decimal number';
      }
    }
    return null;
  }

  String? _validatePlaceName(String? value) {
    if (value != null && value.isEmpty) {
      return 'Please enter a place name';
    }
    return null;
  }

  String? _validatePlaceNumber(String? value) {
    if (value != null) {
      final placeNumber = int.tryParse(value);
      if (value.isEmpty || placeNumber == null || placeNumber < 0) {
        return 'Please enter a positive integer number';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFormField(
              controller: _placeNumberController,
              label: 'Place number',
              validator: _validatePlaceNumber,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _placeNameController,
              label: 'Place name',
              validator: _validatePlaceName,
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Informative text to inform user which type of prize type '
                'they want to enter',
              ),
            ),
            RadioListTile(
              value: PrizeType.amount,
              groupValue: _groupValue,
              onChanged: (value) {
                setState(() {
                  _groupValue = value!;
                });
              },
              title: const Text('Amount'),
            ),
            RadioListTile(
              value: PrizeType.percentage,
              groupValue: _groupValue,
              onChanged: (value) {
                setState(() {
                  _groupValue = value!;
                });
              },
              title: const Text('Percentage'),
            ),
            const SizedBox(height: 16),
            switch (_groupValue) {
              PrizeType.amount => CustomTextFormField(
                  controller: _amountController,
                  label: 'Prize amount',
                  validator: _validateAmount,
                ),
              PrizeType.percentage => CustomTextFormField(
                  controller: _percentageController,
                  label: 'Prize percentage',
                  validator: _validatePercentage,
                ),
            },
            const SizedBox(height: 32),
            CustomButton(
              buttonType: ButtonType.filled,
              onPressed: _createPrize,
              text: 'Create prize',
            ),
          ],
        ),
      ),
    );
  }
}
