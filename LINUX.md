# Lokalny StreamLight na CachyOS (x86_64)

Fork bazuje na FoggyBytes/StreamLight, commit
`cbb767629120fd7ea83163d8da642f3773a5122d` (5.7.0).
Zmiany są lokalne, na gałęzi `codex/linux-build`.

## Budowanie na Windows

Wymagany Docker Desktop uruchomiony w trybie kontenerów Linux.
W PowerShell, w katalogu projektu:

```powershell
./scripts/build-linux.ps1
```

Opcjonalnie `-Jobs 8` zmienia liczbę równoległych kompilacji.
Zależności instalowane są w kontenerze Arch Linux. Wynik trafia do `dist/`:
`streamlight-5.7.0-4-x86_64.pkg.tar.zst`, `SHA256SUMS` i lista wersji zależności.
Obraz korzysta z bieżących repozytoriów Arch, więc kolejne buildy mogą używać
nowszych bibliotek. Kod kompilowany jest dla zwykłego x86_64, bez `-march=native`.
Skrypt po kompilacji instaluje paczkę w jednorazowym kontenerze i wykonuje
20-sekundowy test GUI na Xvfb. Log i zrzut ekranu trafiają do `dist/`.

## Przeniesienie i uruchomienie

Skopiuj paczkę i `SHA256SUMS` na CachyOS. W katalogu z plikami:

```bash
sha256sum -c SHA256SUMS
sudo pacman -Syu
sudo pacman -U ./streamlight-5.7.0-4-x86_64.pkg.tar.zst
streamlight
```

To natywna paczka, nie samowystarczalny AppImage: pacman pobierze brakujące
zależności z repozytoriów, więc instalacja może wymagać internetu.
Użyj aktualnego CachyOS, ponieważ program linkuje do bieżących bibliotek Arch.
W menu aplikacji pojawi się StreamLight. Pliki programu i wpis menu mają własne
nazwy, więc nie zastępują instalacji Moonlight.

Jeżeli wystąpi problem z uruchomieniem na Waylandzie, sprawdź XWayland:

```bash
QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 streamlight
```

Odinstalowanie: `sudo pacman -R streamlight`.

## Zakres pierwszego portu

### Domyślny host i dźwięki menu (paczka 5.7.0-4)

Na karcie hosta wybierz **Options → Set as default host**. Przy kolejnym starcie
StreamLight otworzy bibliotekę tego hosta, jeżeli jest online, sparowany i obsługiwany.
Czeka na wykrycie do około 8 sekund. Przy hoście offline pozostaje na jego karcie;
nie uruchamia gry ani Wake-on-LAN samoczynnie. Każde naciśnięcie klawisza/pada,
kliknięcie lub przewinięcie anuluje automatyczne wejście. Powrót z biblioteki lub
streamingu nie ponawia automatycznego wejścia. Host jest zapisany po UUID i aliasie,
nie po nazwie, IP ani pozycji na liście.

Usuń wybór przez **Options → Clear default host** lub **Settings → Session →
Default host at startup → Clear**. Drugie miejsce działa również po usunięciu hosta.

**Settings → Session → Menu sounds / Menu sound volume** steruje dźwiękami menu.
Domyślnie są włączone z głośnością 25%. Krótkie oryginalne tony obejmują nawigację,
zatwierdzenie i cofnięcie. Nie zawierają nagrań Steam. Działają przez SDL, bez nowej
zależności QtMultimedia. Wyłączenie dźwięków, utrata aktywności okna i rozpoczęcie
streamingu zamykają urządzenie audio menu. Brak urządzenia audio nie blokuje GUI.

Testy `tests/menu/menu.pro` sprawdzają trwałość ustawień, wybór hosta po zmianie
kolejności, przypadki offline/niesparowany/brak hosta, parametry sygnału audio,
zwalnianie audio oraz kliknięcia aktywnych i wyłączonych kontrolek. Testy GUI
w `tests/menu/` korzystają wyłącznie z fikcyjnego hosta w osobnym kontenerze.

### Obsługa platformy

Build zachowuje X11, Wayland, VA-API, VDPAU, DRM/EGL i Vulkan/libplacebo.
Sterowniki GPU zapewnia system docelowy. Rzeczywiste dekodowanie sprzętowe,
HDR, pad i streaming trzeba sprawdzić na docelowej maszynie z hostem Sunshine.

Dotychczasowe funkcje Windows nadal mają ograniczenia na Linuxie: automatyczne
uruchamianie Hue Sync i Tailscale, odczyt baterii oraz dopasowanie prędkości
łącza hosta nie są zaimplementowane dla Linuxa. Tailscale można uruchomić
osobno w systemie i dodać ręcznie adres Tailscale hosta.
Fractional V-Sync działa tylko na Windows w rendererze D3D11; zwykły V-Sync
i Frame Pacing pozostają dostępne na Linuxie.

Od wydania paczki `5.7.0-2` niedostępne ustawienia są zablokowane z wyjaśnieniem
w ustawieniach głównych, profilach hostów i opcjach poszczególnych gier.
Akcja dopasowania łącza w menu hosta również jest zablokowana; przywrócenie
prędkości hosta pozostaje dostępne. Integracja kafelków Xbox jest już chroniona
warunkami platformy w kodzie autora.
Przełącznik Discord Rich Presence uwzględnia dostępność integracji w buildzie;
nasza paczka jej nie zawiera.

Opcjonalny most StreamTweak pozostaje w aplikacji. StreamTweak działa na hoście
Windows; Linux jest tutaj klientem. Dlatego zdalne funkcje hosta, np. Windows
Update, nie są ukrywane ze względu na system klienta.

## Wynik lokalnej weryfikacji (11.09.2026)

- Zbudowano release 5.7.0 z Qt 6.11.2 i FFmpeg 9.0.1 na Arch Linux.
- Instalacja przez pacman oraz kontrola plików pakietu przeszły poprawnie.
- `ldd` nie wykazał brakujących bibliotek, `--version` zwróciło StreamLight 5.7.0.
- GUI wyświetliło ekran dodawania hosta i działało przez 20 sekund.
- Dla paczki 5.7.0-2 sprawdzono również otwarcie ustawień oraz zakładki Video,
  Network i Session. Fractional V-Sync pozostaje zablokowany przy włączonym
  zwykłym V-Sync i Frame Pacing. Zrzuty są w `dist/settings-*.png`.
- Kontener nie ma GPU: widoczny komunikat o braku dekodera sprzętowego jest
  oczekiwany w tym teście. Nie potwierdza to działania GPU ani streamingu na CachyOS.
- W logu pozostają ostrzeżenia QML dotyczące ToolTip i skrótów; nie blokują startu.

## Przegląd forka drainerlight (11.09.2026)

Porównano commit `1342d5d4c1dddfbcea27a885ea35ec2f6420a8f1` z naszą bazą.
Fork zawiera jeden commit funkcjonalny: pakowanie AppImage, CI, nazwy i metadane
Linux/Steam Link oraz usunięcie BOM z wersji. Nie zmienia dekoderów, renderowania
streamu, obsługi kontrolerów ani ograniczeń ustawień zależnych od platformy.

[Build CI](https://github.com/drainerlight/StreamLight/actions/runs/34584718800)
zakończył się sukcesem i udostępnia artefakt `StreamLight-LinuxAppImage-1342d5`
(82 668 206 bajtów). Workflow sprawdza kompilację i obecność artefaktu, ale nie
uruchamia GUI ani testu streamingu. Samego gotowego AppImage nie testowaliśmy.

Wnioski z [przejrzanego commitu](https://github.com/drainerlight/StreamLight/commit/1342d5d4c1dddfbcea27a885ea35ec2f6420a8f1):

- AppImage jest sensowną osobną ścieżką dla przenoszenia aplikacji bez instalacji
  paczką systemową. Workflow buduje na Ubuntu 22.04, z Qt 6.8.3, FFmpeg 8.1.1,
  SDL3 i sdl2-compat. Obsługuje potrzebne moduły QML i ręcznie dołącza SDL3,
  którego zależności `dlopen` nie wykrywa zwykłe `ldd`.
- Skrypt AppImage zachowuje odziedziczone `disable-wayland` i `disable-libdrm`.
  Nie jest zamiennikiem naszej konfiguracji z natywnym Waylandem i DRM.
- Nasza paczka już ma nazwę `streamlight`, własne metadane, ikonę i identyfikator
  pulpitu. Zachowujemy `io.github.FoggyBytes.StreamLight`; przejście na używany
  przez ten fork `com.foggybytes.StreamLight` nie daje korzyści temu buildowi.
- Nie przeniesiono CI, zmian Steam Link ani konfiguracji AppImage do ścieżki
  budowania paczki Arch. Nie są potrzebne do lokalnego buildu dla CachyOS.
- Selektywnie przeniesiono nazwę `StreamLight` w podpowiedziach SDL dla dźwięku
  i aplikacji oraz usunięcie UTF-8 BOM z `app/version.txt`. Te zmiany znajdują się
  w paczce `5.7.0-3`. Nie wykonano pełnego merge'a gałęzi.

Pozostajemy przy natywnej paczce dla aktualnego CachyOS. AppImage warto rozwijać
jako oddzielny wariant, jeśli priorytetem stanie się uruchamianie bez `pacman -U`.
