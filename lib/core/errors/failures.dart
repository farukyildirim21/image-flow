sealed class Failure {
  final String message;
  const Failure(this.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class ProcessingFailure extends Failure {
  const ProcessingFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class DetectionFailure extends Failure {
  const DetectionFailure(super.message);
}
