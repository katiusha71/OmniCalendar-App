class PersianNumerals {
  static const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  static String convert(dynamic input) {
    return input.toString().replaceAllMapped(
      RegExp(r'[0-9]'),
      (match) => _persianDigits[int.parse(match.group(0)!)],
    );
  }
}
