import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

enum PrizeType { amount, percentage }

// TODO: add validation for the rest of the textformfields
class CreatePrize extends StatefulWidget {
  const CreatePrize({super.key});

  @override
  State<CreatePrize> createState() => _CreatePrizeState();
}

class _CreatePrizeState extends State<CreatePrize> {
  var _groupValue = PrizeType.amount;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _percentageController;

  bool _isAmountEnabled() => _groupValue == PrizeType.amount;
  bool _isPercentageEnabled() => _groupValue == PrizeType.percentage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _percentageController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _percentageController.dispose();
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Place name'),
                  ),
                  validator: (value) {
                    if (value != null) {
                      if (value.isEmpty) {
                        return 'Please enter your team name';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 13.6,
                ),
                // TODO: remove error message on change if possible
                RadioListTile(
                  value: PrizeType.amount,
                  groupValue: _groupValue,
                  onChanged: (value) {
                    setState(() {
                      _groupValue = value!;
                      _amountController.clear();
                      _percentageController.clear();
                    });
                  },
                  title: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Prize amount'),
                    ),
                    enabled: _isAmountEnabled(),
                    validator: (value) {
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
                      _amountController.clear();
                      _percentageController.clear();
                    });
                  },
                  title: TextFormField(
                    controller: _percentageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Prize percentage'),
                    ),
                    enabled: _isPercentageEnabled(),
                    validator: (value) {
                      if (value != null) {
                        if (_isAmountEnabled()) {
                          return null;
                        }
                        final prizePercentage = int.tryParse(value);
                        if (prizePercentage == null) {
                          return 'Please enter an integer number';
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
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This form is valid'),
                        ),
                      );
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
