import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_models/auth/phone_auth_eligibility_result.dart';

class PhoneAuthEligibilityRepository {
  PhoneAuthEligibilityRepository({
    FirebaseFunctions? functions,
  }) : _functions =
      functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFunctions _functions;

  Future<PhoneAuthEligibilityResult> checkEligibility({
    required String phoneNumber,
    required String app,
    required String intent,
  }) async {
    final callable = _functions.httpsCallable(
      'checkPhoneAuthEligibility',
    );

    final response = await callable.call(<String, dynamic>{
      'phoneNumber': phoneNumber,
      'app': app,
      'intent': intent,
    });

    final data = Map<String, dynamic>.from(response.data as Map);

    return PhoneAuthEligibilityResult.fromMap(data);
  }
}