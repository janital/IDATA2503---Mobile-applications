import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:project/models/project.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/models/user.dart';
import 'package:project/providers/project_provider.dart';
import 'package:project/providers/user_provider.dart';
import 'package:project/screens/edit_profile_screen.dart';
import 'package:project/screens/project_preview_screen.dart';
import 'package:project/styles/curve_clipper.dart';
import 'package:project/styles/theme.dart';
import 'package:project/screens/user_settings_screen.dart';
import 'package:project/widgets/appbar_button.dart';
import 'package:project/widgets/loading_spinner.dart';
import 'package:project/widgets/modal_list_item.dart';
import 'package:project/widgets/project_card.dart';

enum _ProfileScreenView {
  current,
  other,
}

/// Screen/Scaffold for the profile of the user.
class ProfileScreen extends ConsumerWidget {
  /// Named route for this screen.
  static const routeName = "/user";

  /// Creates an instance of [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? userId = ModalRoute.of(context)!.settings.arguments as String?;
    _ProfileScreenView? userType;

    /// Returns a [Stream] of a [User].
    Stream<User?> getUserStream() {
      if (userId == null ||
          userId == ref.watch(authProvider).currentUser!.uid) {
        userType = _ProfileScreenView.current;
        userId = ref.watch(authProvider).currentUser!.uid;
        return ref.watch(userProvider).getUser(userId!);
      }
      userType = _ProfileScreenView.other;
      return ref.watch(userProvider).getUser(userId!);
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Themes.primaryColor,
        title: appBarTitle(ref),
        actions: [profileMenuButton(context, ref)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              color: Themes.primaryColor,
              height: 220,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 16.0,
                ),
                child: StreamBuilder<User?>(
                  stream: getUserStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _profilePicture(context, snapshot),
                          const SizedBox(width: 16.0),
                          _profileInfo(snapshot),
                        ],
                      );
                    }
                    if (snapshot.hasError) print(snapshot.error);
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
          _ProfileProjectList(userId!, userType!),
        ],
      ),
    );
  }

  /// Returns a [Column] displaying the users username and bio.
  Widget _profileInfo(AsyncSnapshot<User?> snapshot) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            snapshot.data!.username,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4.0),
          Flexible(
            child: Text(
              snapshot.data!.bio,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                overflow: TextOverflow.clip,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 36.0),
        ],
      ),
    );
  }

  /// Returns a [CircleAvatar] displaying the users profile picture
  CircleAvatar _profilePicture(
      BuildContext context, AsyncSnapshot<User?> snapshot) {
    return CircleAvatar(
      radius: MediaQuery.of(context).size.width / 6,
      backgroundImage: NetworkImage(snapshot.data!.imageUrl!),
    );
  }

  /// Returns a [AppBarButton] for opening menu for the user.
  AppBarButton profileMenuButton(BuildContext context, WidgetRef ref) {
    return AppBarButton(
      handler: () => showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        context: context,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Container(
                  height: 3,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50.0),
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                ModalListItem(
                  icon: PhosphorIcons.userCircleGearLight,
                  label: "edit profile",
                  handler: () {
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .pushNamed(EditProfileScreen.routeName);
                  },
                ),
                ModalListItem(
                  icon: PhosphorIcons.gearSixLight,
                  label: "settings",
                  handler: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(
                      UserSettingsScreen.routeName,
                    );
                  },
                ),
                ModalListItem(
                  icon: PhosphorIcons.signOutLight,
                  label: "log out",
                  handler: () {
                    Navigator.of(context).pop();
                    _logout(ref);
                  },
                ),
                ModalListItem(
                  handler: () => showDialog(
                    context: context,
                    builder: (context) => const AboutDialog(
                      applicationLegalese:
                          "Copyright © 2022 NTNU, IDATA2503 Group 3 - Espen, Sakarias and Janita",
                      applicationVersion: "version 0.0.1",
                      applicationName: "solveit",
                    ),
                  ),
                  icon: PhosphorIcons.infoLight,
                  label: "app info",
                ),
              ],
            ),
          ),
        ),
      ),
      tooltip: "User menu",
      icon: PhosphorIcons.list,
      color: Colors.white,
    );
  }

  /// Returns two texts in a row displaying the solveit title.
  Row appBarTitle(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Text(
          "solve",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        Text(
          "it",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        )
      ],
    );
  }

  /// Logging the user out.
  void _logout(WidgetRef ref) {
    final auth = ref.read(authProvider);
    auth.signOut();
  }
}

/// Displays the projects of a user.
class _ProfileProjectList extends ConsumerStatefulWidget {
  /// The id of the user to display projects for.
  final String userId;

  /// The type of view the profile screen is in.
  final _ProfileScreenView userType;

  /// Creates an instance of [_ProfileProjectList].
  const _ProfileProjectList(
    this.userId,
    this.userType,
  );

  @override
  ConsumerState<_ProfileProjectList> createState() =>
      _ProfileProjectListState();
}

class _ProfileProjectListState extends ConsumerState<_ProfileProjectList> {
  String owner = "owner";
  String collaborator = "collaborator";
  late String isSelected;
  @override
  void initState() {
    isSelected = owner;
    super.initState();
  }

  /// Returs a [Stream] of projects depending on the value of [isSelected].
  Stream<List<Project>> getProjectStream() {
    if (isSelected == owner) {
      return ref
          .watch(projectProvider)
          .getProjectsByUserIdAsOwner(widget.userId);
    }
    return ref
        .watch(projectProvider)
        .getProjectsByUserIdAsCollaborator(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          _projectsTabBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<List<Project>?>(
                stream: getProjectStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Project> projects = snapshot.data!;
                    return _projectsList(projects);
                  }
                  if (snapshot.hasError) print(snapshot.error);
                  return const LoadingSpinner();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a [GridView] displaying the given [projects].
  GridView _projectsList(List<Project> projects) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 120,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) => _projectCard(projects[index], context),
    );
  }

  /// Returns a projectcard for the given [project].
  ProjectCard _projectCard(Project project, BuildContext context) {
    return ProjectCard(
        project: project,
        handler: () {
          ref.read(currentProjectProvider.notifier).setProject(
              ref.watch(projectProvider).getProject(project.projectId));
          Navigator.of(context)
              .pushNamed(ProjectPreviewScreen.routeName, arguments: project);
        });
  }

  /// Returns bottoms in a row to decide which projects to display in the list.
  Padding _projectsTabBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        children: <Widget>[
          isSelected == owner
              ? ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSelected = owner;
                    });
                  },
                  style: Themes.softPrimaryElevatedButtonStyle,
                  child: Text(owner),
                )
              : TextButton(
                  style: Themes.textButtonStyle(ref),
                  onPressed: () {
                    setState(() {
                      isSelected = owner;
                    });
                  },
                  child: Text(owner),
                ),
          const SizedBox(width: 4.0),
          isSelected == collaborator
              ? ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSelected = collaborator;
                    });
                  },
                  style: Themes.softPrimaryElevatedButtonStyle,
                  child: Text(collaborator),
                )
              : TextButton(
                  style: Themes.textButtonStyle(ref),
                  onPressed: () {
                    setState(() {
                      isSelected = collaborator;
                    });
                  },
                  child: Text(collaborator),
                ),
        ],
      ),
    );
  }
}
