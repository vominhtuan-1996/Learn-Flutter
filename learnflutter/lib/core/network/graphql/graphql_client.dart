import '../api_client/api_client.dart';

/// GraphqlClient - Wrapper for GraphQL requests using the core ApiClient.
/// 
/// Since GraphQL operations are typically HTTP POST requests with a specific 
/// JSON body structure (`query` and `variables`), this client simplifies 
/// executing queries and mutations.
class GraphqlClient {
  GraphqlClient._internal();

  static final GraphqlClient instance = GraphqlClient._internal();

  /// The default GraphQL endpoint path. You can override it per request.
  String defaultPath = '/graphql';

  /// Execute a GraphQL query or mutation.
  /// 
  /// [document] is the GraphQL query string or mutation string.
  /// [variables] are the optional variables for the operation.
  /// [path] can be used to override the default GraphQL endpoint.
  /// [useCache] enables caching the response using ApiCacheStore.
  Future<dynamic> execute({
    required String document,
    Map<String, dynamic>? variables,
    String? path,
    bool useCache = false,
  }) async {
    final requestPath = path ?? defaultPath;
    
    final data = {
      'query': document,
      if (variables != null && variables.isNotEmpty) 'variables': variables,
    };

    return await ApiClient.instance.post(
      requestPath,
      data: data,
      useCache: useCache,
    );
  }

  /// Shorthand for executing a GraphQL Query
  Future<dynamic> query({
    required String document,
    Map<String, dynamic>? variables,
    String? path,
    bool useCache = false,
  }) {
    return execute(
      document: document,
      variables: variables,
      path: path,
      useCache: useCache,
    );
  }

  /// Shorthand for executing a GraphQL Mutation
  Future<dynamic> mutation({
    required String document,
    Map<String, dynamic>? variables,
    String? path,
  }) {
    // Mutations typically should not be cached
    return execute(
      document: document,
      variables: variables,
      path: path,
      useCache: false,
    );
  }
}
