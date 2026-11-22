import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/skill.dart';

class PluginCatalogItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final String trigger;
  final String instructions;
  final String? configPlaceholder;

  const PluginCatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.trigger,
    required this.instructions,
    this.configPlaceholder,
  });
}

class SkillsScreen extends StatefulWidget {
  final List<Skill> skills;
  final Function(Skill) onAddSkill;
  final Function(Skill) onToggleSkill;
  final Function(String) onDeleteSkill;

  const SkillsScreen({
    super.key,
    required this.skills,
    required this.onAddSkill,
    required this.onToggleSkill,
    required this.onDeleteSkill,
  });

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  // Curated Official & Community Plugins Marketplace
  final List<PluginCatalogItem> _marketplacePlugins = const [
    PluginCatalogItem(
      id: 'plugin_supabase',
      name: 'Supabase Cloud Backend',
      description: 'PostgreSQL database, real-time sync, auth & file storage for apps and websites.',
      category: 'Database',
      icon: Icons.bolt_rounded,
      color: Color(0xFF3ECF8E), // Supabase Green
      trigger: 'Connect Supabase, database schema, SQL migrations, user authentication',
      instructions: 'Generate Supabase client code, write SQL migrations, manage RLS security policies.',
      configPlaceholder: 'Supabase Project URL & Anon Key',
    ),
    PluginCatalogItem(
      id: 'plugin_firebase',
      name: 'Firebase Cloud Services',
      description: 'Cloud Firestore, Firebase Auth, Cloud Functions, and Firebase Hosting deployment.',
      category: 'Cloud',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFFFCA28), // Firebase Amber
      trigger: 'Setup Firebase, write Firestore rules, Cloud Functions, Firebase Auth',
      instructions: 'Author Firebase configurations, Firestore security rules, client SDK initialization.',
      configPlaceholder: 'Firebase Project ID / google-services.json',
    ),
    PluginCatalogItem(
      id: 'plugin_canva',
      name: 'Canva Design & Media Studio',
      description: 'Generate marketing banners, social media designs, posters, and brand graphics.',
      category: 'Design',
      icon: Icons.palette_rounded,
      color: Color(0xFF00C4CC), // Canva Cyan
      trigger: 'Design in Canva, create banner, make social media poster, brand color palette',
      instructions: 'Call Canva design APIs, suggest color palettes, render SVG/PNG layouts and banners.',
      configPlaceholder: 'Canva API Token',
    ),
    PluginCatalogItem(
      id: 'plugin_figma',
      name: 'Figma UI/UX & Code Connect',
      description: 'Inspect Figma design frames and convert them into pixel-perfect Flutter & Web code.',
      category: 'Design',
      icon: Icons.layers_rounded,
      color: Color(0xFFA259FF), // Figma Purple
      trigger: 'Convert Figma to code, extract design tokens, build UI from Figma design',
      instructions: 'Parse Figma JSON/links, export vector assets, generate responsive widgets and CSS.',
      configPlaceholder: 'Figma Personal Access Token',
    ),
    PluginCatalogItem(
      id: 'plugin_cloudflare',
      name: 'Cloudflare Edge Cloud & Workers',
      description: 'Deploy web apps to Cloudflare Pages, run serverless Workers, and manage DNS/KV.',
      category: 'Cloud',
      icon: Icons.cloud_queue_rounded,
      color: Color(0xFFF38020), // Cloudflare Orange
      trigger: 'Deploy to Cloudflare, setup Worker, host website on Pages, configure DNS',
      instructions: 'Generate wrangler.toml, deploy static assets via wrangler CLI, configure edge routes.',
      configPlaceholder: 'Cloudflare API Token & Account ID',
    ),
    PluginCatalogItem(
      id: 'plugin_netlify',
      name: 'Netlify Web Deploy & Forms',
      description: 'One-click frontend site hosting with automated preview links and serverless forms.',
      category: 'Cloud',
      icon: Icons.language_rounded,
      color: Color(0xFF00AD9F), // Netlify Teal
      trigger: 'Deploy to Netlify, setup netlify.toml, create site preview link',
      instructions: 'Build frontend bundle, deploy via netlify-cli, generate instant preview URL.',
      configPlaceholder: 'Netlify Auth Token',
    ),
    PluginCatalogItem(
      id: 'plugin_github',
      name: 'GitHub Teamwork & Git DevOps',
      description: 'Manage git repositories, create pull requests, commit changes, and trigger CI/CD.',
      category: 'DevOps',
      icon: Icons.terminal_rounded,
      color: Color(0xFF818CF8), // Indigo
      trigger: 'Git commit, push to GitHub, create PR, trigger GitHub Actions build',
      instructions: 'Execute gh and git commands, write release notes, inspect workflow logs.',
      configPlaceholder: 'GitHub Personal Access Token (PAT)',
    ),
    PluginCatalogItem(
      id: 'plugin_web_scraper',
      name: 'Web Scraping & Browser Automation',
      description: 'Extract data from live websites, bypass static barriers, and automate browser tasks.',
      category: 'Tools',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF38BDF8), // Electric Cyan
      trigger: 'Scrape website, crawl page data, automate web interaction',
      instructions: 'Use Python BeautifulSoup, Puppeteer, or curl to fetch and parse structured web data.',
      configPlaceholder: 'Optional proxy / user-agent settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isPluginInstalled(String pluginId) {
    return widget.skills.any((s) => s.id == pluginId);
  }

  void _installPlugin(PluginCatalogItem plugin) {
    if (_isPluginInstalled(plugin.id)) return;

    final configCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: plugin.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(plugin.icon, color: plugin.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plugin.name,
                        style: const TextStyle(
                          color: HermesTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        plugin.category,
                        style: TextStyle(color: plugin.color, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              plugin.description,
              style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HermesTheme.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: HermesTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Trigger Keyword:',
                    style: TextStyle(color: HermesTheme.warning, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plugin.trigger,
                    style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (plugin.configPlaceholder != null) ...[
              const SizedBox(height: 14),
              TextField(
                controller: configCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'API Key / Configuration (Optional)',
                  hintText: plugin.configPlaceholder,
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: plugin.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_task_rounded, color: Colors.black, size: 20),
                label: const Text(
                  'Add Plugin to Agent',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () {
                  String instructions = plugin.instructions;
                  if (configCtrl.text.trim().isNotEmpty) {
                    instructions += '\nConfig: ${configCtrl.text.trim()}';
                  }

                  final newSkill = Skill(
                    id: plugin.id,
                    name: plugin.name,
                    description: plugin.description,
                    trigger: plugin.trigger,
                    instructions: instructions,
                    category: plugin.category,
                    isEnabled: true,
                  );

                  widget.onAddSkill(newSkill);
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ ${plugin.name} added successfully!'),
                      backgroundColor: HermesTheme.success,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills & Plugin Hub'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: HermesTheme.primary,
          labelColor: HermesTheme.primary,
          unselectedLabelColor: HermesTheme.textMuted,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text('Active Skills (${widget.skills.length})'),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.extension_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Plugin Store'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: HermesTheme.primary),
            tooltip: 'Create Custom Skill',
            onPressed: () => _showAddCustomSkillDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Installed & Active Skills
          _buildActiveSkillsTab(),

          // Tab 2: Plugin Marketplace
          _buildPluginMarketplaceTab(),
        ],
      ),
    );
  }

  Widget _buildActiveSkillsTab() {
    final filtered = widget.skills.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Search active skills...',
              prefixIcon: Icon(Icons.search_rounded, size: 20, color: HermesTheme.textMuted),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No active skills found. Check Plugin Store!', style: TextStyle(color: HermesTheme.textMuted)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final skill = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: HermesTheme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: skill.isEnabled ? HermesTheme.cardBorder : HermesTheme.cardBorder.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: HermesTheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  skill.category,
                                  style: const TextStyle(
                                    color: HermesTheme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: skill.isEnabled,
                                activeColor: HermesTheme.primary,
                                onChanged: (_) => widget.onToggleSkill(skill),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: HermesTheme.danger, size: 18),
                                onPressed: () => widget.onDeleteSkill(skill.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            skill.name,
                            style: const TextStyle(
                              color: HermesTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            skill.description,
                            style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: HermesTheme.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.bolt_rounded, size: 14, color: HermesTheme.warning),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Trigger: ${skill.trigger}',
                                        style: const TextStyle(
                                          color: HermesTheme.textMuted,
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  skill.instructions,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: HermesTheme.textSecondary,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPluginMarketplaceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _marketplacePlugins.length,
      itemBuilder: (context, index) {
        final plugin = _marketplacePlugins[index];
        final isInstalled = _isPluginInstalled(plugin.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HermesTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isInstalled ? plugin.color.withOpacity(0.5) : HermesTheme.cardBorder,
              width: isInstalled ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: plugin.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(plugin.icon, color: plugin.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plugin.name,
                                style: const TextStyle(
                                  color: HermesTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: plugin.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                plugin.category,
                                style: TextStyle(
                                  color: plugin.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plugin.description,
                          style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '⚡ ${plugin.trigger}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isInstalled) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: HermesTheme.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: HermesTheme.success, size: 16),
                          SizedBox(width: 4),
                          Text('Added', style: TextStyle(color: HermesTheme.success, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plugin.color.withOpacity(0.2),
                        foregroundColor: plugin.color,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: plugin.color.withOpacity(0.4)),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Plugin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _installPlugin(plugin),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCustomSkillDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final trigCtrl = TextEditingController();
    final instCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesTheme.surface,
        title: const Text('Create Custom Skill (SKILL.md)', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Skill Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: trigCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Trigger Keyword / Condition'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: instCtrl,
                maxLines: 3,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Instructions / Prompt Guidance'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: HermesTheme.textMuted)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: HermesTheme.primary),
            child: const Text('Save Skill', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final skill = Skill(
                  id: 'skill_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  trigger: trigCtrl.text.trim(),
                  instructions: instCtrl.text.trim(),
                  category: 'Custom',
                );
                widget.onAddSkill(skill);
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }
}
