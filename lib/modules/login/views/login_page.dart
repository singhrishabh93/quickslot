import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/local/session_storage.dart';
import 'package:swades_hackathon_app/data/models/user.dart';
import 'package:swades_hackathon_app/data/repositories/users_repository.dart';
import 'package:swades_hackathon_app/data/utils/result.dart';
import 'package:swades_hackathon_app/router/app_router.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Future<Result<List<User>>> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<UsersRepository>().listUsers();
  }

  Future<void> _onUserTap(User user) async {
    await getIt<SessionStorage>().save(userId: user.id, userName: user.name);
    if (!mounted) return;
    await context.router.replaceAll([const VenuesRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a user')),
      body: FutureBuilder<Result<List<User>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final result = snapshot.data;
          if (result == null) {
            return const Center(child: Text('Unknown error'));
          }
          return result.fold(
            (users) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final u = users[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(u.name[0])),
                    title: Text(u.name),
                    subtitle: Text(u.email),
                    onTap: () => _onUserTap(u),
                  ),
                );
              },
            ),
            (failure) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  failure.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
