<h1>Aplikacja dla firmy kurierskiej</h1>

## Skład grupy
Patryk Czuchnowski (patczuch@student.agh.edu.pl) <br />
Andrzej Wacławik (wajarema@student.agh.edu.pl) <br />
Michał Pędrak (michalpedrak@student.agh.edu.pl) <br />

## Technologi
Baza danych - PostgreSQL <br />
Backend - Python, Flask  <br />
Frontend - React

## Charakterystyka
W ramach projektu chcielibyśmy stworzyć stronę internetową dla firmy kurierskiej oferującej usługi dostarczania paczek pomiędzy punktami paczkowymi. Klient przynosi paczkę do takiego punktu, następnie pracownik dodaje informacje o niej do bazy i podaje klientowi numer paczki. Pod koniec dnia pracownik tworzy trasy dla kurierów, którzy wypełniają trasę, a następnie potwierdzają jej ukończenie w aplikacji. Gdy paczka znajdzie się w punkcie docelowym, odbiorca może przyjść ją odebrać co również zapisuje pracownik w aplikacji. Trasę paczki można kontrolować przez cały czas trwania dostawy mając jej numer.

## Problemy do uwzględnienia
Aby stworzyć trasę do przewozu paczek musi być spełnione wiele warunków takich jak nie przekroczenie maksymalnej ładowności pojazdu, fizyczna obecność paczek w punkcie startowym czy możliwość uczestniczenia danego kuriera w tym czasie. Widok całej drogi paczki musi uwględniać wszystkie punkty paczkowe oraz trasy w których ta paczka była obecna.

## Schemat bazy danych

<img src="schemat.png" alt="Schemat">

## Spis funkcji SQL
[Dodawanie kuriera](./sql/functions/AddCourier.sql)<br />

## Do poprawy lub uzupełnienia (27 kwietnia 2023)
- ~~przedstawić opis problemu na początku README~~<br />
- zastanowić się nad podejściem do przechowywania danych w PersonInfo<br />
- dodać spis (listę) funkcji (np. z linkami do kodu)<br />
- ~~dodawać komentarze do kodu sql~~<br />
- opisać kluczowe tabele i funkcje (ale jak coś jest oczywiste to nie mieszać)<br />
- dokumentacja w jednym pliku (w miarę liniowa - bez linków itp.)<br />
- zarysować architekturę backendu (Python + Flask) w dokumentacji<br />
- testy do backendu w Postman'ie<br />
- wnioski czy to dobrze ze zrobilismy tak ze procedury sa w postgresie i tylko je wywolujemy przez backend
