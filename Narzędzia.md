# Kompleksowe Narzędzia RE — Przewodnik Szczegółowy

Pogłębione omówienie **czterech kluczowych darmowych narzędzi**, które tworzą kompletny zestaw do inżynierii wstecznej. Dwa do analizy **statycznej** (czytanie kodu) i dwa do analizy **dynamicznej** (uruchamianie i obserwacja), podzielone na Windows i Linux.

| | Statyczne (czytaj kod) | Dynamiczne (uruchom i badaj) |
|---|---|---|
| **Windows** | Ghidra | x64dbg |
| **Linux** | Ghidra / Cutter | GDB + pwndbg |

> **Model myślowy:** Narzędzia statyczne pokazują *całą mapę* programu w spoczynku. Narzędzia dynamiczne pozwalają *przejechać* przez program i zobaczyć prawdziwe wartości. Ciągle przełączasz się między nimi.

---

# Ghidra (Statyczna + Dekompilator)

Flagowe darmowe narzędzie — działa tak samo na Windows i Linux. Disasembluje plik binarny i tworzy czytelny **pseudo-C**.

## Kluczowe Pojęcia
- **Project** — kontener na jeden lub więcej plików binarnych. Tworzony raz, używany wielokrotnie.
- **CodeBrowser** — główne okno analizy (listing + dekompilator + drzewo symboli).
- **Widok Listing** — disasemblacja (instrukcje asemblera, adresy, komentarze).
- **Widok Decompiler** — automatycznie generowany kod w stylu C (najważniejsza funkcja).
- **Auto-analiza** — pierwszy przebieg Ghidry, który wykrywa funkcje, stringi i referencje.

## Workflow przy Pierwszym Uruchomieniu
1. **File → New Project** → Non-Shared Project → nadaj nazwę.
2. **File → Import File** → wybierz plik binarny → OK.
3. Kliknij dwukrotnie zaimportowany plik, aby otworzyć **CodeBrowser**.
4. Na pytanie "analyze now?" kliknij **Yes** i zaakceptuj domyślne analizatory.
5. Poczekaj na zakończenie analizy (pasek postępu w prawym dolnym rogu).

## Najważniejsze Okna / Panele
| Panel | Co pokazuje |
|---|---|
| **Symbol Tree** (lewo) | Funkcje, etykiety, importy, eksporty |
| **Listing** (środek) | Disasemblacja z adresami |
| **Decompiler** (prawo) | Pseudo-C wybranej funkcji |
| **Defined Strings** | Wszystkie stringi (Window → Defined Strings) |
| **Function Graph** | Wizualny graf przepływu sterowania funkcji |

## Niezbędne Skróty
| Klawisz | Akcja |
|---|---|
| `G` | Przejdź do adresu lub symbolu |
| `L` | Zmień nazwę zmiennej/funkcji/etykiety |
| `;` | Dodaj komentarz |
| `Ctrl+Shift+E` | Edytuj sygnaturę funkcji |
| Dwuklik | Podążaj za referencją / skocz do funkcji |
| `Ctrl+Shift+G` (lub prawy klik → References) | Znajdź referencje do bieżącego elementu |
| Spacja | Przełącz widok listing ↔ graf |

## Praktyczny Przykład — Znajdź Sprawdzanie Licencji
1. **Window → Defined Strings**, znajdź `"Invalid license key"`.
2. Kliknij dwukrotnie → przeskakujesz do niego w Listingu.
3. Prawy klik na adres stringa → **References → Show References to Address**.
4. Kliknij dwukrotnie referencję → trafiasz do funkcji, która go wypisuje.
5. Przeczytaj panel **Decompiler**:
   ```c
   if (check_key(input) == 0)
       puts("Invalid license key");
   else
       puts("Access granted");
   ```
6. Kliknij dwukrotnie `check_key`, aby przeczytać logikę walidacji. Naciśnij `L`, aby zmieniać nazwy zmiennych w miarę ich rozumienia (np. `iVar1` → `keyLength`).

## Pro Tipy
- **Zmieniaj nazwy agresywnie** (`L`). Zamiana `FUN_00401abc` na `validate_password` czyni cały plik czytelnym.
- **Zmieniaj typy zmiennych** — jeśli Ghidra pokazuje `undefined4`, a to wskaźnik, prawy klik → Retype dla czystszego wyniku.
- **Zakładki** (`Ctrl+D`) oznaczają ciekawe miejsca, do których chcesz wrócić.
- Dekompilator nie jest idealny — gdy wygląda źle, przejdź do **Listingu**, by przeczytać prawdziwy asembler.

---

# x64dbg (Dynamiczna — Windows)

Nowoczesny, darmowy debugger trybu użytkownika dla Windows (obsługuje 32-bit przez `x32dbg` i 64-bit przez `x64dbg`). Uruchom program, zatrzymaj go, badaj/modyfikuj rejestry i pamięć oraz patchuj na żywo.

## Cztery Główne Panele
| Panel | Przeznaczenie |
|---|---|
| **CPU / Disassembly** (góra-lewo) | Instrukcje, z podświetlonym bieżącym EIP/RIP |
| **Registers** (prawo) | Wartości rejestrów na żywo + flagi (ZF, CF, itd.) |
| **Dump** (dół-lewo) | Surowy podgląd pamięci |
| **Stack** (dół-prawo) | Bieżący stos wywołań / pamięć stosu |

## Niezbędne Skróty
| Klawisz | Akcja |
|---|---|
| `F2` | Przełącz breakpoint w wybranej linii |
| `F7` | Wejdź do środka (wejdź w `call`) |
| `F8` | Przejdź ponad (wykonaj `call` bez wchodzenia) |
| `F9` | Uruchom / kontynuuj |
| `Ctrl+F9` | Uruchom do powrotu (wykonaj do `ret`) |
| `F4` | Uruchom do wybranej linii |
| `Spacja` | Asembluj / edytuj instrukcję pod kursorem |

## Przydatne Akcje Prawego Kliku
- **Search for → All referenced strings** — skocz do kodu po tekście, który wypisuje (najszybszy sposób na znalezienie ciekawej części).
- **Search for → All intermodular calls** — lista wszystkich wywołań API Windows (np. znajdź każde `MessageBoxW`).
- **Follow in Dump / Disassembler** — przeskakuj między pamięcią a kodem.
- **Breakpoint → Hardware/Memory** — zatrzymaj, gdy pamięć jest odczytywana/zapisywana.

## Praktyczny Przykład — Omiń Sprawdzanie w Czasie Działania
1. Otwórz `target.exe` w x64dbg → zatrzymuje się na systemowym breakpoincie; naciśnij `F9`, aby dojść do punktu wejścia.
2. Prawy klik na disasemblacji → **Search for → All referenced strings**.
3. Kliknij dwukrotnie `"Invalid license key"` → trafiasz w pobliże sprawdzania.
4. Tuż nad stringiem zobaczysz coś takiego:
   ```asm
   test eax, eax
   je   0x40123A      ; skacze do gałęzi "błąd", gdy eax == 0
   ```
5. Ustaw breakpoint (`F2`) na `je`. Naciśnij `F9`, wpisz dowolny klucz.
6. Gdy się zatrzyma, spójrz na **ZF** w panelu Registers. Dwa sposoby na obejście:
   - **Flipnij flagę:** kliknij dwukrotnie `ZF`, aby ją przełączyć → wymusza drugą gałąź.
   - **Zpatchuj instrukcję:** zaznacz `je`, naciśnij `Spacja`, zmień na `jne` lub `nop`.
7. Kontynuuj (`F9`) — program teraz akceptuje dowolny klucz.
8. Aby zapisać: **prawy klik → Patches → Patch file**, by zapisać zmodyfikowany `.exe`.

## Częste Zadania dla Początkujących
- **Ustaw breakpoint na API:** w polu poleceń wpisz `bp MessageBoxW`, potem `F9` — zatrzymanie tuż przed pojawieniem się okna komunikatu.
- **Pokonaj proste anti-debug:** zainstaluj wtyczkę **ScyllaHide**, by ukryć debugger przed `IsDebuggerPresent` i podobnymi.

---

# Cutter (Statyczna — Linux/Wieloplatformowa)

Darmowe, open-source GUI zbudowane na frameworku **rizin**, z opcjonalnym wbudowanym **dekompilatorem opartym na Ghidrze**. Lżejszy i szybszy w otwieraniu niż Ghidra; świetny do szybkich analiz statycznych. (Ghidra też jest w pełni dostępna na Linux i działa dokładnie tak, jak opisano wyżej — wybierz, co wolisz.)

## Kluczowe Panele
| Panel | Przeznaczenie |
|---|---|
| **Functions** (lewo) | Lista wykrytych funkcji |
| **Disassembly** (środek) | Listing asemblera |
| **Decompiler** | Pseudo-C (włącz wtyczkę dekompilatora Ghidry) |
| **Graph view** | Graf przepływu sterowania (naciśnij `Spacja`) |
| **Console** | Uruchamiaj surowe komendy rizin |

## Praktyczny Przykład
1. Otwórz `target` w Cutter → zaakceptuj domyślny poziom analizy.
2. W panelu **Functions** szukaj sensownych nazw (`main`, `check_password`) — obecne, jeśli plik nie jest stripped.
3. Kliknij dwukrotnie `check_password` → przełącz środkowy widok na **Decompiler**, by przeczytać pseudo-C.
4. Naciśnij `Spacja` dla **widoku grafu** — wizualnie prześledź gałąź "sukcesu" vs "błędu".
5. Zmieniaj nazwy symboli w miarę ich poznawania (klawisz `N`), by zachować czytelność.

> **Bonus:** Cutter udostępnia konsolę rizin, więc możesz uruchamiać potężne jednolinijkowce (np. `afl` by wylistować funkcje, `axt @ sym.main` by znaleźć referencje krzyżowe) bez opuszczania GUI.

---

# GDB + pwndbg (Dynamiczna — Linux)

**GDB** to standardowy debugger Linuksa (wiersz poleceń). **pwndbg** to wtyczka dodająca kolorowy, kontekstowy wynik — disasemblacja, rejestry, stos i backtrace pokazywane automatycznie przy każdym zatrzymaniu. Razem są linuksowym odpowiednikiem x64dbg.

## Konfiguracja
Zainstaluj pwndbg raz (sklonuj repozytorium i uruchom jego `setup.sh`); ładuje się automatycznie przez `~/.gdbinit`. Potem wystarczy uruchomić `gdb ./target`.

## Niezbędne Komendy
| Komenda | Akcja |
|---|---|
| `break main` / `b main` | Breakpoint na funkcji `main` |
| `break *0x