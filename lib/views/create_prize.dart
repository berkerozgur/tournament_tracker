import 'dart:developer' as dev;

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/prize.dart';

enum PrizeType { amount, percentage }

class CreatePrize extends StatefulWidget {
  const CreatePrize({super.key});

  @override
  State<CreatePrize> createState() => _CreatePrizeState();
}

class _CreatePrizeState extends State<CreatePrize> {
  var _groupValue = PrizeType.amount;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _percentage;
  late final TextEditingController _placeName;
  late final TextEditingController _placeNumber;

  bool _isAmountEnabled() => _groupValue == PrizeType.amount;
  bool _isPercentageEnabled() => _groupValue == PrizeType.percentage;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
    _percentage = TextEditingController();
    _placeName = TextEditingController();
    _placeNumber = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    _percentage.dispose();
    _placeName.dispose();
    _placeNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create prize'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 136.6 * 5,
            child: Column(
              children: [
                TextFormField(
                  controller: _placeNumber,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Place number'),
                  ),
                  validator: (value) {
                    if (value != null) {
                      final placeNumber = int.tryParse(value);
                      if (placeNumber == null) {
                        return 'Please enter an integer number';
                      } else if (placeNumber < 1) {
                        return 'Place number can\'t be smaller than 1';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 13.6,
                ),
                TextFormField(
                  controller: _placeName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Place name'),
                  ),
                  validator: (value) {
                    if (value != null) {
                      if (value.isEmpty) {
                        return 'Please enter place name';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 13.6,
                ),
                RadioListTile(
                  value: PrizeType.amount,
                  groupValue: _groupValue,
                  onChanged: (value) {
                    setState(() {
                      _groupValue = value!;
                      _amount.clear();
                      _percentage.clear();
                      // Focus then unfocus to clear error messages
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                  title: TextFormField(
                    controller: _amount,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Prize amount'),
                    ),
                    enabled: _isAmountEnabled(),
                    validator: (value) {
                      if (!_isAmountEnabled()) return null;
                      if (value != null) {
                        if (_isPercentageEnabled()) {
                          return null;
                        }
                        final prizeAmount = Decimal.tryParse(value);
                        if (prizeAmount == null) {
                          return 'Please enter a decimal number';
                        } else if (prizeAmount <= Decimal.zero) {
                          return 'Please enter a positive number';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                RadioListTile(
                  value: PrizeType.percentage,
                  groupValue: _groupValue,
                  onChanged: (value) {
                    setState(() {
                      _groupValue = value!;
                      _amount.clear();
                      _percentage.clear();
                      // Focus then unfocus to clear error messages
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                  title: TextFormField(
                    controller: _percentage,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Prize percentage'),
                    ),
                    enabled: _isPercentageEnabled(),
                    validator: (value) {
                      if (!_isPercentageEnabled()) return null;
                      if (value != null) {
                        if (_isAmountEnabled()) {
                          return null;
                        }
                        final prizePercentage = double.tryParse(value);
                        if (prizePercentage == null) {
                          return 'Please enter a decimal number';
                        } else if (prizePercentage < 0 ||
                            prizePercentage > 100) {
                          return 'Percentage has to be between 0 and 100';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 13.6,
                ),
                FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      var prize = Prize.fromStrings(
                        id: '-1',
                        amount: _amount.text,
                        percentage: _percentage.text,
                        placeName: _placeName.text,
                        placeNumber: _placeNumber.text,
                      );
                      final createdPrize =
                          await GlobalConfig.connection?.createPrize(prize);
                      if (!mounted) return;

                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Prize: $createdPrize')),
                      );

                      dev.log(prize.toString());
                      _amount.clear();
                      _percentage.clear();
                      _placeName.clear();
                      _placeNumber.clear();
                    }
                  },
                  child: const Text('Create prize'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
