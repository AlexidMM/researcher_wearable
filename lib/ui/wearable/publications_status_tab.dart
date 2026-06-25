import 'package:flutter/material.dart';

import '../../models/publication.dart';

class PublicationsStatusTab extends StatelessWidget {
  const PublicationsStatusTab({super.key, required this.publications});

  final List<Publication> publications;

  @override
  Widget build(BuildContext context) {
    if (publications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Aún no tienes convocatorias publicadas.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: publications.length,
      itemBuilder: (context, index) {
        final publication = publications[index];

        return ListTile(
          leading: Icon(
            publication.status ? Icons.check_circle : Icons.cancel,
            color: publication.status ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          title: Text(
            publication.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(_typeLabel(publication.type)),
          trailing: _StatusChip(isActive: publication.status),
        );
      },
    );
  }

  String _typeLabel(String? type) {
    return switch (type) {
      'scholarship' => 'Beca',
      'internship' => 'Estancia',
      'project' => 'Proyecto',
      _ => 'Convocatoria',
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Abierta' : 'Cerrada',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
