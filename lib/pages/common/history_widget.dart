import 'package:combinat/pages/common/result_widget.dart';
import 'package:combinat/session_storage.dart';
import 'package:combinat/utils.dart';
import 'package:flutter/material.dart';

class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  int listenerKey = 0;

  @override
  void initState() {
    super.initState();
    listenerKey = HistoryStorage.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant HistoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    HistoryStorage.removeListener(listenerKey);
    listenerKey = HistoryStorage.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    HistoryStorage.removeListener(listenerKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "History",
            style: TextStyle(
              fontSize: 28,
            ),
          ),
        ),
        Expanded(
          child: HistoryStorage.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const Text(
                          "Your calculations will appear here",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  children: HistoryStorage.history
                      .map(
                        (e) => ListTile(
                          title: ResultWidget(
                            result: e.key,
                            resultToCopy: e.value,
                            copyCallback: (copied) => showSnackBar(
                              context: context,
                              text: Text("Copied $copied"),
                              icon: Icon(
                                Icons.copy,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                            fontSize: 20,
                            alignment: Alignment.centerLeft,
                            isTex: true,
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}
