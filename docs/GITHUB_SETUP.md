# GitHub 터미널 연동 가이드

## 1. Git 사용자 정보 설정 (한 번만)

커밋에 표시될 이름과 GitHub에 가입한 이메일을 설정합니다.

```bash
git config --global user.name "본인이름"
git config --global user.email "github가입이메일@example.com"
```

예시:
```bash
git config --global user.name "manbo"
git config --global user.email "manbo@gmail.com"
```

---

## 2. GitHub 인증 (둘 중 하나 선택)

### 방법 A: GitHub CLI 사용 (추천)

1. **GitHub CLI 설치** (없다면):
   ```bash
   brew install gh
   ```

2. **로그인**:
   ```bash
   gh auth login
   ```
   - GitHub.com 선택 → HTTPS 또는 SSH 선택 → 브라우저에서 인증

3. **푸시**:
   ```bash
   cd /Users/manbo/Documents/Feely
   git push -u origin main
   ```

---

### 방법 B: SSH 키 사용

1. **SSH 키 생성** (이메일은 GitHub 가입 이메일):
   ```bash
   ssh-keygen -t ed25519 -C "github가입이메일@example.com" -f ~/.ssh/id_ed25519 -N ""
   ```

2. **공개 키를 클립보드에 복사** (macOS):
   ```bash
   pbcopy < ~/.ssh/id_ed25519.pub
   ```

3. **GitHub에 키 등록**:
   - https://github.com/settings/keys 접속
   - "New SSH key" → 제목 입력, 키 붙여넣기 → Add SSH key

4. **연결 확인**:
   ```bash
   ssh -T git@github.com
   ```
   "Hi manbo01! You've successfully authenticated..." 메시지가 나오면 성공.

5. **푸시** (이미 origin이 SSH로 설정되어 있음):
   ```bash
   cd /Users/manbo/Documents/Feely
   git push -u origin main
   ```

---

## 3. 푸시가 "unrelated histories"로 거부될 때

GitHub에서 README로 레포를 만들었다면 한 번만 아래 실행:

```bash
cd /Users/manbo/Documents/Feely
git pull origin main --allow-unrelated-histories
# 충돌 시 편집 후
git add .
git commit -m "Merge remote README"
git push -u origin main
```
