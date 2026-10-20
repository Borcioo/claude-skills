# claude-skills

Zespołowy zestaw do Claude Code: minimalny, z decyzjami opartymi na researchu (październik 2026) i testach A/B na naszym repo `utility-sites`.

## Decyzja

**Na co dzień instalujecie dwa pluginy:**

| Plugin | Po co | Koszt kontekstu |
|---|---|---|
| `superpowers` (v7.0.0, przypięty po SHA) | proces: brainstorming → plan → wykonanie z review per zadanie, TDD, debugowanie, weryfikacja przed „gotowe” | ~650 tokenów na sesję (wstrzykiwany `using-superpowers`) + listing 15 skilli |
| `guardrails` (nasz) | twarde blokady: edycja i zapis z powłoki do `.env`, lockfile'ów, `.git/`, workflowów CI; z `CLAUDE_PROTECT_TESTS=1` także testów | zero (sam hook, bez kontekstu modelu) |

Resztę dają ustawienia i komendy wbudowane w Claude Code (sekcja „Konfiguracja zamiast pluginów”).

**Opcjonalnie**, w marketplace z pinami, ale poza domyślnym zestawem:
- `typescript-lsp` i `php-lsp`: na `utility-sites` nie dały zysku (wyniki niżej). Warto je włączyć przy dużych bazach kodu i refaktorach przez wiele pakietów.
- `context7`: aktualna dokumentacja bibliotek. Nie testowany; definicje narzędzi ładują się na żądanie, więc nieużywany prawie nic nie kosztuje.

## Dlaczego nie 20 pluginów

Większość popularnych pluginów dubluje to, co superpowers albo Claude Code już mają. Dwa systemy robiące to samo konkurują o te same wyzwalacze.

| Odrzucony plugin | Co go zastępuje |
|---|---|
| `code-review`, `pr-review-toolkit` | superpowers `requesting-code-review` / `receiving-code-review` (osobny recenzent bez historii sesji, review po każdym zadaniu w SDD); review całego PR: wbudowane `/code-review` |
| `commit-commands` (`/commit-push-pr`) | superpowers `finishing-a-development-branch` (merge, push, PR) |
| `skill-creator` | superpowers `writing-skills` |
| `hookify` | `guardrails` + hooki w `.claude/settings.json` projektu |
| `ralph-loop`, frameworki pętli i rojów | wbudowane `/goal` (warunek końca oceniany przez osobny model); w superpowers `subagent-driven-development` i `dispatching-parallel-agents` |
| `security-guidance`, skille Trail of Bits | wbudowane `/security-review` przed PR |
| `claude-md-management`, `episodic-memory`, claude-mem | natywna pamięć: CLAUDE.md poniżej 200 linii, `.claude/rules/`, auto-pamięć |
| `codemap` (nasz eksperyment) | wbudowany Glob/Grep, bo test A/B nie dał zysku (`experiments/codemap/RESULTS.md`) |
| wtyczki dostawców (Stripe, Supabase, Vercel, Laravel Boost…), `frontend-design` | tylko w projekcie, który ich używa, instalowane z `claude-plugins-official` w zakresie projektu |

## Dlaczego nie „mniejsze skille zamiast superpowers”

- **Brak dowodów, że mniejsze skille wygrywają.** W SWE-Skills-Bench 39 z 49 publicznych skilli dało 0% poprawy. W WebDev-Skills-Bench skille obniżały skuteczność o 1–4%, a sam dodatkowy tekst, nawet niezwiązany z zadaniem, odtwarzał większość tej straty. Więcej małych skilli to więcej tekstu w kontekście i więcej konfliktów wyzwalaczy.
- **Superpowers daje coś, czego Claude Code nie ma wbudowanego:** dyscyplinę TDD, systematyczne debugowanie i plan z review po każdym zadaniu. Plan mode i `/goal` pokrywają tylko część tego.
- **Niezależnego benchmarku superpowers też nie ma.** Zamiana oznaczałaby utratę Waszych modyfikacji bez dowodu, że będzie lepiej.
- **Co warto zrobić z Waszym forkiem:**
  - przez kilka tygodni sprawdzać `/skill-doctor`, czyli które skille się wyzwalają;
  - usuwać te, których nie używacie;
  - zmiany dopisywać w formie sekcji „Gotchas” z realnych porażek, a nie ogólnych zasad.

## Własne skille: tylko deterministyczne albo projektowe

Ogólne skille-poradniki („python-pro”, „security expert”) to dokładnie ta kategoria, która w benchmarkach nie pomaga, więc ich nie piszemy. Uniwersalne dodatki mają sens wtedy, gdy wymuszają coś mechanicznie, tak jak `guardrails`.

Wiedza o projekcie trafia do CLAUDE.md i `.claude/rules/` danego repo. CLAUDE.md w `utility-sites` (78 linii: komendy, konwencje, pułapki) to dobry wzorzec.

## Testy A/B na `utility-sites`

Testy na prawdziwym repo (gałąź `develop`, 805 plików), po 3 uruchomienia na wariant, model Sonnet, przez `claude plugin eval`:

| Kandydat | Przypadki | Skuteczność z / bez | Tury z / bez | Koszt testu | Werdykt |
|---|---|---|---|---|---|
| `codemap` | 5 (listy plików, przegląd eksportów, kontrola) | 100% / 100% | średnio 4,4 / 3,7 | $1,77 | odrzucony |
| `typescript-lsp` | 2 (zmiana nazwy z pułapką WebHID + typecheck, lista wywołań) | 100% / 100% | 30,7 / 28,0 i 5,0 / 4,0 | $1,55 | opcjonalny |

Szczegóły: [`experiments/codemap/RESULTS.md`](experiments/codemap/RESULTS.md) i [`evals/typescript-lsp/RESULTS.md`](evals/typescript-lsp/RESULTS.md). Przypadki są w repo, więc test da się powtórzyć dla każdego nowego kandydata. Zasada: plugin wchodzi do zestawu tylko z wyraźnym zyskiem na naszym kodzie.

`guardrails` sprawdziliśmy inaczej:
- 22 przypadki jednostkowe (z `jq` i bez niego), w tym ścieżki Windows i polecenia PowerShell;
- test na żywo: sesja headless poproszona o dopisanie do `.env` została zablokowana, plik nietknięty.

## Szybki start

```text
/plugin marketplace add Borcioo/claude-skills
/plugin install superpowers@borcioo-skills
/plugin install guardrails@borcioo-skills
```

Opcjonalnie, w dużym projekcie TS lub PHP (najpierw binarka: `npm i -g typescript-language-server typescript intelephense`):

```text
/plugin install typescript-lsp@borcioo-skills
/plugin install php-lsp@borcioo-skills
/plugin install context7@borcioo-skills
```

Jeśli używacie własnej wersji superpowers, podmieńcie źródło wpisu `superpowers` w `.claude-plugin/marketplace.json` na swój fork, przypięty po SHA. Nie instalujcie obu wersji naraz.

## Konfiguracja zamiast pluginów

Najmocniej udokumentowane w researchu dźwignie to ustawienia i nawyki, nie dodatki:

- **Szablon projektu** [`templates/project/.claude/`](templates/project/.claude/):
  - `settings.json` rejestruje marketplace i włącza `superpowers` oraz `guardrails`;
  - włącza sandbox z blokadą `~/.ssh` i `~/.aws/credentials` oraz ukrytymi `GITHUB_TOKEN` i `NPM_TOKEN`;
  - `agents/Explore.md` przełącza eksplorację na Haiku (wbudowany Explore używa modelu głównej sesji, a przy Fable na subskrypcji Opusa).
- **Model:** domyślnie Sonnet. Opus wybierany na starcie trudnego zadania, bez zmiany modelu w trakcie sesji, bo zmiana unieważnia cache promptu.
- **Autonomia:** `/goal "testy i typecheck przechodzą, żaden plik testów nie zmieniony"` zamiast pętli Ralpha. W nienadzorowanych przebiegach `CLAUDE_PROTECT_TESTS=1`, bo ponad 79% oszustw Claude w ImpossibleBench to modyfikacja testów.
- **Wbudowane komendy:** `/code-review`, `/security-review`, `/simplify`, plan mode, `claude --worktree`.
- **Wielu agentów:** jeden piszący i subagenci tylko do odczytu. Agent teams kosztują ok. 7x tokenów i zostają wyłączone, chyba że do review albo debugowania konkurencyjnych hipotez.

## guardrails: szczegóły

- **Pliki chronione:**
  - `.env` i `.env.*`;
  - lockfile'y: npm, pnpm, yarn, bun, composer, poetry, uv, cargo;
  - `.git/` i `.github/workflows/`.
- **Co blokuje:**
  - narzędzia `Edit` i `Write`;
  - zapisy z powłoki: `>`, `tee`, `sed -i`, `cp`, `mv`, `rm` oraz `Set-Content`, `Out-File` i podobne w PowerShell.

  Odczyt i polecenia bez zapisu, takie jak `cat .env.example`, `pnpm install` czy `2>&1`, przechodzą.
- **`CLAUDE_PROTECT_TESTS=1`:** dochodzą `tests/`, `__tests__/`, `e2e/`, `*.test.*`, `*.spec.*` i `*_test.go`. Włączajcie tylko w nienadzorowanych przebiegach, bo w interaktywnym TDD pisanie testów to pierwszy krok.
- **Wymagania:** bash (na Windowsie Git Bash, którego Claude Code i tak używa); `jq` nie jest wymagany.
- **To nie jest pełna ochrona:** zdeterminowany skrypt (np. `node -e` piszący do pliku) przejdzie. Od tego jest sandbox i review diffu.

## Research

- [`docs/research/2026-10-raport.md`](docs/research/2026-10-raport.md): pełny raport. Obejmuje skille, MCP, koszty tokenów, pamięć i Obsidian, pętle, roje, praktyki Anthropic i twórców Claude Code oraz checklistę bezpieczeństwa.
- [`docs/research/notes/`](docs/research/notes/): notatki źródłowe z 8 wątków.

Ranking w raporcie to przegląd rynku. Decyzją jest ten README.

## Jak podbić pin

1. `git ls-remote https://github.com/<owner>/<repo> HEAD` (przy tagu adnotowanym bierz commit z `^{}`).
2. Przejrzyj diff między starym a nowym SHA, zwłaszcza hooki, skrypty, `.mcp.json` i opisy skilli.
3. Podmień `sha` w `.claude-plugin/marketplace.json` i uruchom `claude plugin validate .`.
4. PR z linkiem do diffu i jedną osobą do review.

## Struktura

```text
.claude-plugin/marketplace.json   katalog: 2 pluginy domyślne + 3 opcjonalne
plugins/guardrails/               nasz hook ochronny
templates/project/.claude/        szablon ustawień i subagenta Explore dla projektów
evals/typescript-lsp/             test A/B wtyczki LSP na utility-sites
experiments/codemap/              odrzucony eksperyment z testem A/B
docs/research/                    raport i notatki źródłowe
```
