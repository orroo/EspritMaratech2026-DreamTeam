import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/program_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/program_service.dart';
import '../../utils/constants.dart';

class ProgramsListScreen extends StatefulWidget {
  final bool showAddDialog;
  const ProgramsListScreen({super.key, this.showAddDialog = false});

  @override
  State<ProgramsListScreen> createState() => _ProgramsListScreenState();
}

class _ProgramsListScreenState extends State<ProgramsListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.showAddDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProgramDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final programService = Provider.of<ProgramService>(context);
    final user = authService.currentUser;
    final isCoach = user?.role == UserRole.adminCoach ||
        user?.role == UserRole.adminPrincipal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmes d\'entraînement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un programme...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ProgramModel>>(
              stream: programService.getProgramsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                final programs = snapshot.data ?? [];
                final filteredPrograms = programs.where((p) {
                  return p.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      p.description
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredPrograms.isEmpty) {
                  return const Center(child: Text('Aucun programme trouvé.'));
                }

                return ListView.builder(
                  itemCount: filteredPrograms.length,
                  itemBuilder: (context, index) {
                    final program = filteredPrograms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(program.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(program.description),
                            const SizedBox(height: 4),
                            Text(
                              'Par: ${program.coachName ?? "Coach"} • ${program.timestamp.day}/${program.timestamp.month}/${program.timestamp.year}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (program.pdfUrl != null)
                              IconButton(
                                icon: const Icon(Icons.share,
                                    color: Colors.green, size: 20),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: program.pdfUrl!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Lien copié !')),
                                  );
                                },
                              ),
                            if (isCoach) ...[
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue, size: 20),
                                onPressed: () => _showProgramDialog(context,
                                    program: program),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 20),
                                onPressed: () =>
                                    _confirmDelete(context, program.id),
                              ),
                            ],
                            if (!isCoach && program.pdfUrl != null)
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () {
                                  // Implement download/open link logic
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isCoach
          ? FloatingActionButton(
              onPressed: () => _showProgramDialog(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showProgramDialog(BuildContext context, {ProgramModel? program}) {
    final titleController = TextEditingController(text: program?.title);
    final descController = TextEditingController(text: program?.description);
    final urlController = TextEditingController(text: program?.pdfUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            program == null ? 'Nouveau Programme' : 'Modifier le Programme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: urlController,
                decoration:
                    const InputDecoration(labelText: 'URL du PDF (Optionnel)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              final programService =
                  Provider.of<ProgramService>(context, listen: false);

              final newProgram = ProgramModel(
                id: program?.id ?? '',
                title: titleController.text,
                description: descController.text,
                coachId: authService.currentUser?.id ?? '',
                coachName: authService.currentUser?.name,
                timestamp: DateTime.now(),
                pdfUrl:
                    urlController.text.isNotEmpty ? urlController.text : null,
              );

              final navContext = context;
              if (program == null) {
                await programService.createProgram(newProgram);
              } else {
                await programService.updateProgram(program.id, newProgram);
              }
              if (navContext.mounted) Navigator.pop(navContext);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer?'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce programme?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Non')),
          TextButton(
            onPressed: () async {
              final navContext = context;
              await Provider.of<ProgramService>(context, listen: false)
                  .deleteProgram(id);
              if (navContext.mounted) Navigator.pop(navContext);
            },
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
