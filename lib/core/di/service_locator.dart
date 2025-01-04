import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/member_repository.dart';
import '../../data/services/bot_service.dart';
import '../../data/services/group_service.dart';
import '../../data/services/member_service.dart';
import '../../data/services/payment_service.dart';
import '../../data/services/sms_service.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // External Services
  serviceLocator.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  serviceLocator.registerLazySingleton<Telephony>(
    () => Telephony.instance,
  );

  serviceLocator.registerLazySingleton<http.Client>(
    () => http.Client(),
  );

  // Repositories
  serviceLocator.registerLazySingleton<GroupRepository>(
    () => GroupRepository(
      firestore: serviceLocator<FirebaseFirestore>(),
    ),
  );

  serviceLocator.registerLazySingleton<MemberRepository>(
    () => MemberRepository(
      firestore: serviceLocator<FirebaseFirestore>(),
    ),
  );

  // Services
  serviceLocator.registerLazySingleton<BotService>(
    () => BotService(
      client: serviceLocator<http.Client>(),
      baseUrl: AppConstants.botApiBaseUrl,
    ),
  );

  serviceLocator.registerLazySingleton<SMSService>(
    () => SMSService(
      telephony: serviceLocator<Telephony>(),
    ),
  );

  serviceLocator.registerLazySingleton<GroupService>(
    () => GroupService(
      groupRepository: serviceLocator<GroupRepository>(),
      memberRepository: serviceLocator<MemberRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton<MemberService>(
    () => MemberService(
      memberRepository: serviceLocator<MemberRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton<PaymentService>(
    () => PaymentService(
      memberRepository: serviceLocator<MemberRepository>(),
      smsService: serviceLocator<SMSService>(),
    ),
  );
}

void disposeServiceLocator() {
  serviceLocator<http.Client>().close();
  serviceLocator.reset();
}
