const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,  // ← dùng process.env thay functions.config()
    pass: process.env.EMAIL_PASS,
  },
});

exports.onTwoFactorEnabled = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before.twoFactorEnabled && after.twoFactorEnabled) {
      const email = after.email;
      const name = after.name ?? "bạn";

      const mailOptions = {
        from: `"My App 🔐" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: "Xác nhận: Bảo mật 2 lớp đã được kích hoạt",
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto;">
            <h2 style="color: #E24B4A;">🔐 Bảo mật 2 lớp đã bật</h2>
            <p>Xin chào <strong>${name}</strong>,</p>
            <p>
              Tài khoản của bạn vừa <strong>kích hoạt bảo mật 2 lớp (Biometric)</strong>.
              Từ lần đăng nhập tiếp theo, bạn sẽ cần xác thực vân tay hoặc Face ID.
            </p>
            <hr style="border: 1px solid #f0f0f0;" />
            <p style="color: #999; font-size: 12px;">
              Nếu bạn không thực hiện thao tác này, hãy vào Settings và tắt 2FA ngay.
            </p>
          </div>
        `,
      };

      await transporter.sendMail(mailOptions);
      console.log(`✅ Email 2FA sent to ${email}`);
    }
  });