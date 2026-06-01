import 'package:flutter/material.dart';

class _C {
  static const rose        = Color(0xFFF4A8B0);
  static const roseDark    = Color(0xFFD4717A);
  static const green       = Color(0xFF7CB342);
  static const greenLight  = Color(0xFFE8F5E9);
  static const greenBdr    = Color(0xFFA5D6A7);
  static const purple      = Color(0xFF9C27B0);
  static const purpleLight = Color(0xFFF3E5F5);
  static const textDark    = Color(0xFF4A2E25);
  static const textMid     = Color(0xFF6D4C41);
  static const textMuted   = Color(0xFFBCAAA4);
  static const textGreen   = Color(0xFF388E3C);
}

class CuteNotificationDialog extends StatelessWidget {
  final String icon;
  final String title;
  final String body;
  final String? setTitle;
  final Color setBg;
  final Color setBorder;
  final Color setTitleColor;
  final String setSub;
  final Color setSubColor;
  final VoidCallback onStudy;
  final String cancelLabel;
  final String studyLabel;

  const CuteNotificationDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.setTitle,
    required this.setBg,
    required this.setBorder,
    required this.setTitleColor,
    required this.setSub,
    required this.setSubColor,
    required this.onStudy,
    this.cancelLabel = 'Later',
    this.studyLabel  = 'Study Now',
  });

  /// Helper: show dialog
  static Future<void> show({
    required BuildContext context,
    required String icon,
    required String title,
    required String body,
    String? setTitle,
    required Color setBg,
    required Color setBorder,
    required Color setTitleColor,
    required String setSub,
    required Color setSubColor,
    required VoidCallback onStudy,
    String cancelLabel = 'Later',
    String studyLabel  = 'Study Now',
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => CuteNotificationDialog(
        icon: icon,
        title: title,
        body: body,
        setTitle: setTitle,
        setBg: setBg,
        setBorder: setBorder,
        setTitleColor: setTitleColor,
        setSub: setSub,
        setSubColor: setSubColor,
        onStudy: onStudy,
        cancelLabel: cancelLabel,
        studyLabel: studyLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double dialogW = screenW - 48; 
    final double dialogH = dialogW / 0.889; 

    final double contentTop    = dialogH * 0.32;  
    final double contentBottom = dialogH * 0.24; 
    final double contentSide   = dialogW * 0.08; 

    final double xBtnTop   = dialogH * 0.14;
    final double xBtnRight = dialogW * 0.02;
    final double xBtnSize  = dialogW * 0.12;

    final double btnBottom = dialogH * 0.075;  
    final double btnHeight = dialogH * 0.115;
    final double btnSide   = dialogW * 0.08;
    final double btnGap    = dialogW * 0.05;
    final double btnW      = (dialogW - btnSide * 2 - btnGap) / 2;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: dialogW,
        height: dialogH,
        child: Stack(
          clipBehavior: Clip.none, 
          children: [

            Positioned.fill(
              child: Image.asset(
                'assets/game/notification_frame.png',
                fit: BoxFit.fill,
              ),
            ),

            Positioned(
              top: xBtnTop,
              right: xBtnRight,
              width: xBtnSize,
              height: xBtnSize,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: const SizedBox.expand(),
              ),
            ),

            Positioned(
              top: contentTop,
              left: contentSide,
              right: contentSide,
              bottom: contentBottom,

              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Icon + Title
                    Row(children: [
                      Text(icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: _C.textDark,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),

                    // Body
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _C.textMid,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Flashcard set info box
                    if (setTitle != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: setBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: setBorder, width: 1.2),
                        ),
                        child: Row(children: [
                          const Text('📚', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  setTitle!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: setTitleColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  setSub,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: setSubColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                  ],
                ),
              ),
            ),

            // ── 4. Nút "Later" – nút hồng trái ──────────────────────────────
            // Đo từ ảnh: left=13%, right=47%, top=84.5%, height=11%
            Positioned(
              top:   dialogH * 0.825,
              left:  dialogW * 0.13,
              right: dialogW * 0.45,  // = 100% - 47% = 53% từ phải
              height: dialogH * 0.110,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    cancelLabel,
                    style: TextStyle(
                      fontSize: dialogW * 0.042,
                      fontWeight: FontWeight.w800,
                      color: _C.roseDark,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top:   dialogH * 0.825,
              left:  dialogW * 0.37,
              right: dialogW * 0.13,  
              height: dialogH * 0.110,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                  onStudy();
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    studyLabel,
                    style: TextStyle(
                      fontSize: dialogW * 0.042,
                      fontWeight: FontWeight.w800,
                      color: _C.textGreen,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}