import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:learnflutter/core/network/api_client/api_client.dart';
import 'package:learnflutter/core/network/graphql/graphql_client.dart';
import 'package:learnflutter/core/network/queue/network_queue_service.dart';

/// Demo trực quan 3 component của `core/network`:
/// - **REST**: GET/POST qua `ApiClient` đến jsonplaceholder.
/// - **Queue**: enqueue 8 GET song song qua `NetworkQueueService`.
/// - **GraphQL**: query countries.trevorblades.com qua `GraphqlClient`.
///
/// Mọi request dùng URL tuyệt đối → bỏ qua `baseUrl` mặc định của app.
class NetworkDemoScreen extends StatelessWidget {
  const NetworkDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Network Module Demo'),
          bottom: const TabBar(tabs: [
            Tab(text: 'REST'),
            Tab(text: 'Queue'),
            Tab(text: 'GraphQL'),
          ]),
        ),
        body: const TabBarView(
          children: [
            _RestTab(),
            _QueueTab(),
            _GraphqlTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REST tab — ApiClient
// ═══════════════════════════════════════════════════════════════════════════

class _RestTab extends StatefulWidget {
  const _RestTab();

  @override
  State<_RestTab> createState() => _RestTabState();
}

class _RestTabState extends State<_RestTab> {
  String _output = 'Press a button to call jsonplaceholder.typicode.com';
  bool _loading = false;

  Future<void> _run(Future<dynamic> Function() task, String label) async {
    setState(() {
      _loading = true;
      _output = '⏳ $label...';
    });
    try {
      final r = await task();
      if (!mounted) return;
      setState(() => _output = '✅ $label\n\n${_pretty(r)}');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _output = '❌ $label\nApiException ${e.statusCode}: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _output = '❌ $label\n$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton(
              onPressed: _loading
                  ? null
                  : () => _run(
                        () => ApiClient.instance.get('https://jsonplaceholder.typicode.com/posts/1'),
                        'GET /posts/1',
                      ),
              child: const Text('GET /posts/1'),
            ),
            FilledButton.tonal(
              onPressed: _loading
                  ? null
                  : () => _run(
                        () => ApiClient.instance.post(
                          'https://jsonplaceholder.typicode.com/posts',
                          data: {'title': 'demo', 'body': 'hello', 'userId': 1},
                        ),
                        'POST /posts',
                      ),
              child: const Text('POST /posts'),
            ),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => _run(
                        () => ApiClient.instance.get(
                          'https://jsonplaceholder.typicode.com/users',
                          useCache: true,
                        ),
                        'GET /users (cache)',
                      ),
              child: const Text('GET /users (cache)'),
            ),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => _run(
                        () => ApiClient.instance.delete('https://jsonplaceholder.typicode.com/posts/1'),
                        'DELETE /posts/1',
                      ),
              child: const Text('DELETE /posts/1'),
            ),
          ]),
          const SizedBox(height: 16),
          Expanded(child: _OutputBox(text: _output, loading: _loading)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Queue tab — NetworkQueueService
// ═══════════════════════════════════════════════════════════════════════════

class _QueueTab extends StatefulWidget {
  const _QueueTab();

  @override
  State<_QueueTab> createState() => _QueueTabState();
}

class _QueueTabState extends State<_QueueTab> {
  final List<_QueueLog> _logs = [];
  int _pending = 0;
  int _completed = 0;
  int _failed = 0;
  bool _running = false;

  Future<void> _enqueueBatch() async {
    NetworkQueueService.instance.init();
    setState(() {
      _logs.clear();
      _pending = 8;
      _completed = 0;
      _failed = 0;
      _running = true;
    });

    final futures = <Future<void>>[];
    for (int i = 1; i <= 8; i++) {
      final id = i;
      futures.add(
        NetworkQueueService.instance
            .get('https://jsonplaceholder.typicode.com/posts/$id')
            .then((data) {
          if (!mounted) return;
          setState(() {
            _logs.add(_QueueLog('✅ post/$id', '"${data['title']}"'));
            _pending--;
            _completed++;
          });
        }).catchError((e) {
          if (!mounted) return;
          setState(() {
            _logs.add(_QueueLog('❌ post/$id', '$e'));
            _pending--;
            _failed++;
          });
        }),
      );
    }
    await Future.wait(futures);
    if (mounted) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _running ? null : _enqueueBatch,
            icon: const Icon(Icons.queue),
            label: const Text('Enqueue 8 GET requests'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(label: 'Pending', value: _pending, color: Colors.orange),
              const SizedBox(width: 8),
              _StatChip(label: 'Completed', value: _completed, color: Colors.green),
              const SizedBox(width: 8),
              _StatChip(label: 'Failed', value: _failed, color: Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        'concurrency mặc định = 2 → request chạy theo cặp.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _logs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final l = _logs[i];
                        return ListTile(
                          dense: true,
                          title: Text(l.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(l.detail, maxLines: 1, overflow: TextOverflow.ellipsis),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueLog {
  _QueueLog(this.title, this.detail);
  final String title;
  final String detail;
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GraphQL tab — GraphqlClient
// ═══════════════════════════════════════════════════════════════════════════

class _GraphqlTab extends StatefulWidget {
  const _GraphqlTab();

  @override
  State<_GraphqlTab> createState() => _GraphqlTabState();
}

class _GraphqlTabState extends State<_GraphqlTab> {
  String _output = 'Press a button to query countries.trevorblades.com';
  bool _loading = false;

  static const _continentQuery = r'''
    query Continent($code: ID!) {
      continent(code: $code) {
        name
        countries { code name capital emoji }
      }
    }
  ''';

  Future<void> _queryContinent(String code) async {
    setState(() {
      _loading = true;
      _output = '⏳ Querying continent $code...';
    });
    try {
      final r = await GraphqlClient.instance.query(
        document: _continentQuery,
        variables: {'code': code},
        path: 'https://countries.trevorblades.com/',
      );
      if (!mounted) return;
      setState(() => _output = _formatContinent(r));
    } catch (e) {
      if (!mounted) return;
      setState(() => _output = '❌ $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatContinent(dynamic resp) {
    final c = resp['data']?['continent'];
    if (c == null) return 'No data:\n${_pretty(resp)}';
    final countries = (c['countries'] as List).cast<Map>();
    final list = countries
        .take(20)
        .map((x) => '${x['emoji']}  ${x['name']} (${x['code']}) — ${x['capital'] ?? '—'}')
        .join('\n');
    return '✅ Continent: ${c['name']}\n${countries.length} countries (showing first 20):\n\n$list';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final entry in {
              'AS': 'Asia',
              'EU': 'Europe',
              'NA': 'N. America',
              'AF': 'Africa',
              'OC': 'Oceania',
              'SA': 'S. America',
            }.entries)
              OutlinedButton(
                onPressed: _loading ? null : () => _queryContinent(entry.key),
                child: Text(entry.value),
              ),
          ]),
          const SizedBox(height: 16),
          Expanded(child: _OutputBox(text: _output, loading: _loading)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared
// ═══════════════════════════════════════════════════════════════════════════

class _OutputBox extends StatelessWidget {
  const _OutputBox({required this.text, required this.loading});
  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: SelectableText(
              text,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          if (loading)
            const Positioned(
              right: 8,
              top: 8,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _pretty(dynamic data) {
  try {
    return const JsonEncoder.withIndent('  ').convert(data);
  } catch (_) {
    return data.toString();
  }
}
