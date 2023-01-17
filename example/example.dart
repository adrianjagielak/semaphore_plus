import 'dart:async';

import 'package:semaphore/semaphore.dart';

Future main() async {
  var maxCount = 3;
  var running = 0;
  var simultaneous = 0;
  var sm = new LocalSemaphore(maxCount);
  var tasks = <Future>[];
  for (var i = 0; i < 9; i++) {
    tasks.add(new Future(() async {
      try {
        await sm.acquire();
        running++;
        if (simultaneous < running) {
          simultaneous = running;
        }

        print("Start $i, running $running");
        await _doWork(100);
        running--;
        print("End   $i, running $running");
      } finally {
        sm.release();
      }
    }));
  }

  await Future.wait(tasks);
  print("Max permits: $maxCount, max simultaneous runned: $simultaneous");
}

Future _doWork(int ms) {
  // Simulate work
  return new Future.delayed(new Duration(milliseconds: ms));
}
