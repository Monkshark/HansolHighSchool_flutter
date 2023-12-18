import 'package:flutter/material.dart';
import 'package:hansol_high_school/API/NoticeDataApi.dart';
import 'package:hansol_high_school/Data/LocalDatabase.dart';
import 'package:hansol_high_school/Data/ScheduleData.dart';
import 'package:hansol_high_school/Widgets/AlertWidgets/DeleteAlertDialog.dart';
import 'package:hansol_high_school/Widgets/CalendarWidgets/MainCalendar.dart';
import 'package:hansol_high_school/Widgets/CalendarWidgets/ScheduleBottomSheet.dart';
import 'package:hansol_high_school/Widgets/CalendarWidgets/ScheduleCard.dart';
import 'package:hansol_high_school/Widgets/CalendarWidgets/SchoolScheduleCard.dart';
import 'package:hansol_high_school/Widgets/CalendarWidgets/TodayBanner.dart';
import 'package:get_it/get_it.dart';

class HansolHighSchool extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NoticeScreen(),
    );
  }
}

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({Key? key}) : super(key: key);

  @override
  _NoticeScreenState createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => ScheduleBottomSheet(
              selectedDate: selectedDate,
              onScheduleCreated: () {
                setState(() {});
              },
            ),
            isScrollControlled: true,
            isDismissible: true,
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MainCalendar(
              selectedDate: selectedDate,
              onDaySelected: onDaySelected,
            ),
            const SizedBox(height: 8.0),
            StreamBuilder<List<Schedule>>(
              stream: GetIt.I<LocalDataBase>().watchSchedules(selectedDate),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();

                return FutureBuilder<String?>(
                  future: NoticeDataApi().getNotice(date: selectedDate),
                  builder: (context, snapshot2) {
                    final schoolSchedule = snapshot2.data;
                    final hasSchoolSchedule = schoolSchedule != null;

                    final schedules = snapshot.data!;
                    final count =
                        schedules.length + (hasSchoolSchedule ? 1 : 0);

                    return TodayBanner(
                      selectedDate: selectedDate,
                      count: count,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: FutureBuilder<String?>(
                future: NoticeDataApi().getNotice(date: selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final schoolSchedule = snapshot.data;
                  final hasSchoolSchedule = schoolSchedule != null;

                  return StreamBuilder<List<Schedule>>(
                    stream:
                        GetIt.I<LocalDataBase>().watchSchedules(selectedDate),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();

                      final schedules = snapshot.data!;
                      final itemCount =
                          schedules.length + (hasSchoolSchedule ? 1 : 0);

                      return ListView.builder(
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (hasSchoolSchedule && index == 0) {
                            return Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('학사일정은 삭제가 불가능합니다'),
                                  ),
                                );
                                return false;
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8.0,
                                  left: 8.0,
                                  right: 8.0,
                                ),
                                child: SchoolScheduleCard(
                                  startTime: 00,
                                  endTime: 24,
                                  content: schoolSchedule!,
                                ),
                              ),
                            );
                          } else {
                            final schedule =
                                schedules[index - (hasSchoolSchedule ? 1 : 0)];

                            return Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const DeleteAlertDialog(
                                      title: '일정 삭제',
                                      content:
                                          '정말 일정을 삭제하시겠습니까?\n삭제 후에는 복구가 불가능합니다.',
                                    );
                                  },
                                );
                              },
                              onDismissed: (direction) async {
                                await GetIt.I<LocalDataBase>()
                                    .deleteSchedule(schedule);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('일정 삭제됨'),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8.0,
                                  left: 8.0,
                                  right: 8.0,
                                ),
                                child: ScheduleCard(
                                  startTime: schedule.startTime,
                                  endTime: schedule.endTime,
                                  content: schedule.content,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDay) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}
