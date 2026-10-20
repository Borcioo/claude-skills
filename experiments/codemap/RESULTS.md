# codemap: wynik testu A/B (odrzucony)

**Werdykt: nie wchodzi do marketplace.** Na prawdziwym repo nie dał zysku ani w skuteczności, ani w liczbie tur, ani w koszcie.

## Jak testowano

- **Repo:** `Borcioo/utility-sites` (gałąź `develop`, 805 plików, monorepo TS/Astro).
- **Warianty:** z pluginem i bez niego, po 3 uruchomienia na wariant, model Sonnet, `claude plugin eval` z ablacją with/without.
- **Data:** 2026-10-20; całkowity koszt testu $1,77.
- **Przypadki** dobrane tak, żeby faworyzowały `codemap` (pełne listy plików danego typu, przegląd eksportów). Jeden przypadek jest kontrolny: zadanie dla Grepa.

## Wyniki (średnie z 3 uruchomień)

| Przypadek | Wariant | Skuteczność | Tury | Koszt | Czy agent użył codemap |
|---|---|---|---|---|---|
| stylesheets-and-theme | z pluginem | 100% | 7,0 | $0,067 | 3/3 |
| | bez | 100% | 4,3 | $0,061 | – |
| pl-catalogs (18 plików) | z pluginem | 100% | 4,7 | $0,075 | 0/3 |
| | bez | 100% | 4,7 | $0,076 | – |
| tool-components (16 narzędzi) | z pluginem | 100% | 3,7 | $0,056 | 0/3 |
| | bez | 100% | 3,3 | $0,054 | – |
| lane-logic | z pluginem | 100% | 3,7 | $0,056 | 0/3 |
| | bez | 100% | 3,0 | $0,052 | – |
| cn-helper (kontrola) | z pluginem | 100% | 3,0 | $0,047 | 0/3 |
| | bez | 100% | 3,0 | $0,047 | – |

## Wnioski

- Model bez pluginu rozwiązywał wszystkie zadania lokalizacyjne w 3–5 turach samym Glob/Grep.
- Dodatkowy skill nie miał czego poprawić. W jedynym przypadku, w którym agent go użył, dołożył tury.
- Potwierdza to tezę z raportu: sama lista plików dubluje wbudowany Glob.
- Mapa symboli może mieć sens dopiero w dużo większym lub nietypowo ułożonym repo. To nadal hipoteza, nie wynik.

Kod i przypadki zostają tutaj, żeby test dało się powtórzyć na innym repo. Skrypt w `fixture.sh` zakłada lokalną kopię repo w `/home/user/utility-sites`.

```bash
cd experiments/codemap
claude plugin eval . --runs 3 --scaffold --trust-plugin --allow-tools Bash Write --model sonnet --no-publish --max-cost-usd 10
```
