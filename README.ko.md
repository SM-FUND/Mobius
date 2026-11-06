# Mobius 거래소 간 차익거래 엔진

[简体中文](README.md) | [English](README.en.md) | [日本語](README.ja.md) | **한국어**

[![Release](https://img.shields.io/github/v/release/SM-FUND/Mobius?label=release&color=1f6feb)](https://github.com/SM-FUND/Mobius/releases/latest)
[![Platform](https://img.shields.io/badge/platform-Linux%20x86__64-orange)](#실행-환경)
[![Install](https://img.shields.io/badge/install-한_줄_설치-2ea44f)](#한-줄-설치)

Mobius는 여러 거래소에서 같은 코인의 스프레드를 모니터링하고, 전략과 리스크 조건이 충족되면 두 레그를 동시에 주문합니다. 전략, 포지션, 체결, 수익은 콘솔에서 관리합니다.

이 저장소는 컴파일된 Linux x86_64 프로그램만 배포하며 소스 코드, 사용자 설정, 데이터베이스, 거래 자격 증명은 포함하지 않습니다. 프로그램은 내 서버에 설치되고 API 키는 그 서버에만 저장됩니다.

---

## 사용 전 안내

이 도구는 디지털 자산 거래를 다룹니다. 스프레드가 있다고 해서 반드시 수익이 나는 것은 아니며, 실제 결과는 다음 요인의 영향을 받습니다.

- 거래 수수료, 펀딩비 및 기타 플랫폼 수수료
- 네트워크 지연, 시세 변동, 호가창 깊이
- 슬리피지, 부분 체결, 두 레그의 체결 시점 차이
- 거래소 API·WebSocket 장애 또는 규칙 변경
- 증거금, 포지션, 강제 청산, 계정 권한 관련 위험
- 거주 국가 또는 지역의 법률, 규제, 플랫폼 접근 제한

먼저 소액으로 테스트하고 계정, 방향, 수량, 리스크 설정이 모두 올바른지 확인한 뒤 규모를 늘리세요. 이 도구는 투자 조언이 아니며 수익을 약속하지 않습니다. 거래, 계정, 자금 위험은 사용자 본인이 부담합니다.

---

## 지원 거래소와 전략

| 거래소 | 현물 | 선물 |
|---|:-:|:-:|
| Binance | ✓ | ✓ |
| OKX | ✓ | ✓ |
| Bybit | ✓ | ✓ |
| Bitget | ✓ | ✓ |
| Gate | ✓ | ✓ |
| Hyperliquid | ✓ | ✓ |
| Aster | ✓ | ✓ |
| Kraken | ✓ | ✓ |

- **스프레드 전략**: 현물/선물을 자유롭게 조합한 두 레그 스프레드로 진입·청산하며, 포지션 래더를 지원합니다.
- **선물 비율 전략(FR / SR)**: 두 레그의 가격 비율로 진입·청산합니다.
- **리스크 관리**: 최대 포지션, 손절, 리스크 강제 축소, 원클릭 전체 청산. 미확인 주문은 원래 주문 ID로 조회해 확인하며 중복 주문하지 않습니다.

실제로 사용할 수 있는 상품은 콘솔의 "스프레드 추가"에서 검색되는 것을 기준으로 합니다.

---

## 실행 환경

| 항목 | 요구 사항 |
|---|---|
| 운영체제 | Ubuntu 22.04 / 24.04 (Ubuntu만 지원) |
| 아키텍처 | x86_64 |
| CPU / 메모리 | 2코어 / 2 GB면 충분 |
| 디스크 | 20 GB 이상 |
| 네트워크 | 안정적이고 지연이 낮으며 각 거래소 API에 접속 가능할 것. 일본, 싱가포르 등 거래소와 가까운 리전 권장 |
| 포트 | 콘솔은 TCP 8787 사용 |

서버 아키텍처 확인:

```bash
uname -m
```

`x86_64`가 출력되어야 합니다. `aarch64` 또는 `arm64`라면 현재 버전은 실행할 수 없습니다.

---

## 한 줄 설치

새 Ubuntu 서버에서 실행합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/SM-FUND/Mobius/refs/heads/production/install.sh | sudo bash
```

설치 스크립트는 다음을 수행합니다.

1. 최신 릴리스를 내려받아 SHA-256을 검증하고, 검증에 실패하면 즉시 종료합니다.
2. 시스템 사용자 `mobius`를 만들고 부팅 시 자동 시작되는 systemd 서비스로 프로그램을 설치합니다.
3. 서비스를 시작하고 콘솔 주소와 **초기화 코드**를 출력합니다.

설치에 성공하면 마지막에 다음과 같은 출력이 표시됩니다.

```text
[mobius] Mobius 0.3.0+62 installed.
[mobius] Console:    http://203.0.113.10:8787
[mobius] Setup code: ABCD-EFGH
```

**초기화 코드는 잘 보관하고 스크린샷을 외부에 공유하지 마세요.** 인증 앱을 연결하기 전에는 "IP + 초기화 코드"를 아는 사람이라면 누구나 콘솔을 탈취할 수 있습니다.

> 설치 및 운영 명령의 터미널 출력은 영어입니다. AWS Lightsail 등 클라우드 업체의 웹 터미널에는 CJK 글꼴이 없는 경우가 많아 글자가 깨지기 때문입니다. 콘솔 화면은 "설정"에서 중국어 또는 영어로 전환할 수 있습니다.

### 8787 포트 개방

클라우드 서버에는 보통 보안 그룹이나 방화벽이 있습니다. TCP 8787을 허용하지 않으면 브라우저에서 콘솔을 열 수 없습니다.

- 클라우드 콘솔의 "보안 그룹 / 방화벽"에서 TCP 8787 인바운드 규칙을 추가하고, 출발지는 가급적 내 IP로 제한합니다.
- 서버에서 ufw를 사용 중이라면:

```bash
sudo ufw allow 8787/tcp
```

---

## 첫 로그인

1. 브라우저에서 `http://<서버 IP>:8787`을 엽니다.
2. 설치 출력에 표시된 초기화 코드를 입력합니다.
3. Google Authenticator, Microsoft Authenticator, 1Password 등 인증 앱으로 화면의 QR 코드를 스캔합니다.
4. 인증 앱에 표시된 6자리 코드를 입력하면 연결이 완료되고 콘솔에 들어갑니다.

연결이 완료되면 초기화 코드는 즉시 무효화되며, 이후에는 6자리 코드만으로 로그인합니다. 로그인 세션은 12시간 동안 유효합니다.

---

## 거래소 API 키 설정

콘솔의 "설정 → 거래소"에서 계정을 추가합니다. API 키를 만들 때는 반드시:

- **거래·조회 권한만 켜고 출금 권한은 끕니다**
- **IP 화이트리스트에 이 서버의 공인 IP를 등록합니다**
- 거래소마다 Mobius 전용 키를 따로 만들고 다른 프로그램과 함께 쓰지 않습니다

저장한 API 키는 서버에 암호화되어 저장되며 콘솔에 평문으로 다시 표시되지 않습니다.

---

## 보안 안내

- 콘솔은 TOTP 인증 앱을 연결해야만 사용할 수 있으므로, 초기화 코드가 없는 사람이 먼저 탈취할 수 없습니다.
- 초기화 코드나 6자리 코드를 연속으로 틀리면 잠깁니다. 같은 IP에서 5번 틀리면 1분간 잠기고, 이후 매번 2배로 늘어나 최대 1시간입니다.
- 같은 6자리 코드는 한 번만 사용할 수 있어 가로채더라도 재사용할 수 없습니다.
- **콘솔은 HTTP로 접속하므로 트래픽이 암호화되지 않습니다.** 세션과 화면에 입력한 API 키가 평문으로 네트워크를 지나갑니다. 그래서 위의 "출금 끄기 + IP 화이트리스트"는 필수이며, 보안 그룹에서도 8787 출발지를 내 IP로만 허용하는 것을 권장합니다. 암호화가 필요하면 인증서가 있는 리버스 프록시를 앞단에 두세요.

---

## 온라인 업데이트

새 버전이 배포되면 콘솔 오른쪽 위에 새 버전 버튼(`新版本 vX.X.X.X`)이 나타납니다. 업데이트를 실행하면:

1. 실행 중인 전략이 먼저 자동으로 중지됩니다.
2. 서버가 새 버전을 내려받아 검증하고, 데이터를 백업한 뒤 버전을 전환합니다. 서비스 재시작에 약 1분이 걸립니다.
3. 새 버전이 시작되면 중지했던 전략이 자동으로 원래 상태로 복원됩니다.
4. 새 버전 시작에 실패하면 이전 버전과 업데이트 전 데이터로 자동 롤백합니다.

업데이트가 끝나면 페이지가 자동으로 새로고침됩니다. 설치 명령을 다시 실행할 필요는 없습니다.

모든 버전과 업데이트 내역은 [Releases](https://github.com/SM-FUND/Mobius/releases)에서 볼 수 있습니다.

---

## 자주 쓰는 명령

```bash
# 서비스 상태 확인
sudo systemctl status mobius

# 로그 실시간 확인
sudo journalctl -u mobius -f

# 최근 100줄 로그 확인
sudo journalctl -u mobius -n 100 --no-pager

# 서비스 재시작
sudo systemctl restart mobius

# 온라인 업데이트 로그 확인
sudo journalctl -u mobius-update -n 50 --no-pager

# 인증 앱 분실: 인증 앱과 모든 로그인 세션을 지우고 새 초기화 코드 출력
sudo mobius-update reset-auth

# 최신 버전 재설치(데이터와 설정 유지)
curl -fsSL https://raw.githubusercontent.com/SM-FUND/Mobius/refs/heads/production/install.sh | sudo bash
```

---

## 파일 위치

| 경로 | 내용 |
|---|---|
| `/opt/mobius/current` | 현재 실행 중인 프로그램(`/opt/mobius/releases/<버전>`을 가리킴) |
| `/var/lib/mobius/data` | 계정, 원장, 시세 기록 등 데이터(암호화된 API 키 포함) |
| `/var/lib/mobius/backups` | 가장 최근 온라인 업데이트 전의 데이터 백업 |
| `/etc/mobius/mobius.env` | 서비스 설정 |

백업할 때는 `/var/lib/mobius/data` 전체를 복사해 암호화한 뒤 다른 곳에 보관하세요.

---

## 자주 묻는 질문

**브라우저에서 콘솔이 열리지 않음**

먼저 서비스가 실행 중인지 확인합니다: `sudo systemctl status mobius`. 서비스가 정상이라면 대개 클라우드 보안 그룹이나 ufw에서 TCP 8787을 허용하지 않은 경우입니다.

**초기화 코드를 찾을 수 없음**

`sudo mobius-update reset-auth`를 실행하면 새 초기화 코드를 생성해 출력합니다. 연결된 인증 앱과 모든 로그인 세션이 지워진다는 점에 유의하세요.

**"验证失败次数过多"(인증 실패 횟수 초과)라고 표시됨**

잘못 입력한 횟수가 많아 일시적으로 잠긴 상태입니다. 안내된 시간이 지난 뒤 다시 시도하세요(최대 1시간). 서비스를 재시작(`sudo systemctl restart mobius`)해도 잠금이 해제됩니다.

**업데이트 실패**

콘솔에 실패 원인이 표시되고, 프로그램은 자동으로 이전 버전으로 롤백하며 전략도 복원됩니다. 원인 확인: `sudo journalctl -u mobius-update -n 50 --no-pager`.

**제거**

```bash
sudo systemctl disable --now mobius mobius-update.path
sudo rm -f /etc/systemd/system/mobius.service /etc/systemd/system/mobius-update.path /etc/systemd/system/mobius-update.service /usr/local/sbin/mobius-update
sudo systemctl daemon-reload
sudo rm -rf /opt/mobius
```

위 명령은 데이터와 설정을 유지합니다. 더 이상 필요 없다고 확인되면 `sudo rm -rf /var/lib/mobius /etc/mobius`로 모든 데이터(API 키 포함)를 삭제하고, `sudo userdel mobius`로 시스템 사용자를 삭제하세요.

---

이 저장소의 내용은 릴리스 파이프라인이 자동으로 생성합니다. 직접 변경 사항을 커밋하지 마세요.
