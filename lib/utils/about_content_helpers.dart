import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme_roles.dart';
import '../providers/app_provider.dart';

Color aboutDescriptionColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? TCnt.neutralSecond(context).withOpacity(0.9)
      : TCnt.neutralSecond(context);
}

Widget buildRichTextWithIrage(BuildContext context, String text) {
  final appProvider = Provider.of<AppProvider>(context, listen: false);
  final isPersian = appProvider.language == 'fa';

  final iragePattern = RegExp(r'(Irage|ایراژ)\s*\(([^)]+)\)');
  final match = iragePattern.firstMatch(text);

  if (match == null) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        letterSpacing: -0.098,
        color: TCnt.neutralSecond(context),
      ),
    );
  }

  final beforeText = text.substring(0, match.start);
  final irageText = isPersian ? 'ایراژ' : 'Irage';
  final heritageText = ' (${match.group(2)})';
  final afterText = text.substring(match.end);

  return Text.rich(
    TextSpan(
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        letterSpacing: -0.098,
        color: TCnt.neutralSecond(context),
      ),
      children: [
        if (beforeText.isNotEmpty) TextSpan(text: beforeText),
        TextSpan(
          text: irageText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? TCnt.neutralMain(context)
                : null,
          ),
        ),
        TextSpan(
          text: heritageText,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? TCnt.neutralTertiary(context)
                : TCnt.neutralTertiary(context).withOpacity(0.7),
          ),
        ),
        if (afterText.isNotEmpty) TextSpan(text: afterText),
      ],
    ),
  );
}

Widget buildRichTextWithIrageQuoted(BuildContext context, String text) {
  final appProvider = Provider.of<AppProvider>(context, listen: false);
  final isPersian = appProvider.language == 'fa';

  final iragePattern = RegExp(r'["«](Irage|ایراژ)["»]\s*\(([^)]+)\)');
  final match = iragePattern.firstMatch(text);

  if (match == null) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        letterSpacing: -0.098,
        color: TCnt.neutralSecond(context),
      ),
    );
  }

  final beforeText = text.substring(0, match.start);
  final quoteStart = match.group(0)!.startsWith('«') ? '«' : '"';
  final irageText = isPersian ? 'ایراژ' : 'Irage';
  final quoteEnd = match.group(0)!.contains('»') ? '»' : '"';
  final heritageText = ' (${match.group(2)})';
  final afterText = text.substring(match.end);

  final textParts = afterText.split('\n\n');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            letterSpacing: -0.098,
            color: TCnt.neutralSecond(context),
          ),
          children: [
            if (beforeText.isNotEmpty) TextSpan(text: beforeText),
            TextSpan(text: quoteStart),
            TextSpan(
              text: irageText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? TCnt.neutralMain(context)
                    : null,
              ),
            ),
            TextSpan(text: quoteEnd),
            TextSpan(
              text: heritageText,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TCnt.neutralTertiary(context)
                    : TCnt.neutralTertiary(context).withOpacity(0.7),
              ),
            ),
            if (textParts.isNotEmpty && textParts[0].isNotEmpty)
              TextSpan(text: textParts[0]),
          ],
        ),
      ),
      if (textParts.length > 1)
        ...textParts.sublist(1).expand(
          (part) => [
            const SizedBox(height: 12),
            Text(
              part,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                letterSpacing: -0.098,
                color: TCnt.neutralSecond(context),
              ),
            ),
          ],
        ),
    ],
  );
}

Widget buildTermsSectionWithIrage(
  BuildContext context, {
  required String number,
  required String title,
  required String content,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      number.isNotEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '$number.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      letterSpacing: -0.32,
                      color: TCnt.neutralMain(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      letterSpacing: -0.32,
                      color: TCnt.neutralMain(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.32,
                color: TCnt.neutralMain(context),
                fontWeight: FontWeight.w600,
              ),
            ),
      const SizedBox(height: 6),
      Padding(
        padding: number.isEmpty ? EdgeInsets.zero : const EdgeInsets.only(left: 24),
        child: buildRichTextWithIrage(context, content),
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget buildTermsSectionWithIrageQuoted(
  BuildContext context, {
  required String number,
  required String title,
  required String content,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      number.isNotEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '$number.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      letterSpacing: -0.32,
                      color: TCnt.neutralMain(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      letterSpacing: -0.32,
                      color: TCnt.neutralMain(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.32,
                color: TCnt.neutralMain(context),
                fontWeight: FontWeight.w600,
              ),
            ),
      const SizedBox(height: 6),
      Padding(
        padding: number.isEmpty ? EdgeInsets.zero : const EdgeInsets.only(left: 24),
        child: buildRichTextWithIrageQuoted(context, content),
      ),
      const SizedBox(height: 16),
    ],
  );
}

