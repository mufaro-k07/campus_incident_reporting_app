import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'cubits/auth/auth_cubit.dart';
import 'firebase_options.dart';
import 'repositories/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: authRepository)],
      child: BlocProvider(
        create: (_) => AuthCubit(authRepository),
        child: const CampusIncidentApp(),
      ),
    ),
  );
}
