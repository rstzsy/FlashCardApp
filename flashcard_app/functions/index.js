const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

exports.onTwoFactorEnabled = onDocumentUpdated("users/{userId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();

  if (!before.twoFactorEnabled && after.twoFactorEnabled) {
    const email = after.email;
    const name = after.name ?? "User";

    const mailOptions = {
      from: `"Mofu Flashcard 🐑" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: "🔐 Two-Factor Authentication Enabled",
      html: `
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/></head>
<body style="margin:0;padding:0;background-color:#EEF6FF;font-family:'Helvetica Neue',Arial,sans-serif;">

  <table width="100%" cellpadding="0" cellspacing="0" style="padding:40px 16px;">
    <tr>
      <td align="center">
        <table width="520" cellpadding="0" cellspacing="0" style="max-width:520px;width:100%;">

          <!-- HEADER CARD -->
          <tr>
            <td align="center" style="
              background: #aec9e0;
              border-radius:24px 24px 0 0;
              padding: 36px 32px 28px;
            ">
              <!-- Emoji thay thế logo -->
              <div style="
                width:80px;height:80px;
                background:white;
                border-radius:50%;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                font-size:40px;
                line-height:80px;
                box-shadow:0 8px 24px rgba(0,0,0,0.12);
                margin-bottom:16px;
              ">🐑</div>

              <h1 style="
                margin:0;
                font-size:22px;
                font-weight:800;
                color:#ffffff;
                text-shadow:0 2px 8px rgba(0,0,0,0.15);
                letter-spacing:-0.3px;
              ">Two-Factor Authentication</h1>

              <p style="
                margin:8px 0 0;
                font-size:14px;
                color:rgba(255,255,255,0.85);
              ">Security update for your account</p>
            </td>
          </tr>

          <!-- BODY CARD -->
          <tr>
            <td style="
              background:#ffffff;
              padding:32px;
              border-radius:0 0 24px 24px;
              box-shadow:0 12px 40px rgba(100,120,200,0.12);
            ">

              <!-- Greeting -->
              <p style="font-size:16px;color:#333;margin:0 0 16px;">
                Hi <strong style="color:#EE6983;">${name}</strong> 👋
              </p>

              <!-- Status badge -->
              <div style="
                background:linear-gradient(135deg,#e8f5e9,#f1f8e9);
                border:1.5px solid #a5d6a7;
                border-radius:12px;
                padding:14px 18px;
                margin-bottom:20px;
                display:flex;
                align-items:center;
              ">
                <span style="font-size:22px;margin-right:12px;">✅</span>
                <span style="font-size:14px;color:#2e7d32;font-weight:600;">
                  Biometric Authentication is now active
                </span>
              </div>

              <!-- Content -->
              <p style="font-size:15px;color:#555;line-height:1.7;margin:0 0 12px;">
                Your <strong>Mofu Flashcard</strong> account is now protected with 
                an extra layer of security.
              </p>

              <p style="font-size:15px;color:#555;line-height:1.7;margin:0 0 20px;">
                Every time you sign in, you'll be asked to verify using 
                <strong style="color:#EE6983;">Fingerprint</strong> or 
                <strong style="color:#EE6983;">Face ID</strong>.
              </p>

              <!-- Info box -->
              <div style="
                background:#f8f6ff;
                border-radius: 12px;
                padding:14px 18px;
                margin-bottom:24px;
              ">
                <p style="margin:0;font-size:13px;color:#666;line-height:1.6;">
                  🔒 This change was made on 
                  <strong>${new Date().toLocaleDateString('en-US',{year:'numeric',month:'long',day:'numeric'})}</strong>.
                  If this wasn't you, go to <strong>Settings → Two-Factor Auth</strong> and disable it immediately.
                </p>
              </div>

              <!-- Divider -->
              <div style="height:1px;background:#f0f0f0;margin:0 0 20px;"></div>

              <!-- Footer note -->
              <p style="font-size:12px;color:#aaa;text-align:center;margin:0;">
                © ${new Date().getFullYear()} Mofu Flashcard · You're receiving this because 2FA was enabled on your account.
              </p>

            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>

</body>
</html>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log(`✅ Email 2FA sent to ${email}`);
  }
});