import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/person.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';

class CreateNewMember extends StatefulWidget {
  final void Function(Person member) onMemberCreated;

  const CreateNewMember({super.key, required this.onMemberCreated});

  @override
  State<CreateNewMember> createState() => _CreateNewMemberState();
}

class _CreateNewMemberState extends State<CreateNewMember> {
  late final TextEditingController _emailController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _createNewMember() async {
    if (_formKey.currentState?.validate() ?? false) {
      final member = Person(
        id: -1,
        emailAddress: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneController.text,
      );

      final createdMember = await GlobalConfig.connection.createPerson(member);
      widget.onMemberCreated.call(createdMember);

      _emailController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _phoneController.clear();
    }
  }

  String? _validateEmailAddress(String? value) {
    if (value != null && value.isEmpty) {
      return 'This field can\'t be empty';
    }
    return null;
  }

  String? _validateFirstName(String? value) {
    if (value != null && value.isEmpty) {
      return 'This field can\'t be empty';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value != null && value.isEmpty) {
      return 'This field can\'t be empty';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value != null && value.isEmpty) {
      return 'This field can\'t be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextFormField(
              controller: _firstNameController,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              label: 'First name',
              validator: _validateFirstName,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _lastNameController,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              label: 'Last name',
              validator: _validateLastName,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _phoneController,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              label: 'Phone number',
              validator: _validatePhoneNumber,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _emailController,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              label: 'Email address',
              validator: _validateEmailAddress,
            ),
            const Spacer(),
            CustomButton(
              buttonType: ButtonType.filled,
              onPressed: _createNewMember,
              text: 'Create new member',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
