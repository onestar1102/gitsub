// =============================================================================
// lib/widgets/qna_section.dart
// =============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qna_provider.dart';
import '../providers/auth_provider.dart';

class QnaSection extends StatefulWidget {
  const QnaSection({super.key});

  @override
  State<QnaSection> createState() => _QnaSectionState();
}

class _QnaSectionState extends State<QnaSection> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  // ───────── 공통 스타일 상수 ─────────
  static const _bubbleColor = Color(0xFFFFDCDE);   // #FFDCDE

  @override
  Widget build(BuildContext context) {
    final qna     = context.watch<QnaProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    final messages = qna.messages.reversed.toList(); // 최신 메시지를 위로

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });

    return Column(
      children: [
        // ───────── 메시지 리스트 ─────────
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (_, i) {
              final m = messages[i];
              final isAnswer = m.isAdmin; // A = 관리자

              return Align(
                alignment:
                isAnswer ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(maxWidth: 280),

                  // ───── 배경 & 윤곽선 ─────
                  decoration: BoxDecoration(
                    color: _bubbleColor,                 // 배경색 공통
                    // color: isAnswer 배경 따로하고싶으면 이거 수정
                    //     ? Colors.white           // A → 흰색 배경
                    //     : Colors.lightBlue[100], // Q → 연한 하늘색
                    borderRadius: BorderRadius.circular(14),
                    border: isAnswer            // A 버블만 윤곽선 추가
                        ? Border.all(color: Colors.grey.shade400)
                        : null,
                  ),

                  child: Text('${isAnswer ? 'A. ' : 'Q. '}${m.text}',
                    style: const TextStyle(fontSize: 15), // 글자 크기 ↑
                  ),
                ),
              );
            },
          ),
        ),

        // ───────── 입력창 ─────────
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: isAdmin ? '답변 작성...' : '질문 작성...',
                  ),
                  onSubmitted: (txt) =>
                      _sendMessage(txt, context, isAdmin),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () =>
                    _sendMessage(_ctrl.text, context, isAdmin),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────── 공통 전송 함수 ─────────
  void _sendMessage(String raw, BuildContext ctx, bool isAdmin) {
    final txt = raw.trim();
    if (txt.isEmpty) return;

    ctx.read<QnaProvider>().send(txt, isAdmin: isAdmin);
    _ctrl.clear();
  }
}
