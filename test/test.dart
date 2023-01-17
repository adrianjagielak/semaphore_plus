import 'dart:async';

import 'package:semaphore/semaphore.dart';
import 'package:test/test.dart';

void main() {
  test("Global semaphore", () async {
    var res1 = [];
    Future action(List res, int milliseconds) {
      expect(res.length, 0, reason: "Not exlusive start");
      res.length++;
      var completer = new Completer();
      new Timer(new Duration(milliseconds: milliseconds), () {
        expect(res.length, 1, reason: "Not exlusive end");
        res.length--;
        completer.complete();
      });

      return completer.future;
    }

    var s1 = new GlobalSemaphore("semaphore_test");
    var s2 = new GlobalSemaphore("semaphore_test");
    expect(s1, s2, reason: "Global semaphores are not equal");
    //
    var list = [];
    for (var i = 0; i < 3; i++) {
      Future f(Semaphore s, List l) async {
        try {
          await s.acquire();
          await action(l, 200);
        } finally {
          s.release();
        }
      }

      list.add(new Future(() => f(s1, res1)));
      list.add(new Future(() => f(s2, res1)));
    }

    // Run concurrently
    await Future.wait(list);
  });

  test("Local semaphore synchronisation", () async {
    var res1 = [];
    var res2 = [];
    Future action(List res, int milliseconds) {
      expect(res.length, 0, reason: "Not exlusive start");
      res.length++;
      var completer = new Completer();
      new Timer(new Duration(milliseconds: milliseconds), () {
        expect(res.length, 1, reason: "Not exlusive end");
        res.length--;
        completer.complete();
      });

      return completer.future;
    }

    var s1 = new LocalSemaphore(1);
    var s2 = new LocalSemaphore(1);
    var list = [];
    for (var i = 0; i < 3; i++) {
      Future f(Semaphore s, List l) async {
        try {
          await s.acquire();
          await action(l, 100);
        } finally {
          s.release();
        }
      }

      list.add(new Future(() => f(s1, res1)));
      list.add(new Future(() => f(s2, res2)));
    }

    // Run concurrently
    await Future.wait(list);
  });

  test("Local semaphore max count", () async {
    var list1 = [];
    var maxCount = 3;
    Future action(List list, int milliseconds) {
      expect(list.length <= maxCount, true, reason: "Not exlusive start");
      list.length++;
      var completer = new Completer();
      new Timer(new Duration(milliseconds: milliseconds), () {
        expect(list.length <= maxCount, true, reason: "Not exlusive end");
        list.length--;
        completer.complete();
      });

      return completer.future;
    }

    var s1 = new LocalSemaphore(3);
    var list = [];
    for (var i = 0; i < maxCount * 2; i++) {
      Future f(Semaphore s, List l) async {
        try {
          await s.acquire();
          await action(l, 100);
        } finally {
          s.release();
        }
      }

      list.add(new Future(() => f(s1, list1)));
    }

    // Run concurrently
    await Future.wait(list);
  });
}
