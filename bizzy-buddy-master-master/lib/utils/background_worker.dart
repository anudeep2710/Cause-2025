import 'dart:isolate';
import 'package:flutter/foundation.dart';

/// A utility class for running tasks in background threads using Dart isolates
class BackgroundWorker {
  /// Runs a computation on a separate isolate and returns the result
  ///
  /// This is a wrapper around Flutter's `compute` function that provides
  /// consistent error handling. Use this for CPU-intensive operations
  /// that would otherwise block the UI thread.
  ///
  /// Example usage:
  /// ```dart
  /// final result = await BackgroundWorker.run(
  ///   (data) => veryHeavyComputation(data),
  ///   someInputData,
  /// );
  /// ```
  static Future<R> run<Q, R>(ComputeCallback<Q, R> callback, Q message) async {
    try {
      return await compute(callback, message);
    } catch (e) {
      debugPrint('Error in background worker: $e');
      rethrow; // Rethrow to let the caller handle it
    }
  }

  /// Runs a computation on a separate isolate with progress updates
  ///
  /// This creates a custom isolate with a port for receiving progress updates
  /// during long-running operations.
  ///
  /// Example usage:
  /// ```dart
  /// await BackgroundWorker.runWithProgress(
  ///   task: (data, sendProgress) {
  ///     for (int i = 0; i < 100; i++) {
  ///       // Do work...
  ///       sendProgress(i / 100); // Send progress from 0.0 to 1.0
  ///     }
  ///     return 'Done!';
  ///   },
  ///   data: inputData,
  ///   onProgress: (progress) {
  ///     setState(() => this.progress = progress);
  ///   },
  ///   onResult: (result) {
  ///     print('Task completed with result: $result');
  ///   },
  /// );
  /// ```
  static Future<void> runWithProgress<Q, R>({
    required Function(Q data, Function(double) sendProgress) task,
    required Q data,
    required Function(double progress) onProgress,
    required Function(R result) onResult,
    Function(dynamic error)? onError,
  }) async {
    final ReceivePort receivePort = ReceivePort();
    final progressPort = ReceivePort();

    try {
      await Isolate.spawn(
        (Map<String, dynamic> args) {
          final SendPort sendPort = args['sendPort'];
          final SendPort progressSendPort = args['progressPort'];
          final data = args['data'] as Q;

          void sendProgress(double progress) {
            progressSendPort.send(progress);
          }

          try {
            final result = task(data, sendProgress);
            sendPort.send({'result': result});
          } catch (e) {
            sendPort.send({'error': e.toString()});
          }
        },
        {
          'sendPort': receivePort.sendPort,
          'progressPort': progressPort.sendPort,
          'data': data,
        },
      );

      // Listen for progress updates
      progressPort.listen((progress) {
        if (progress is double) {
          onProgress(progress);
        }
      });

      // Listen for the result or error
      final result = await receivePort.first;
      if (result is Map) {
        if (result.containsKey('result')) {
          onResult(result['result'] as R);
        } else if (result.containsKey('error') && onError != null) {
          onError(result['error']);
        }
      }
    } finally {
      receivePort.close();
      progressPort.close();
    }
  }
}
