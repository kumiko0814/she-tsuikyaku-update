#!/bin/bash
# 追客配信アップデート案モックの公開スクリプト
set -e
cd "$(dirname "$0")"

git init -q 2>/dev/null || true
git add index.html
git commit -qm "SHE tsuikyaku nurturing update mockup (anonymized)" || true

if ! git remote get-url origin >/dev/null 2>&1; then
  gh repo create kumiko0814/she-tsuikyaku-update --public --source=. --push
else
  git push -u origin master
fi

gh api repos/kumiko0814/she-tsuikyaku-update/pages -X POST \
  -f "source[branch]=master" -f "source[path]=/" 2>/dev/null || echo "(Pages設定済み)"

echo ""
echo "⏳ ビルド待ち（30〜60秒）..."
for i in $(seq 1 24); do
  CODE=$(curl -s -o /dev/null -w '%{http_code}' https://kumiko0814.github.io/she-tsuikyaku-update/)
  if [ "$CODE" = "200" ]; then
    echo "✅ 公開完了: https://kumiko0814.github.io/she-tsuikyaku-update/"
    exit 0
  fi
  sleep 5
done
echo "⚠️ まだ200になっていません。1分後にURLを直接確認してください。"
