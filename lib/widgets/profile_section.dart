// =============================================================================
// lib/widgets/profile_section.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ───── 아바타 ─────
            CircleAvatar(
              radius: 50,
              backgroundImage: profile.photoUrl.isNotEmpty
                  ? NetworkImage(profile.photoUrl)
                  : null,
              child: profile.photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 12),

            // ───── 소개·링크 박스 ─────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black,     // ← 윤곽선 더 진하게
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // 소개 텍스트 ↓ 글자 크기 살짝 줄임
                  Text(
                    profile.intro.isNotEmpty
                        ? profile.intro
                        : '소개를 작성해주세요',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  // 링크들
                  ...profile.links.map(
                        (url) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: InkWell(
                        onTap: () => launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication),
                        child: Text(
                          url,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isAdmin)
              TextButton(
                onPressed: () => _showEditDialog(context, profile),
                child: const Text('소개 · 링크 편집'),
              ),
          ],
        ),
      ),
    );
  }

  // 편집 다이얼로그 (기존 코드 그대로) ─────────────────────────────────────
  void _showEditDialog(BuildContext ctx, ProfileProvider prov) {
    final introCtrl = TextEditingController(text: prov.intro);
    final linkCtrls = prov.links
        .map((e) => TextEditingController(text: e))
        .toList(growable: true);

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('소개 · 링크 편집'),
          content: SizedBox(
            width: 320,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextField(
                  controller: introCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: '소개'),
                ),
                const SizedBox(height: 12),
                ...List.generate(linkCtrls.length, (i) => Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: linkCtrls[i],
                        decoration:
                        InputDecoration(labelText: '링크 ${i + 1}'),
                      ),
                    ),
                    IconButton(
                      icon:
                      const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () =>
                          setState(() => linkCtrls.removeAt(i)),
                    )
                  ],
                )),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('링크 추가'),
                  onPressed: () =>
                      setState(() => linkCtrls.add(TextEditingController())),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            ElevatedButton(
              onPressed: () async {
                final links = linkCtrls
                    .map((c) => c.text.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                await prov.updateIntroAndLinks(introCtrl.text.trim(), links);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
