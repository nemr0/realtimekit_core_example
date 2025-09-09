import 'package:flutter/material.dart';
import 'package:realtimekit_demo/constants/colors.dart';
import 'package:realtimekit_demo/di/di.dart';
import 'package:realtimekit_demo/di/providers.dart';
import 'package:realtimekit_demo/meeting_config.dart';
import 'package:realtimekit_demo/notifiers/states/router_states.dart';
import 'package:realtimekit_demo/ui/widgets/appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtimekit_core/realtimekit_core.dart';
import 'meeting/loading_screen.dart';
import 'meeting/setup_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final nameController = TextEditingController();

  final descriptionController = TextEditingController();

  final roomNameController = TextEditingController();

  @override
  void initState() {
    if (mounted) {
      attachAllListeners(ref);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    listenToAllListeners(ref);
    ref.listen(routerNotifier, (previous, next) {
      switch (next.runtimeType) {
        case OnRouterMeetingInitStarted:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoadingScreen()));
          break;
        case OnRouterMeetingInitCompleted:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SetupPage()));
          break;
        case OnRouterMeetingInitFailed:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ExceptionPage((next as OnRouterMeetingInitFailed).error),
            ),
          );
          break;
        case OnRouterMeetingRoomJoinStarted:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoadingScreen(),
            ),
          );
          break;
        case OnRouterMeetingRoomJoinCompleted:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RealtimeKitMeetingRoom(),
            ),
          );
          break;

        case OnRouterMeetingRoomJoinFailed:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ExceptionPage((next as OnRouterMeetingRoomJoinFailed).error),
            ),
          );
          break;
        case OnRouterMeetingRoomLeaveCompleted:
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);
          break;

        default:
          break;
      }
    });
    return Scaffold(
      appBar: const RealtimeKitAppBar(),
      body: Center(child: _meetingDetails()),
    );
  }

  Widget _meetingDetails() {
    return Center(
      child: MaterialButton(
        onPressed: () {
          dyteMobileClient.init(
            RtkMeetingInfo(
              baseDomain: 'realtime.cloudflare.com',
              authToken: MeetingConfig.authToken,
            ),
          );
        },
        minWidth: 180,
        height: 45,
        color: RealtimeKitColors.primary,
        child: const Text(
          "Join Meeting",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void listenToAllListeners(WidgetRef ref) {
    ref.listen(roomEventNotifier, (previous, next) {});
    ref.listen(localUserSettingsProvider, (previous, next) {});
    ref.listen(participantEventNotifier, (previous, next) {});
    ref.listen(chatNotifier, (previous, next) {});
    ref.listen(screenshareProvider, (previous, next) {});
    ref.listen(recordingNotifier, (previous, next) {});
    ref.listen(pluginProvider, (previous, next) {});
    ref.listen(waitingRoomNotifier, (previous, next) {});
    ref.listen(newPollEventNotifier, (previous, next) {});
    ref.listen(pollsListNotifier, (previous, next) {});
  }

  void attachAllListeners(WidgetRef ref) {
    dyteMobileClient.addMeetingRoomEventListener(
      ref.read(roomEventNotifier.notifier),
    );
    dyteMobileClient.addMeetingRoomEventListener(
      ref.read(routerNotifier.notifier),
    );
    dyteMobileClient.addSelfEventListener(
      ref.read(localUserSettingsProvider.notifier),
    );
    dyteMobileClient.addSelfEventListener(
      ref.read(routerNotifier.notifier),
    );
    dyteMobileClient.addParticipantsEventListener(
      ref.read(participantEventNotifier.notifier),
    );
    dyteMobileClient.addChatEventListener(
      ref.read(chatNotifier.notifier),
    );
    dyteMobileClient.addParticipantsEventListener(
      ref.read(pinUnpinProvider.notifier),
    );
    dyteMobileClient.addDataUpdateEventListener(
      ref.read(screenshareProvider.notifier),
    );
    dyteMobileClient.addRecordingEventListener(
      ref.read(recordingNotifier.notifier),
    );
    dyteMobileClient.addDataUpdateEventListener(
      ref.read(pluginProvider.notifier),
    );
    dyteMobileClient.addWaitlistEventListener(
      ref.read(waitingRoomNotifier.notifier),
    );
    dyteMobileClient.addPollsEventListener(
      ref.read(newPollEventNotifier.notifier),
    );
    dyteMobileClient.addPollsEventListener(
      ref.read(pollsListNotifier.notifier),
    );
  }
}
