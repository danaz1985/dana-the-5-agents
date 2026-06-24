# מדריך: חיבור פרויקט ל‑GitHub עם עדכון אוטומטי

מדריך לחזרה על מה שעשינו, לכל פרויקט חדש.
החליפי רק שני דברים: **נתיב הפרויקט** ו‑**כתובת ה‑repo**.

> 💡 הדרך הכי קלה: פתחי את הפרויקט החדש ב‑Claude Code ותגידי:
> *"תחבר את הפרויקט הזה ל‑GitHub עם עדכון אוטומטי, הנה הכתובת: …"* — וזה ייעשה הכל לבד.

---

## שלב 0 — להכין את ה‑repo ב‑GitHub
ב‑GitHub: **New repository** → תני שם → **Create** (בלי README/gitignore, ריק).
העתיקי את כתובת ה‑`.git`.

## שלב 1 — אתחול git והגדרת זהות (פעם אחת למחשב)
```bash
cd "/נתיב/לפרויקט"
git config --global user.email "dana@ogglobalimport.com"
git config --global user.name "danaz1985"
git config --global init.defaultBranch main
git init
```

## שלב 2 — commit ראשון
```bash
git add -A
git commit -m "Initial commit"
```

## שלב 3 — חיבור ל‑GitHub ודחיפה ראשונה (עם טוקן)
קודם צרי **Personal Access Token** ב‑https://github.com/settings/tokens
(Tokens classic → הרשאת `repo`).
```bash
git branch -M main
git remote add origin https://github.com/danaz1985/שם-הפרויקט.git
git push "https://danaz1985:הטוקן_שלך@github.com/danaz1985/שם-הפרויקט.git" main:main
```

## שלב 4 — לשמור את הטוקן ב‑keychain (כדי לא להזין שוב)
```bash
printf "protocol=https\nhost=github.com\nusername=danaz1985\npassword=הטוקן_שלך\n\n" | git credential-osxkeychain store
git fetch origin
git branch --set-upstream-to=origin/main main
```
> אחרי זה כל `git push` רגיל יעבוד לבד.
> **הטוקן נשמר פעם אחת לכל המחשב** — אם כבר עשית את זה, אפשר לדלג על שלב 4.

## שלב 5 — קובצי env ו‑gitignore
צרי `.env`, `.env.example` (זהה אבל בלי ערכים אמיתיים), ו‑`.gitignore` שמכיל:
```
.env
.env.local
.env.*.local
.claude/settings.local.json
node_modules/
.DS_Store
*.log
```

## שלב 6 — ה‑hook לעדכון אוטומטי

**א.** צרי קובץ `.claude/hooks/git-autopush.sh`:
```bash
#!/usr/bin/env bash
cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
[ -z "$(git status --porcelain)" ] && exit 0
git add -A
git commit -q -m "auto: update $(date '+%Y-%m-%d %H:%M')" >&2 || exit 0
git push -q >&2 || echo "git-autopush: push failed" >&2
exit 0
```

**ב.** הרשאת הרצה:
```bash
chmod +x .claude/hooks/git-autopush.sh
```

**ג.** צרי `.claude/settings.json`:
```json
{
  "hooks": {
    "Stop": [
      { "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/git-autopush.sh\"", "timeout": 120 } ] }
    ]
  }
}
```

**ד.** הפעלה ראשונה: פתחי פעם אחת `/hooks` או הפעילי מחדש את Claude Code.
מאותו רגע — ובכל סשן חדש — כל שינוי בקבצים יעלה אוטומטית ל‑GitHub.

---

## איך זה מתנהג
- שינוי/יצירת קבצים → commit + push אוטומטי בסוף התור.
- תור של שיחה בלבד (בלי שינוי קבצים) → לא קורה כלום (אין commits מיותרים).
- אין צורך לבקש "תעלה" — זה קורה לבד.
