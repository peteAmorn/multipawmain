class APIRequest<T>{
  T? body;
  bool error;
  String? errorMessage;

  APIRequest({
    this.body,
    this.error = false,
    this.errorMessage
  });
}