import 'package:flutter/material.dart';
import 'package:inkspire/providers/theme_provider.dart';
import 'package:inkspire/providers/chat_provider.dart';
import 'package:inkspire/data/services/animated_background.dart';
import 'package:inkspire/presentation/screens/prompt_screen.dart';
import 'package:inkspire/presentation/widgets/chat_list_view.dart';
import 'package:inkspire/presentation/widgets/chat_grid_view.dart';
import 'package:inkspire/presentation/widgets/custom_fab.dart';
import 'package:inkspire/utils/view_preferences.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isGridView = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Load saved view mode preference
    _loadViewMode();
  }

  Future<void> _loadViewMode() async {
    final isGridView = await ViewPreferences.getViewMode();
    setState(() {
      _isGridView = isGridView;
      if (_isGridView) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
      if (_isGridView) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }

      // Save the preference
      ViewPreferences.saveViewMode(_isGridView);

      // Show feedback to user
      final snackBar = SnackBar(
        content: Text('Switched to ${_isGridView ? 'grid' : 'list'} view'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        width: 200,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('InkSpire'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 4,
        shadowColor: isDarkMode ? Colors.white10 : Colors.black12,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          // View mode toggle button
          IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.list_view,
              progress: _animation,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          RefreshIndicator(
            onRefresh: () async {
              // Show a loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Refreshing your inspiration...'),
                    ],
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[700],
                ),
              );

              // Call the refresh method in the provider
              await chatProvider.refreshChats();

              // Show completion message if there were no errors
              if (context.mounted && chatProvider.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Your gallery is up to date!'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted && chatProvider.error != null) {
                // Show error message if there was a problem
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${chatProvider.error}'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            color: Theme.of(context).primaryColor,
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isGridView
                  ? ChatGridView(
                key: const ValueKey('grid'),
                chats: chatProvider.chats,
                onRemoveChat: (id) {
                  chatProvider.removeChat(id);
                },
              )
                  : ChatListView(
                key: const ValueKey('list'),
                chats: chatProvider.chats,
                onRemoveChat: (id) {
                  chatProvider.removeChat(id);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PromptScreen(
                onNewChat: (chat) {
                  chatProvider.addChat(chat);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}