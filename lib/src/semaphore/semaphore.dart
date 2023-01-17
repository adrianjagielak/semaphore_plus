part of semaphore;

/**
 * Global semaphore is a named semaphore with max count of permits equals to 1.
 */
class GlobalSemaphore extends Semaphore {
  static final Map<String, GlobalSemaphore> _semaphores =
      <String, GlobalSemaphore>{};

  factory GlobalSemaphore([String name]) {
    var semaphore = _semaphores[name];
    if (semaphore == null) {
      semaphore = new GlobalSemaphore._internal(name);
      _semaphores[name] = semaphore;
    }

    return semaphore;
  }

  GlobalSemaphore._internal(String name) : super._internal(1, name);
}

/**
 * Local semaphore is a unnamed semaphore with a specified count of max
 * permits.
 */
class LocalSemaphore extends Semaphore {
  LocalSemaphore(int maxCount) : super._internal(maxCount);
}

abstract class Semaphore {
  final int maxCount;

  final String name;

  int _currentCount = 0;

  Queue<Completer> _waitQueue = new Queue<Completer>();

  Semaphore._internal(this.maxCount, [this.name]) {
    if (maxCount == null) {
      throw new ArgumentError.notNull("maxCount");
    }

    if (maxCount < 1) {
      throw new RangeError.value(maxCount, "maxCount");
    }
  }

  /**
   * Acquires a permit from this semaphore, asyncronously blocking until one is
   * available.
   */
  Future acquire() {
    var completer = new Completer();
    if (_currentCount + 1 <= maxCount) {
      _currentCount++;
      completer.complete();
    } else {
      _waitQueue.add(completer);
    }

    return completer.future;
  }

  /**
   * Releases a permit, returning it to the semaphore.
   */
  void release() {
    if (_currentCount == 0) {
      throw new StateError("Unable to release semaphore");
    }

    _currentCount--;
    if (_waitQueue.length > 0) {
      _currentCount++;
      var completer = _waitQueue.removeFirst();
      completer.complete();
    }
  }
}
