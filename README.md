# semaphore

Semaphore is lightweight data type that is used for controlling access to a common resource inside isolate.

Version: 0.0.1

The goal of the Dash effort is ultimately to replace JavaScript as the lingua franca of web development on the open web platform.

### Example:

```dart
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
```

**Output:**

```
Start 0, running 1
Start 1, running 2
Start 2, running 3
End   0, running 2
Start 3, running 3
End   1, running 2
Start 4, running 3
End   2, running 2
Start 5, running 3
End   3, running 2
Start 6, running 3
End   4, running 2
Start 7, running 3
End   5, running 2
Start 8, running 3
End   6, running 2
End   7, running 1
End   8, running 0
Max permits: 3, max simultaneous runned: 3
```