import 'package:flutter/material.dart';

import '../../models/publication.dart';
import '../../services/api_service.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({
    super.key,
    required this.apiService,
    required this.onLogout,
  });

  final ApiService apiService;
  final VoidCallback onLogout;

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  List<Publication> _publications = [];
  bool _loading = true;
  String? _error;
  final Set<int> _updatingIds = {};

  @override
  void initState() {
    super.initState();
    _loadPublications();
  }

  Future<void> _loadPublications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final publications = await widget.apiService.fetchMyPublications();
      if (!mounted) return;
      setState(() {
        _publications = publications;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleStatus(Publication publication, bool newStatus) async {
    setState(() {
      _updatingIds.add(publication.id);
    });

    try {
      final updated = await widget.apiService.updatePublicationStatus(publication.id, newStatus);
      if (!mounted) return;
      setState(() {
        _publications = _publications
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingIds.remove(publication.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Misiones'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _loading ? null : _loadPublications,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Salir',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(onPressed: _loadPublications, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                )
              : _publications.isEmpty
                  ? const Center(child: Text('No tienes publicaciones abiertas.'))
                  : ListView.builder(
                      itemCount: _publications.length,
                      itemBuilder: (context, index) {
                        final publication = _publications[index];
                        final isUpdating = _updatingIds.contains(publication.id);

                        return SwitchListTile(
                          title: Text(
                            publication.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(publication.status ? 'Activa' : 'Cerrada'),
                          value: publication.status,
                          onChanged: isUpdating
                              ? null
                              : (value) => _toggleStatus(publication, value),
                          activeThumbColor: const Color(0xFFF6C844),
                        );
                      },
                    ),
    );
  }
}
