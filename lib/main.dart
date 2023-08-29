import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'amplifyconfiguration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await _configureAmplify();
    await signIn(email: 'ashwinkumar', password: 'ashwinkumar');

    // Manually commented / un-commented below methods and hot-reloaded to test
    // await updateUserAttributes(newEmail: "<newEmail>");
    // await resendVerificationCode();
    // await verifyAttributeUpdate(verificationCode: '00000');
  }

  Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  Future<void> updateUserAttributes({
    required String newEmail,
  }) async {
    final attributes = [
      AuthUserAttribute(
          userAttributeKey: AuthUserAttributeKey.email, value: newEmail)
    ];
    try {
      final result = await Amplify.Auth.updateUserAttributes(
        attributes: attributes,
      );
      result.forEach((key, value) {
        switch (value.nextStep.updateAttributeStep) {
          case AuthUpdateAttributeStep.confirmAttributeWithCode:
            final destination = value.nextStep.codeDeliveryDetails?.destination;
            safePrint('Confirmation code sent to $destination for $key');
            break;
          case AuthUpdateAttributeStep.done:
            safePrint('Update completed for $key');
            break;
        }
      });
    } on AuthException catch (e) {
      safePrint('Error updating user attributes: ${e.message}');
    }
  }

  Future<void> verifyAttributeUpdate({
    required String verificationCode,
  }) async {
    try {
      await Amplify.Auth.confirmUserAttribute(
        userAttributeKey: AuthUserAttributeKey.email,
        confirmationCode: verificationCode,
      );
    } on AuthException catch (e) {
      safePrint('Error confirming attribute update: ${e.message}');
    }
  }

  Future<void> resendVerificationCode() async {
    try {
      final result = await Amplify.Auth.resendUserAttributeConfirmationCode(
        userAttributeKey: AuthUserAttributeKey.email,
      );
      _handleCodeDelivery(result.codeDeliveryDetails);
    } on AuthException catch (e) {
      safePrint('Error resending code: ${e.message}');
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res =
          await Amplify.Auth.signIn(username: email, password: password);
      print(res);
      return Future<bool>.value(true);
    } on AuthException catch (e) {
      print(e.message);
      return Future<bool>.value(false);
    }
  }

  void _handleCodeDelivery(AuthCodeDeliveryDetails codeDeliveryDetails) async {
    print('Code sent to ${codeDeliveryDetails.destination}');
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SizedBox(),
      ),
    );
  }
}
