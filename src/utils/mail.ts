import nodemailer from 'nodemailer';
import { env } from '../config/env';

const transporter = nodemailer.createTransport({
  host: env.SMTP_HOST,
  port: env.SMTP_PORT,
  secure: env.SMTP_PORT === 465,
  auth: {
    user: env.SMTP_USER,
    pass: env.SMTP_PASS,
  },
});

export async function sendOtpEmail(to: string, code: string) {
  if (env.NODE_ENV !== 'production' || !env.SMTP_HOST) {
    console.log(`[mail] SKIP sending email to ${to} in dev mode. OTP Code: ${code}`);
    return;
  }

  const html = `
    <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 12px; color: #333;">
      <div style="text-align: center; margin-bottom: 30px;">
        <h2 style="color: #1a2a66; margin: 0;">Jinvani Community</h2>
        <p style="color: #666; font-size: 14px; margin-top: 5px;">Secure Verification</p>
      </div>
      <div style="background-color: #f9f9fb; padding: 30px; border-radius: 8px; text-align: center;">
        <p style="font-size: 16px; margin-bottom: 20px; color: #444;">Hello,</p>
        <p style="font-size: 16px; margin-bottom: 25px; color: #444;">Use the following verification code to complete your request:</p>
        <div style="font-size: 36px; font-weight: 700; color: #1a2a66; letter-spacing: 8px; margin-bottom: 25px;">${code}</div>
        <p style="font-size: 14px; color: #888; margin-top: 20px;">This code will expire in 5 minutes.</p>
      </div>
      <div style="margin-top: 30px; text-align: center; font-size: 12px; color: #999;">
        <p>If you didn't request this, you can safely ignore this email.</p>
        <p>&copy; 2024 Jinvani Community. All rights reserved.</p>
      </div>
    </div>
  `;

  try {
    await transporter.sendMail({
      from: env.SMTP_FROM,
      to,
      subject: `[Jinvani Community] Your Security Code: ${code}`,
      html,
    });
    console.log(`[mail] OTP email sent to ${to}`);
  } catch (err) {
    console.error(`[mail] Failed to send email to ${to}:`, err);
    throw err;
  }
}
