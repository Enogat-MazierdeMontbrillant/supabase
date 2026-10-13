import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/client.dart';
import '../services/client_service.dart';

class DatagridPage extends StatefulWidget {
  static const route = '/datagrid';
  const DatagridPage({super.key});

  @override
  State<DatagridPage> createState() => _DatagridPageState();
}

class _DatagridPageState extends State<DatagridPage> {
  Future<List<Client>> _future = ClientService().getClients();

  Widget _header(String text) => Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Future<void> _refresh() async {
    setState(() => _future = ClientService().getClients(forceRefresh: true));
    await _future.catchError((Object _) => const <Client>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datagrid clients'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: FutureBuilder<List<Client>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          'Impossible de charger les clients : ${snapshot.error}'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _refresh,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun client disponible.'));
          }
          return SfDataGrid(
            source: ClientDataSource(snapshot.data!),
            allowSorting: true,
            columnWidthMode: ColumnWidthMode.fill,
            columns: [
              GridColumn(columnName: 'id', label: _header('ID')),
              GridColumn(columnName: 'prenom', label: _header('Prénom')),
              GridColumn(columnName: 'nom', label: _header('Nom')),
              GridColumn(columnName: 'email', label: _header('Email')),
              GridColumn(columnName: 'tel', label: _header('Tél')),
              GridColumn(columnName: 'adresse', label: _header('Adresse')),
            ],
          );
        },
      ),
    );
  }
}

class ClientDataSource extends DataGridSource {
  ClientDataSource(List<Client> clients) {
    _rows = clients
        .map((c) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: c.id),
              DataGridCell<String>(columnName: 'prenom', value: c.prenom),
              DataGridCell<String>(columnName: 'nom', value: c.nom),
              DataGridCell<String>(columnName: 'email', value: c.email ?? ''),
              DataGridCell<String>(columnName: 'tel', value: c.telephone),
              DataGridCell<String>(
                  columnName: 'adresse', value: c.adresse.toString()),
            ]))
        .toList();
  }

  late final List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row
          .getCells()
          .map((cell) => Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8),
                child: Text(cell.value.toString(),
                    overflow: TextOverflow.ellipsis),
              ))
          .toList(),
    );
  }
}
