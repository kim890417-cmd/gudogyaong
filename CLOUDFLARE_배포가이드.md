# 🐾 구독야옹 (Gudok Yaong) - 클라우드플레어(Cloudflare Pages) 초간단 배포 가이드

바탕화면의 `구독야옹` 폴더에 제작된 홈페이지는 **Cloudflare Pages**에 즉시 배포할 수 있도록 완벽하게 최적화되어 있습니다.  
클라우드플레어의 **무료 플랜(Free Plan)**만으로도 **트래픽/대역폭 무제한, 무료 HTTPS 보안 인증서, 초고속 전 세계 글로벌 CDN**이 평생 무료로 제공됩니다.

---

## 🌟 [방법 1] 마우스 드래그 앤 드롭으로 1분 만에 배포하기 (가장 추천! 쉬움 ⭐⭐⭐⭐⭐)

별도의 개발 도구나 프로그램 설치 없이 웹 브라우저에서 클릭 몇 번으로 즉시 전 세계에 배포할 수 있습니다.

### 1단계. 클라우드플레어 로그인
1. [Cloudflare 대시보드 (https://dash.cloudflare.com)](https://dash.cloudflare.com/)에 접속하여 로그인합니다. (계정이 없다면 무료 회원가입)

### 2단계. Pages 프로젝트 생성
1. 좌측 메뉴에서 **[Compute (Workers & Pages)]** (또는 **[Workers & Pages]**)를 클릭합니다.
2. 우측 상단의 **[Create application (애플리케이션 생성)]** 버튼을 클릭합니다.
3. 상단 탭에서 **[Pages]** 탭을 선택합니다.
4. **[Upload assets (직접 업로드)]** 버튼을 클릭합니다.

### 3단계. 프로젝트 이름 입력 및 폴더 업로드
1. **프로젝트 이름(Project name)**을 입력합니다. (예: `gudokyaong` 또는 원하는 영문 이름)
   > 이 이름에 따라 `https://gudokyaong.pages.dev`와 같은 무료 도메인 주소가 생성됩니다.
2. 바탕화면에 있는 **`구독야옹` 폴더 전체**를 웹 브라우저의 업로드 박스 안으로 **드래그 앤 드롭(Drag & Drop)**합니다.
3. **[Deploy site (배포)]** 버튼을 클릭합니다.

### 4단계. 배포 완료! 🎉
- 약 10~20초 뒤 배포가 완료되며, 화면에 생성된 고유 주소(예: `https://gudokyaong.pages.dev`)가 나타납니다.
- 링크를 클릭하면 스마트폰, PC 등 전 세계 어디서나 접속할 수 있는 홈페이지가 즉시 열립니다!

---

## 💻 [방법 2] 터미널 명령어 한 줄로 배포하기 (Wrangler CLI)

Node.js가 설치되어 있다면 터미널에서 명령어 한 줄로 즉시 배포할 수 있습니다.

1. PowerShell 또는 명령 프롬프트를 엽니다.
2. 바탕화면의 `구독야옹` 폴더로 이동합니다:
   ```powershell
   cd C:\Users\sadase\Desktop\구독야옹
   ```
3. 다음 명령어를 실행합니다:
   ```powershell
   npx wrangler pages deploy . --project-name=gudokyaong
   ```
4. 최초 1회 브라우저 창이 뜨며 클라우드플레어 로그인 승인을 요청합니다. [Allow]를 누르면 자동으로 업로드 및 배포가 완료됩니다!

---

## 🔄 [방법 3] 깃허브(GitHub) 자동 배포 연동 (유지보수 추천)

1. GitHub에 새 레포지토리를 만들고 `구독야옹` 폴더의 파일들을 푸시(Push)합니다.
2. Cloudflare 대시보드 -> **[Workers & Pages]** -> **[Create application]** -> **[Pages]** -> **[Connect to Git]** 선택.
3. 내 깃허브 레포지토리를 선택하고 [Save and Deploy] 클릭.
4. 이제 코드를 수정하고 `git push`할 때마다 클라우드플레어가 10초 만에 사이트를 자동 갱신해 줍니다!

---

## 🌐 내 개인 도메인(예: `gudokyaong.com`) 무료 연결 방법

1. Cloudflare Pages 대시보드에서 생성된 `gudokyaong` 프로젝트를 클릭합니다.
2. 상단 메뉴에서 **[Custom domains (커스텀 도메인)]** 탭을 클릭합니다.
3. **[Set up a custom domain]** 버튼을 누르고 보유 중인 도메인을 입력합니다.
4. 안내에 따라 DNS CNAME 레코드를 연결하면, 무료 SSL 인증서가 자동 발급되며 5분 내로 연결됩니다.

---

## 📁 프로젝트 파일 구성 안내

- **`index.html`**: 구독야옹 메인 웹페이지 (브론즈/실버/골드 맞춤 플랜, 냥이 실시간 시식 일지, 영양 칼럼, 제휴 큐레이션, 반응형 모달 포함)
- **`assets/images/`**: 고해상도 최적화 이미지 및 파비콘 (`hero-kitchen.jpg`, `process-ingredients.jpg`, `box-preview.jpg`, `favicon.svg`)
- **`_headers`**: Cloudflare Pages 전용 보안 및 초고속 브라우저 캐싱 규칙
- **`_routes.json`**: Cloudflare Pages 정적 라우팅 설정
- **`robots.txt` & `sitemap.xml`**: 네이버, 구글, 다음 등 검색엔진 노출을 위한 SEO 최적화 파일
- **`wrangler.toml`**: Cloudflare CLI 배포 설정 파일
- **`package.json`**: 로컬 프리뷰 및 배포 명령어 스크립트

---

## 🖥️ 컴퓨터에서 지금 바로 확인하는 방법
배포 전에도 바탕화면 `구독야옹` 폴더 안의 **`index.html`** 파일을 더블 클릭하시면 크롬이나 엣지 브라우저에서 디자인과 모든 인터랙티브 기능을 바로 확인하실 수 있습니다!
