import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_icons.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../utils/about_content_helpers.dart';
import '../utils/svg_helper.dart';
import '../utils/font_helper.dart';
import 'content_bottom_sheet.dart';

void showAboutBottomSheet(BuildContext context, {required bool isPersian}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.3),
    isScrollControlled: true,
    builder: (context) => ContentBottomSheet(
      title: isPersian ? 'درباره ما' : 'About Us',
      titleIconEmoji: '🕊️',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildRichTextWithIrage(
            context,
            isPersian
                ? 'ایراژ (میراث ایران) یک برنامه تقویم مستقل و ساخته شده توسط جامعه است که توسط افرادی که به ایران - ایران واقعی - اعتقاد دارند، ایجاد شده است.'
                : 'The Irage (Iranian Heritage) is a community-built, independent calendar app created by people who believe in Iran — the real Iran.',
          ),
          const SizedBox(height: 16),
          Text(
            isPersian
                ? 'نه نسخه‌ای که توسط رژیم جمهوری اسلامی بازنویسی شده است، بلکه ایرانِ غرور، فرهنگ، هویت و آزادی باستانی.'
                : 'Not the version rewritten by the Islamic Republic regime, but the Iran of ancient pride, culture, identity, and freedom.',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  )
                : TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            isPersian
                ? 'ما اولین برنامه تقویم ملی‌گرای ایرانی هستیم و هیچ ارتباطی با جمهوری اسلامی ندارد.'
                : 'We are the first Iranian nationalist calendar app with zero connection to the Islamic Republic.',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  )
                : TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPersian ? '• بدون حمایت مالی' : '• No sponsorship',
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        )
                      : TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPersian ? '• بدون روابط سیاسی' : '• No political ties',
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        )
                      : TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPersian ? '• بدون تبلیغات' : '• No propaganda',
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        )
                      : TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isPersian
                ? 'فقط عشق خالص به میهن و تعهد به بیان حقیقت.'
                : 'Just pure love for our homeland and a commitment to tell the truth.',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  )
                : TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            isPersian
                ? 'این پروژه دو داستان قدرتمند را گرد هم می‌آورد:'
                : 'This project brings together two powerful stories:',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  )
                : TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            isPersian ? '⭐ ۱. میراث ما' : '⭐ 1. Our Heritage',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 16,
                    height: 1.4,
                    letterSpacing: -0.32,
                    color: TCnt.neutralMain(context),
                    fontWeight: FontWeight.w600,
                  )
                : TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    letterSpacing: -0.32,
                    color: TCnt.neutralMain(context),
                    fontWeight: FontWeight.w600,
                  ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: isPersian ? 0 : 24, right: isPersian ? 24 : 0),
            child: Text(
              isPersian
                  ? 'جشن‌ها، سنت‌ها، اسطوره‌ها، قهرمانان و فرهنگ باستانی که مدت‌ها قبل از وجود رژیم، هویت واقعی ما را به عنوان یک ملت شکل داده‌اند.'
                  : 'The festivals, traditions, myths, heroes, and ancient culture that shaped who we truly are as a nation long before the regime existed.',
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
                    )
                  : TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isPersian ? '🔥 ۲. واقعیت ما' : '🔥 2. Our Reality',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 16,
                    height: 1.4,
                    letterSpacing: -0.32,
                    color: TCnt.neutralMain(context),
                    fontWeight: FontWeight.w600,
                  )
                : TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    letterSpacing: -0.32,
                    color: TCnt.neutralMain(context),
                    fontWeight: FontWeight.w600,
                  ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: isPersian ? 0 : 24, right: isPersian ? 24 : 0),
            child: Text(
              isPersian
                  ? 'یک سابقه روشن و بدون سانسور از جنایاتی که رژیم جمهوری اسلامی علیه مردم ایران مرتکب شده است - بنابراین هیچ زندگی، هیچ نامی و هیچ بی‌عدالتی هرگز فراموش نمی‌شود.'
                  : 'A clear, uncensored record of the crimes committed by the Islamic Republic regime against the people of Iran — so no life, no name, and no injustice is ever forgotten.',
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
                    )
                  : TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isPersian
                ? 'آنها با هم چیزی اساسی را به ما یادآوری می‌کنند:'
                : 'Together, they remind us of something essential:',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  )
                : TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            isPersian
                ? 'ما قبل از این رژیم هویتی داشتیم. و مدت‌ها پس از آن نیز هویتی خواهیم داشت.'
                : 'We had an identity before this regime. And we will have one long after it.',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  )
                : TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            isPersian
                ? 'این برنامه به صورت ناشناس، توسط ایرانیانی ساخته شده است که حقیقت را به ترس ترجیح دادند - افرادی که می‌خواهند هر کاربر افتخار ایرانی بودن و مسئولیت یادآوری کسانی را که جنگیدند، رنج کشیدند یا ساکت شدند، احساس کند.'
                : 'This app is built anonymously, by Iranians who chose truth over fear — people who want every user to feel the pride of being Iranian and the responsibility of remembering those who fought, suffered, or were silenced.',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  )
                : TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  ),
          ),
          const SizedBox(height: 24),
          _buildNoteCallout(
            context: context,
            isPersian: isPersian,
            content: isPersian
                ? 'اگر اینجا هستید، شما هم بخشی از این مأموریت هستید.'
                : 'If you\'re here, you\'re part of that mission too.',
          ),
          const SizedBox(height: 24),
          Text(
            isPersian ? 'دلیل ساخت برنامه' : 'Why this exists',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 16,
                    height: 1.4,
                    letterSpacing: -0.32,
                    color: TCnt.neutralMain(context),
                    fontWeight: FontWeight.w600,
                  )
                : TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    letterSpacing: -0.32,
                    color: TCnt.neutralMain(context),
                    fontWeight: FontWeight.w600,
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            isPersian
                ? 'این فقط یک اپلیکیشن نیست. این یک آرشیو زنده است. یک تقویم از آنچه بوده‌ایم و آنچه هنوز هستیم. این به ما کمک می‌کند که تاریخ واقعی را در دسترس نگه داریم، از قهرمانان خود یاد کنیم و از عزیزانی که از دست داده‌ایم مراقبت کنیم.'
                : 'This isn’t just an app. It’s a living archive. A calendar of who we were and who we still are. It helps us keep our real history accessible, honor our heroes, and care for those we’ve lost.',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  )
                : TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: aboutDescriptionColor(context),
                  ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPersian ? '• این فقط یک تقویم نیست.' : '• This isn\'t just a calendar.',
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        )
                      : TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPersian ? '• این یک عمل آرام مقاومت است.' : '• It\'s a quiet act of resistance.',
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        )
                      : TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPersian ? '• ادای احترام به میراث ما.' : '• A tribute to our heritage.',
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        )
                      : TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPersian ? '• یادآوری قدرت جمعی ما.' : '• A reminder of our collective strength.',
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        )
                      : TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPersian ? '• و گامی کوچک به سوی ایرانی که شایسته آن هستیم.' : '• And a small step toward the Iran we deserve.',
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        )
                      : TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: aboutDescriptionColor(context),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isPersian ? 'تماس با ما' : 'Contact us',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 16,
                    height: 1.4,
                    letterSpacing: -0.32,
                    color: TCnt.neutralMain(context),
                    fontWeight: FontWeight.w600,
                  )
                : TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    letterSpacing: -0.32,
                    color: TCnt.neutralMain(context),
                    fontWeight: FontWeight.w600,
                  ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
                    )
                  : TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: -0.098,
                      color: aboutDescriptionColor(context),
                    ),
              children: [
                TextSpan(
                  text: isPersian
                      ? 'اگر مایل به ارتباط با ما هستید، می‌توانید به آدرس '
                      : 'If you’d like to reach out to us, you can send an email to ',
                ),
                TextSpan(
                  text: 'info@irage.site',
                  style: TextStyle(
                    color: TCnt.brandMain(context),
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final Uri emailUri = Uri.parse('mailto:info@irage.site');
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      }
                    },
                ),
                TextSpan(
                  text: isPersian
                      ? ' ایمیل ارسال کنید. همچنین، در صورت داشتن هرگونه گزارش یا بازخورد، می‌توانید از طریق ایمیل '
                      : '. Alternatively, if you have any reports or feedback, you can contact us via ',
                ),
                TextSpan(
                  text: 'feedback@irage.site',
                  style: TextStyle(
                    color: TCnt.brandMain(context),
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final Uri emailUri = Uri.parse('mailto:feedback@irage.site');
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      }
                    },
                ),
                TextSpan(
                  text: isPersian ? ' با ما تماس بگیرید.' : '.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPersian ? 'توسعه‌دهنده: تیم توسعه ایراژ' : 'Developer: Irage Development Team',
                      style: isPersian
                          ? FontHelper.getYekanBakh(
                              fontSize: 14,
                              color: aboutDescriptionColor(context),
                            )
                          : TextStyle(
                              fontSize: 14,
                              color: aboutDescriptionColor(context),
                            ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isPersian ? 'ما را دنبال کنید' : 'Follow us on',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.32,
                        color: TCnt.neutralMain(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSocialButton(
                          context: context,
                          iconPath: AppIcons.xSocial,
                          onTap: () async {
                            final Uri appUri = Uri.parse('twitter://user?screen_name=irage_official');
                            final Uri webUri = Uri.parse('https://x.com/irage_official');
                            try {
                              if (await canLaunchUrl(appUri)) {
                                await launchUrl(appUri, mode: LaunchMode.externalApplication);
                              } else if (await canLaunchUrl(webUri)) {
                                await launchUrl(webUri, mode: LaunchMode.platformDefault);
                              }
                            } catch (_) {
                              if (await canLaunchUrl(webUri)) {
                                await launchUrl(webUri, mode: LaunchMode.platformDefault);
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildSocialButton(
                          context: context,
                          iconPath: AppIcons.instagram,
                          onTap: () async {
                            final Uri appUri = Uri.parse('instagram://user?username=irage.site');
                            final Uri webUri = Uri.parse('https://instagram.com/irage.site');
                            try {
                              if (await canLaunchUrl(appUri)) {
                                await launchUrl(appUri, mode: LaunchMode.externalApplication);
                              } else if (await canLaunchUrl(webUri)) {
                                await launchUrl(webUri, mode: LaunchMode.platformDefault);
                              }
                            } catch (_) {
                              if (await canLaunchUrl(webUri)) {
                                await launchUrl(webUri, mode: LaunchMode.platformDefault);
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildSocialButton(
                          context: context,
                          iconPath: AppIcons.github,
                          onTap: () async {
                            final Uri uri = Uri.parse('https://github.com/irage-official/Calendar');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: isPersian ? 0 : 16,
                  right: isPersian ? 16 : 0,
                ),
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    'assets/images/adjective/hamkari-meli.png',
                    width: 84,
                    height: 112,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      onClose: () => Navigator.of(context).pop(),
    ),
  );
}

Widget _buildNoteCallout({
  required BuildContext context,
  required bool isPersian,
  required String content,
}) {
  return IntrinsicHeight(
    child: Row(
      textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Border with height matching content
        Container(
          width: 2,
          color: ThemeColors.indigo500,
          margin: EdgeInsets.only(
            left: isPersian ? 8 : 0,
            right: isPersian ? 0 : 8,
          ),
        ),
        // Content without top/bottom padding
        Expanded(
          child: Text(
            content,
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    height: 1.6,
                    letterSpacing: -0.098,
                    color: aboutDescriptionColor(context),
                  )
                : TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    letterSpacing: -0.098,
                    color: aboutDescriptionColor(context),
                  ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSocialButton({
  required BuildContext context,
  required String iconPath,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeColors.gray100.withOpacity(0.1)
            : ThemeColors.gray900.withOpacity(0.06),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgIconWidget(
          assetPath: iconPath,
          size: 20,
          color: TCnt.neutralSecond(context),
        ),
      ),
    ),
  );
}

