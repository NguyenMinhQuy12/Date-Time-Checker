bool isLeapYear(int year) {
  return year % 400 == 0 || (year % 4 == 0 && year % 100 != 0);
}

int daysInMonth(int month, int year) {
  if ([1, 3, 5, 7, 8, 10, 12].contains(month)) return 31;
  if ([4, 6, 9, 11].contains(month)) return 30;
  if (month == 2) return isLeapYear(year) ? 29 : 28;
  return 0;
}

bool checkDateLogic(int day, int month, int year) {
  if (day < 1 || day > 31) return false;
  if (month < 1 || month > 12) return false;
  if (year < 1920 || year > 3000) return false;

  return day <= daysInMonth(month, year);
}