# semaphore

Semaphore is lightweight data type that is used for controlling the cooperative access to a common resource inside the isolate.

Version: 0.1.1

### Example:

```dart
import 'dart:async';

import 'package:semaphore/semaphore.dart';

Future<void> main() async {
  var maxCount = 3;
  var running = <int>[];
  var simultaneous = 0;
  var sm = new LocalSemaphore(maxCount);
  var tasks = <Future>[];
  for (var i = 0; i < 9; i++) {
    tasks.add(new Future(() async {
      try {
        await sm.acquire();
        running.add(i);
        if (simultaneous < running.length) {
          simultaneous = running.length;
        }

        print("Start $i, running $running");
        await _doWork(100);
        running.remove(i);
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
Start 0, running [0]
Start 1, running [0, 1]
Start 2, running [0, 1, 2]
End   0, running [1, 2]
Start 3, running [1, 2, 3]
End   1, running [2, 3]
Start 4, running [2, 3, 4]
End   2, running [3, 4]
Start 5, running [3, 4, 5]
End   3, running [4, 5]
Start 6, running [4, 5, 6]
End   4, running [5, 6]
Start 7, running [5, 6, 7]
End   5, running [6, 7]
Start 8, running [6, 7, 8]
End   6, running [7, 8]
End   7, running [8]
End   8, running []
Max permits: 3, max simultaneous runned: 3
```