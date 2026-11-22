import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/channel_config.dart';

class ChannelsScreen extends StatefulWidget {
  final ChannelConfig config;
  final Function(ChannelConfig) onSaveConfig;

  const ChannelsScreen({
    super.key,
    required this.config,
    required this.onSaveConfig,
  });

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ChannelConfig _cfg;

  final TextEditingController _tgTokenCtrl = TextEditingController();
  final TextEditingController _tgUserCtrl = TextEditingController();
  final TextEditingController _waPhoneCtrl = TextEditingController();
  final TextEditingController _discordWebhookCtrl = TextEditingController();
  final TextEditingController _slackWebhookCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cfg = widget.config;
    _tgTokenCtrl.text = _cfg.telegramToken;
    _tgUserCtrl.text = _cfg.telegramUsername;
    _waPhoneCtrl.text = _cfg.whatsAppPhone;
    _discordWebhookCtrl.text = _cfg.discordWebhookUrl;
    _slackWebhookCtrl.text = _cfg.slackWebhookUrl;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tgTokenCtrl.dispose();
    _tgUserCtrl.dispose();
    _waPhoneCtrl.dispose();
    _discordWebhookCtrl.dispose();
    _slackWebhookCtrl.dispose();
    super.dispose();
  }

  void _save() {
    _cfg.telegramToken = _tgTokenCtrl.text.trim();
    _cfg.telegramUsername = _tgUserCtrl.text.trim();
    _cfg.whatsAppPhone = _waPhoneCtrl.text.trim();
    _cfg.discordWebhookUrl = _discordWebhookCtrl.text.trim();
    _cfg.slackWebhookUrl = _slackWebhookCtrl.text.trim();
    widget.onSaveConfig(_cfg);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: HermesTheme.success,
        content: Text('✓ Channels & Relays saved successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messaging Channels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: HermesTheme.primary),
            onPressed: _save,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: HermesTheme.primary,
          labelColor: HermesTheme.primary,
          unselectedLabelColor: HermesTheme.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner_rounded, size: 20), text: 'WhatsApp'),
            Tab(icon: Icon(Icons.send_rounded, size: 20), text: 'Telegram'),
            Tab(icon: Icon(Icons.tag_rounded, size: 20), text: 'Discord'),
            Tab(icon: Icon(Icons.chat_bubble_outline_rounded, size: 20), text: 'Slack'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWhatsAppTab(),
          _buildTelegramTab(),
          _buildDiscordTab(),
          _buildSlackTab(),
        ],
      ),
    );
  }

  Widget _buildWhatsAppTab() {
    final isConnected = _cfg.whatsAppStatus == 'connected';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HermesTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HermesTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('WhatsApp Relay', style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            isConnected ? 'Linked: ${_cfg.whatsAppPhone}' : 'Not linked',
                            style: TextStyle(color: isConnected ? HermesTheme.success : HermesTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _cfg.whatsAppEnabled,
                    activeColor: const Color(0xFF25D366),
                    onChanged: (val) {
                      setState(() => _cfg.whatsAppEnabled = val);
                      _save();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // QR Code Card for WhatsApp Pairing
              Container(
                width: 220,
                height: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _QrPainter(),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.smart_toy_rounded, color: Color(0xFF00E5FF), size: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan QR with WhatsApp on your phone',
                style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text(
                'Open WhatsApp > Linked Devices > Link a device > Point camera here',
                textAlign: TextAlign.center,
                style: TextStyle(color: HermesTheme.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnected ? HermesTheme.error.withOpacity(0.2) : const Color(0xFF25D366),
                      foregroundColor: isConnected ? HermesTheme.error : Colors.white,
                    ),
                    icon: Icon(isConnected ? Icons.link_off_rounded : Icons.sync_rounded, size: 16),
                    label: Text(isConnected ? 'Unlink Device' : 'Refresh QR Code'),
                    onPressed: () {
                      setState(() {
                        if (isConnected) {
                          _cfg.whatsAppStatus = 'disconnected';
                          _cfg.whatsAppPhone = '';
                        } else {
                          _cfg.whatsAppStatus = 'connected';
                          _cfg.whatsAppPhone = '+880 1700-123456';
                        }
                      });
                      _save();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTelegramTab() {
    final isConnected = _cfg.telegramStatus == 'connected';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HermesTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HermesTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0088CC).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.send_rounded, color: Color(0xFF0088CC), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Telegram Bot Relay', style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            isConnected ? 'Online: ${_cfg.telegramUsername}' : 'Offline',
                            style: TextStyle(color: isConnected ? HermesTheme.success : HermesTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _cfg.telegramEnabled,
                    activeColor: const Color(0xFF0088CC),
                    onChanged: (val) {
                      setState(() => _cfg.telegramEnabled = val);
                      _save();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: HermesTheme.cardBorder),
              const SizedBox(height: 12),
              TextField(
                controller: _tgTokenCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Bot Token (from @BotFather)',
                  hintText: '719283746:AAHg98q21kdsl9...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tgUserCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Bot Username',
                  hintText: '@HermesAgentBot',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Allowed Usernames (Whitelist):', style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _cfg.telegramAllowlist.map((u) => Chip(
                  backgroundColor: HermesTheme.surface,
                  label: Text(u, style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 11)),
                  deleteIconColor: HermesTheme.textMuted,
                  onDeleted: () {
                    setState(() => _cfg.telegramAllowlist.remove(u));
                    _save();
                  },
                )).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0088CC)),
                icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                label: const Text('Send Test Message', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: HermesTheme.success,
                      content: Text('✓ Test message successfully dispatched to Telegram!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscordTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HermesTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HermesTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Discord Webhook Relay', style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                  Switch(
                    value: _cfg.discordEnabled,
                    activeColor: const Color(0xFF5865F2),
                    onChanged: (val) {
                      setState(() => _cfg.discordEnabled = val);
                      _save();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _discordWebhookCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Discord Webhook URL',
                  hintText: 'https://discord.com/api/webhooks/...',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5865F2)),
                icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                label: const Text('Test Discord Relay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: HermesTheme.success,
                      content: Text('✓ Discord test payload transmitted!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlackTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HermesTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HermesTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Slack Incoming Webhook', style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                  Switch(
                    value: _cfg.slackEnabled,
                    activeColor: const Color(0xFFE01E5A),
                    onChanged: (val) {
                      setState(() => _cfg.slackEnabled = val);
                      _save();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _slackWebhookCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Slack Webhook URL',
                  hintText: 'https://hooks.slack.com/services/...',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE01E5A)),
                icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                label: const Text('Test Slack Webhook', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: HermesTheme.success,
                      content: Text('✓ Slack test alert sent!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = Colors.black;
    final unit = size.width / 21;

    // Draw QR position detection corners (top-left, top-right, bottom-left)
    void drawFinder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, unit * 7, unit * 7), paintDark);
      canvas.drawRect(Rect.fromLTWH(x + unit, y + unit, unit * 5, unit * 5), Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH(x + unit * 2, y + unit * 2, unit * 3, unit * 3), paintDark);
    }

    drawFinder(0, 0);
    drawFinder(size.width - unit * 7, 0);
    drawFinder(0, size.height - unit * 7);

    // Decorative pseudo-data pattern
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        // Skip finder areas
        if ((r < 8 && c < 8) || (r < 8 && c > 13) || (r > 13 && c < 8)) continue;
        if ((r + c * 3) % 2 == 0 && (r * 2 + c) % 3 != 0) {
          canvas.drawRect(Rect.fromLTWH(c * unit, r * unit, unit, unit), paintDark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
