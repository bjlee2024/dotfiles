# dotfiles

macOS / Linux 개발 환경을 한 번에 세팅하는 스크립트.

## 실행

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./setup-dev-env.sh
```

> Homebrew가 없으면 자동 설치됩니다.

## 설치 항목

### Font: JetBrainsMono Nerd Font

터미널, 에디터에서 사용하는 Nerd Font. 아이콘 글리프 포함.

### 1. Kitty (터미널 에뮬레이터)

GPU 가속 터미널. Catppuccin Macchiato 테마 + 투명 배경 적용.

| 키 | 동작 |
|---|---|
| `Ctrl+Shift+h/j/k/l` | 창 이동 (좌/하/상/우) |
| `Ctrl+Shift+9` | 수평 분할 |
| `Ctrl+Shift+0` | 수직 분할 |
| `Ctrl+Shift+]` / `[` | 다음/이전 탭 |
| `Ctrl+Shift+w` | 탭 닫기 |
| `Option+h/j/k/l` | Alt 키 전달 (tmux 연동용) |

### 2. tmux + oh-my-tmux (터미널 멀티플렉서)

[oh-my-tmux](https://github.com/gpakosz/.tmux) 기반. Catppuccin Macchiato 테마 적용.

| 키 | 동작 |
|---|---|
| `C-a` | Prefix (기본 `C-b`도 유지) |
| `Prefix + n` | Pane 번호 표시 후 선택 |
| `Prefix + x` | Pane 닫기 (확인 없이) |
| `Prefix + T` | sesh + fzf 세션 관리자 |

sesh 세션 관리자 단축키 (fzf 내부):

| 키 | 동작 |
|---|---|
| `Ctrl+a` | 전체 목록 |
| `Ctrl+t` | tmux 세션만 |
| `Ctrl+g` | config 목록 |
| `Ctrl+x` | zoxide 목록 |
| `Ctrl+f` | 홈 디렉토리 탐색 |
| `Ctrl+d` | tmux 세션 종료 |

플러그인 (TPM으로 자동 관리):
- **catppuccin/tmux** - 테마
- **tmux-nerd-font-window-name** - 창 이름에 Nerd Font 아이콘
- **tmux-resurrect** + **tmux-continuum** - 세션 자동 저장/복원
- **tmux-yank** - 시스템 클립보드 복사

### 3. Yazi (파일 매니저)

터미널 기반 파일 매니저. Catppuccin Macchiato 테마 적용.

```bash
yy    # yazi 실행 (종료 시 마지막 디렉토리로 cd)
```

- 숨김 파일 기본 표시
- Markdown 미리보기 (glow 사용)
- Git 상태 표시

### 4. Neovim + LazyVim (에디터)

[LazyVim](https://www.lazyvim.org/) 기반 Neovim 설정.

- 테마: Catppuccin Macchiato + Dracula lualine + 투명 배경
- 언어 지원: Go, Java, JSON, Markdown
- autoformat 꺼짐, spell check 꺼짐, 상대 줄번호 꺼짐

### 5. Starship (프롬프트)

Catppuccin Mocha 팔레트 적용 커스텀 프롬프트.

표시 정보: OS 아이콘 > 사용자@호스트 > 디렉토리 > Git 브랜치/상태 > 언어 버전 > Docker > 시간

지원 언어 감지: C, Rust, Go, Node.js, PHP, Java, Kotlin, Haskell, Python

## CLI 도구

스크립트가 함께 설치하는 CLI 도구:

| 도구 | 용도 |
|---|---|
| **fzf** | 퍼지 파인더 |
| **fd** | `find` 대체 (빠른 파일 검색) |
| **ripgrep** (`rg`) | `grep` 대체 (빠른 텍스트 검색) |
| **eza** | `ls` 대체 (아이콘, Git 상태 표시) |
| **zoxide** | `cd` 대체 (자주 가는 디렉토리 학습) |
| **sesh** | tmux 세션 관리자 |
| **glow** | 터미널 Markdown 렌더러 |
| **lazygit** | 터미널 Git UI |
| **lazydocker** | 터미널 Docker UI |

## Shell RC

`.bashrc` / `.zshrc`에 자동 추가되는 항목:

- `EDITOR=nvim`, `VISUAL=nvim`
- starship, zoxide, fzf 초기화
- `yy` 함수 (yazi wrapper)

## 설정 파일 위치

```
~/.config/
  kitty/          # kitty.conf, keymap.conf, current-theme.conf
  tmux/           # tmux.conf (-> oh-my-tmux 심링크), tmux.conf.local
  oh-my-tmux/     # gpakosz/.tmux 클론
  nvim/           # LazyVim 설정
  yazi/           # yazi.toml, theme.toml, init.lua, package.toml
  starship/       # starship.toml
```

## 지원 환경

- macOS (Homebrew)
- Linux (apt + Homebrew)
