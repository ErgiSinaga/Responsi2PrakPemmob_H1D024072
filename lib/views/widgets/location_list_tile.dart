import 'package:flutter/material.dart';
import '../../models/location_model.dart';

/// Widget item daftar lokasi (digunakan pada hasil pencarian, favorit, & riwayat)
class LocationListTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onDelete;

  const LocationListTile({
    super.key,
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F5FE), // Light sky blue
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Color(0xFF0288D1),
            size: 22,
          ),
        ),
        title: Text(
          location.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          location.fullAddress,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol Toggle Favorit (Bintang)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite ? Colors.amber.shade600 : Colors.grey.shade400,
              ),
              tooltip: isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
              onPressed: onToggleFavorite,
            ),
            // Tombol Hapus opsional (misal pada riwayat)
            if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                tooltip: 'Hapus',
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
