# claude-skills

Zespołowy marketplace pluginów Claude Code i research (październik 2026) o tym, które skille, pluginy, serwery MCP i narzędzia realnie pomagają w codziennej pracy developera.

- **Pełny raport:** [`docs/research/2026-10-raport.md`](docs/research/2026-10-raport.md). Ranking „wdrożyć teraz / per projekt / pominąć”, praktyki Anthropic i twórców Claude Code, pamięć i Obsidian, pętle, roje agentów, plan wdrożenia i checklista bezpieczeństwa.
- **Notatki źródłowe** (8 wątków, z linkami): [`docs/research/notes/`](docs/research/notes/).

## Najważniejsze wnioski

- **Większość skilli nie daje mierzalnego zysku.** W SWE-Skills-Bench 39 z 49 publicznych skilli dało 0% poprawy, a niektóre zwiększyły zużycie tokenów nawet o 451%. Opłacają się wąskie skille z wiedzą, której model nie ma: specyfika projektu, dostawcy, zespołu.
- **Rój agentów kosztuje wielokrotność jednej sesji.** Agent teams to około 7x tokenów, a w teście Vals AI różnica wynosiła 2,2–5,1x bez istotnej poprawy wyniku. Domyślny model to „jeden piszący, wielu czytających” z limitami budżetu i równoległości.
- **Największy zysk dają rzeczy natywne i tanie:**
  - weryfikacja pracy przez agenta (testy, hooki, `/goal`, LSP);
  - stabilny cache promptu;
  - wybór modelu na starcie sesji;
  - krótki CLAUDE.md.
- **superpowers zostaje jedynym frameworkiem procesu.** Drugi framework (GSD, BMAD, Compound Engineering, Spec Kit) konkuruje z nim o te same wyzwalacze.

## Szybki start

```text
/plugin marketplace add Borcioo/claude-skills
/plugin install superpowers@borcioo-skills
/plugin install code-review@borcioo-skills
/plugin install commit-commands@borcioo-skills
/plugin install claude-md-management@claude-plugins-official
```

Dla każdego języka, którego używasz, dodaj wtyczkę LSP **i** zainstaluj binarkę serwera, np. `npm i -g typescript-language-server typescript intelephense`:

```text
/plugin install typescript-lsp@borcioo-skills
/plugin install php-lsp@borcioo-skills
```

Dopisz też do CLAUDE.md linię w stylu „Do nawigacji i weryfikacji typów używaj wyników LSP”. Bez niej agent częściej wraca do grepa.

Jeśli macie własną, zmodyfikowaną wersję superpowers, podmieńcie w `.claude-plugin/marketplace.json` źródło wpisu `superpowers` na swój fork (przypięty po SHA). Nie instalujcie obu naraz.

## Co jest w marketplace

Każde zewnętrzne źródło jest przypięte do pełnego SHA commita. Aktualizacja u autora nie trafia więc do zespołu, dopóki ktoś nie podbije pinu w PR.

| Kategoria | Pluginy | Kiedy |
|---|---|---|
| `workflow` | `superpowers` (v7.0.0) | zawsze, jako jedyny kręgosłup procesu |
| `core` | `code-review`, `pr-review-toolkit`, `commit-commands`, `hookify`, `skill-creator` | zawsze; z review wybierz jedno narzędzie |
| `lsp` | `typescript-lsp`, `php-lsp`, `pyright-lsp`, `gopls-lsp`, `rust-analyzer-lsp` | dla używanych języków, z binarką serwera |
| `docs` | `context7` | aktualna dokumentacja bibliotek (zdalny serwer HTTP) |
| `security` | `security-guidance` (Anthropic) i z Trail of Bits: `differential-review`, `insecure-defaults`, `sharp-edges`, `static-analysis`, `supply-chain-risk-auditor`, `property-based-testing`, `mutation-testing`, `modern-python` | kod wrażliwy; tylko wybrane, w zakresie projektu |
| `per-project` | `frontend-design` | projekty UI |
| `vendor` | `laravel-boost`, `stripe`, `cloudflare`, `sentry`, `supabase`, `vercel` | tylko w repo, które używa danego dostawcy (`--scope project`); `laravel-boost` uruchamia `php artisan boost:mcp`, więc wymaga pakietu `laravel/boost` w projekcie |
| `loops` | `ralph-loop` | tylko greenfield, w sandboksie, zawsze z `--max-iterations` |
| `memory` | `episodic-memory` | osobiście; podnieś `cleanupPeriodDays` (domyślnie 30 dni) |
| `experimental` | `codemap` (własny) | patrz niżej; zostaje tylko po teście A/B |

Celowo **nie ma** tu:
- mega-kolekcji skilli;
- kompresorów tokenów (caveman, RTK);
- claude-mem, z niezałatanym audytem bezpieczeństwa;
- GitHub MCP, bo `gh` jest tańsze;
- ciężkich frameworków rojowych.

Uzasadnienia są w raporcie, w sekcji „Pominąć”.

## Szablon dla projektu

[`templates/project/.claude/`](templates/project/.claude/) to punkt startowy do skopiowania do repozytorium projektu:

- **`settings.json`:**
  - rejestruje ten marketplace i włącza podstawowe pluginy (działa po zaakceptowaniu zaufania do folderu);
  - włącza sandbox z blokadą odczytu `~/.ssh` i `~/.aws/credentials` oraz ukrytymi `GITHUB_TOKEN`/`NPM_TOKEN`;
  - podpina hook chroniący pliki.
- **`hooks/protect-files.sh`:**
  - blokuje edycję `.env`, lockfile'ów, `.git/` i workflowów CI (wymaga `jq`);
  - z `CLAUDE_PROTECT_TESTS=1` blokuje też edycję testów. Włączaj to tylko w nienadzorowanych pętlach, bo w interaktywnym TDD pisanie testów jest pierwszym krokiem.
- **`agents/Explore.md`:** nadpisuje wbudowanego subagenta Explore wersją tylko do odczytu na Haiku. Wbudowany Explore na subskrypcji chodzi na Opus.

Pluginy z zewnętrznych źródeł, włączone w ustawieniach projektu, każdy instaluje raz u siebie: `claude plugin install <nazwa>@borcioo-skills --scope project`.

## codemap (eksperyment)

Skill ze skryptem bash. Jednym wywołaniem zwraca świeżą listę plików wybranych typów, pogrupowaną po katalogach, a opcjonalnie także klasy, funkcje i eksporty z każdego pliku.

- Respektuje `.gitignore` i pomija `vendor/`, `node_modules/`, build oraz pliki zminifikowane.
- Używa `rg`, a gdy go nie ma, `git` albo `find`.
- Nie wymaga Node ani npx.

```bash
codemap --ext css,scss --symbols
codemap --ext php --dir app --symbols --max 150
```

Sama lista plików dubluje wbudowany Glob (`**/*.css`), więc wartość dodana leży w grupowaniu, wykluczeniach i symbolach. **Zostawcie go tylko, jeśli test A/B na 10–20 realnych zadaniach pokaże zysk.** Mierzcie liczbę wywołań do pierwszego trafnego odczytu pliku i tokeny na zadanie, z pluginem i bez (`claude plugin eval`, `/usage`). Bez wyraźnego zysku plugin usuwamy.

## Jak podbić pin

1. `git ls-remote https://github.com/<owner>/<repo> HEAD` (albo `--tags`; przy tagu adnotowanym bierz commit z `^{}`).
2. Przejrzyj diff między starym a nowym SHA, zwłaszcza hooki, skrypty, `.mcp.json` i zmiany w opisach skilli.
3. Podmień `sha` w `.claude-plugin/marketplace.json` i uruchom `claude plugin validate .`.
4. PR z linkiem do diffu i jedną osobą do review.

Pełna checklista weryfikacji nowych skilli, pluginów i serwerów MCP jest w raporcie, w sekcji „Bezpieczeństwo”.

## Struktura

```text
.claude-plugin/marketplace.json   katalog pluginów (przypięte źródła)
plugins/codemap/                  własny plugin (eksperyment)
templates/project/.claude/        szablon ustawień, hooka i subagenta dla projektów
docs/research/                    raport i notatki źródłowe
```
