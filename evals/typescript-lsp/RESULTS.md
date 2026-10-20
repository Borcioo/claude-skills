# typescript-lsp: wynik testu A/B

**Werdykt: na `utility-sites` brak zysku.** Wtyczka zostaje w marketplace jako opcjonalna (dla dużych baz TS), ale nie wchodzi do domyślnego zestawu.

## Jak testowano

- **Repo:** `Borcioo/utility-sites` (`develop`, 805 plików) z zależnościami zainstalowanymi przez `pnpm install --frozen-lockfile`.
- **LSP:** `typescript-language-server` 5.3.0 i TypeScript 6.0.3.
- **Warianty:** z wtyczką i bez niej, po 3 uruchomienia na wariant, model Sonnet.
- **Data:** 2026-10-20; całkowity koszt testu $1,55.

Oba przypadki mają pułapkę, w której LSP powinien mieć przewagę nad grepem. W repo są dwie różne funkcje `requestDevice`:
- Wasz helper w `packages/tools/src/_shared/request-device.ts`;
- metoda WebHID w `gamepad-test/hid/device.ts`.

Zwykłe szukaj-i-zamień myli te dwa symbole.

| Przypadek | Wariant | Skuteczność | Tury | Koszt | Wywołania narzędzia LSP |
|---|---|---|---|---|---|
| rename-shared-helper (zmiana nazwy + `typecheck`) | z wtyczką | 100% | 30,7 | $0,193 | 0/3 |
| | bez | 100% | 28,0 | $0,169 | – |
| helper-call-sites (lista wywołań) | z wtyczką | 100% | 5,0 | $0,080 | 0/3 |
| | bez | 100% | 4,0 | $0,074 | – |

## Co się stało

- Narzędzie `LSP` było dostępne w każdym uruchomieniu z wtyczką (lista narzędzi w trace), ale agent ani razu go nie wywołał.
- Zamiast tego znajdował właściwe pliki Grepem, zmieniał je celowanym `sed` tylko w plikach helpera, a na koniec uruchamiał `tsc`.
- Pułapkę WebHID ominęły oba warianty we wszystkich uruchomieniach.
- Diagnostyka LSP po edycjach nie pojawiła się, bo nie było błędów typów.
- Wariant z wtyczką kosztował średnio o 6–14% więcej. Przy 3 uruchomieniach to mieści się w szumie.

## Ograniczenia

- Małe repo i tylko dwa zadania. Test CircleCI pokazał zysk na repo ok. 149 tys. linii przy starszym modelu (Sonnet 4.6).
- Na dużych bazach kodu, przy refaktorach przez wiele pakietów albo przy modelu, który częściej się myli, wynik może być inny.
- Fixture zakłada lokalną kopię `utility-sites` i katalog z zainstalowanymi zależnościami (ścieżki w `fixture.sh`).
