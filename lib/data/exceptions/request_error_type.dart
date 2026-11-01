enum RequestErrorType {
  requestCancelled,
  certificateError,
  requestTimeout,
  badRequest,
  unAuthorized,
  serverError,
  networkError,
  cannotConnectToServer,
  unknownError
  ;

  bool get isBadRequest => this == RequestErrorType.badRequest;
  bool get isUnauthorized => this == RequestErrorType.unAuthorized;
  bool get isServerError => this == RequestErrorType.serverError;
  bool get isUnknownError => this == RequestErrorType.unknownError;
  bool get isCancelled => this == RequestErrorType.requestCancelled;

  bool get isConnectivityIssue =>
      this == RequestErrorType.requestTimeout ||
      this == RequestErrorType.networkError ||
      this == RequestErrorType.cannotConnectToServer ||
      this == RequestErrorType.certificateError;

  bool get isRejection => isBadRequest || isUnauthorized;
}
