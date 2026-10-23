/// Clés API passées à la compilation : `--dart-define-from-file=.env` (voir scripts/dev.sh).
class ApiKeys {
  const ApiKeys({this.perenual = '', this.plantnet = ''});

  const ApiKeys.fromEnvironment()
      : perenual = const String.fromEnvironment('PERENUAL_KEY'),
        plantnet = const String.fromEnvironment('PLANTNET_KEY');

  final String perenual;
  final String plantnet;
}

/// Erreur réseau ou de service (quota dépassé, clé absente…), message en français pour l'UI.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
