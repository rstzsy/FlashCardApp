# flashcard_app

- thư mục core: dùng chung cho toàn app (widget, service(api service, storage))
- thư mục model: model dữ liệu
- thư mục feature: chia theo từng model(mỗi model bao gồm những thư mục: thư mục screen, thư mục widget, file controller)
    + vidu: model _auth
                  _ _ screens: login_screen.dart, register_screen.dart
                  _ _ widgets: button.dart, sidebar.dart
                  _ _controllers: login_controller.dart, register_controller.dart