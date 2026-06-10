import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/app/widgets/empty_view.dart';
import 'package:swades_hackathon_app/app/widgets/skeleton.dart';
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

  Future<void> _retry() async {
    setState(() {
      _future = getIt<UsersRepository>().listUsers();
    });
  }

  Future<void> _onUserTap(User user) async {
    await getIt<SessionStorage>().save(userId: user.id, userName: user.name);
    if (!mounted) return;
    await context.router.replaceAll([const VenuesRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Result<List<User>>>(
          future: _future,
          builder: (context, snapshot) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: AppColors.courtGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'QUICKSLOT',
                              style: theme.textTheme.labelLarge?.copyWith(
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'BOOK A COURT.',
                          style: theme.textTheme.displayMedium?.copyWith(
                            height: 0.95,
                          ),
                        ),
                        Text(
                          'PLAY TONIGHT.',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: AppColors.courtGreen,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sports slot booking for Bangalore. Pick a venue, pick an hour, you\'re in.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.subtle,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 1,
                              color: AppColors.ink,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "WHO'S PLAYING",
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: _buildBody(snapshot),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(AsyncSnapshot<Result<List<User>>> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return SliverList.separated(
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => const _UserCardSkeleton(),
      );
    }
    final result = snapshot.data;
    if (result == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return result.fold(
      (users) => SliverList.separated(
        itemCount: users.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _UserCard(user: users[i], onTap: _onUserTap),
      ),
      (failure) => SliverToBoxAdapter(
        child: ErrorView(message: failure.message, onRetry: _retry),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onTap});

  final User user;
  final Future<void> Function(User) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.paper,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: () => onTap(user),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.toUpperCase(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        height: 1,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: AppTheme.mono(
                        context,
                        fontSize: 11,
                        color: AppColors.subtle,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: AppColors.ink,
                child: Text(
                  'ENTER →',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.cream,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCardSkeleton extends StatelessWidget {
  const _UserCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: const [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 160, height: 28),
                  SizedBox(height: 10),
                  Skeleton(width: 200, height: 12),
                ],
              ),
            ),
            Skeleton(width: 72, height: 28),
          ],
        ),
      ),
    );
  }
}
