# WordCraft Hebrew — Windows builds

בנייה לא רשמית של WordCraft עבור Windows ‏64 סיביות, עם ממשק עברי ותיקון סמן הטקסט.

## הורדה

פתחו [Actions](https://github.com/Danlasry/wordcraft-hebrew-builds/actions), בחרו ריצה שהצליחה (סימון ירוק) והורידו את `WordCraft-Hebrew-Windows-x64` תחת Artifacts. נדרשת התחברות ל־GitHub.
חלצו את ה־ZIP והפעילו את `wordcraft.exe`. בחרו File → Options → Interface language → עברית.
אין צורך בכלי בנייה במחשב המשתמש. התוכנה אינה חתומה. שמרו עותקים של מסמכים חשובים ובדקו תחילה מסמך ניסיון.

## בנייה חדשה

ב־Actions בחרו `Build WordCraft Hebrew for Windows` ואז `Run workflow`.
הבנייה רצה ב־Windows Server 2022 x64 עם Rust 1.95.0; בדיקות עברית, סמן ושיקוף רצות לפני בניית release.
התוצרים זמינים 30 יום. אפשר לשמור עותק או להפעיל בנייה נוספת.

## מקורות

- [WordCraft](https://github.com/storytold/wordcraft), commit `eecbb8fe57a56340e7fa109e8da7f1376a03e154` (0.13.2).
- [craft-i18n](https://github.com/storytold/craft-i18n), commit `19358491340b9f33d618673de6bcd40108d9a775`.
- Hebrew integration adapted from [PR 1303](https://github.com/storytold/wordcraft/pull/1303), plus `patches/pointer-fix.patch`.
- Upstream MIT / Apache-2.0 license texts included; source modifications recorded in patches.

Independent build configuration, not an official WordCraft release. No personal documents or user settings included. Gray interface theme not yet added.
