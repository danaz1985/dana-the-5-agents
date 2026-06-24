#!/usr/bin/env bash
# git-autopush.sh — מעלה אוטומטית את כל השינויים ל-GitHub בסוף כל תור.
# מופעל על ידי hook מסוג Stop ב-.claude/settings.json.
# אם אין שינויים — יוצא בשקט בלי לעשות כלום.

# עבור לתיקיית הפרויקט (אם הוגדרה על ידי ה-harness)
cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" 2>/dev/null || exit 0

# ודא שאנחנו בתוך git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# אם אין שינויים — אין מה לעשות
if [ -z "$(git status --porcelain)" ]; then
  exit 0
fi

# הוסף, בצע commit ודחוף
git add -A
git commit -q -m "auto: update $(date '+%Y-%m-%d %H:%M')" >&2 || exit 0
git push -q >&2 || echo "git-autopush: push failed (changes are committed locally)" >&2

exit 0
