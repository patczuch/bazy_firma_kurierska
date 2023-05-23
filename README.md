<h1>Aplikacja dla firmy kurierskiej</h1>

## Skład grupy
Patryk Czuchnowski (patczuch@student.agh.edu.pl) <br />
Andrzej Wacławik (wajarema@student.agh.edu.pl) <br />
Michał Pędrak (michalpedrak@student.agh.edu.pl) <br />

## Technologie
Baza danych - PostgreSQL <br />
Backend - Python, Flask  <br />
Frontend - React

## Charakterystyka
W ramach projektu chcielibyśmy stworzyć stronę internetową dla firmy kurierskiej oferującej usługi dostarczania paczek pomiędzy punktami paczkowymi. Klient przynosi paczkę do takiego punktu, następnie pracownik dodaje informacje o niej do bazy i podaje klientowi numer paczki. Pod koniec dnia pracownik tworzy trasy dla kurierów, którzy wypełniają trasę, a następnie potwierdzają jej ukończenie w aplikacji. Gdy paczka znajdzie się w punkcie docelowym, odbiorca może przyjść ją odebrać co również zapisuje pracownik w aplikacji. Trasę paczki można kontrolować przez cały czas trwania dostawy mając jej numer.

## Problemy do uwzględnienia
Aby stworzyć trasę do przewozu paczek musi być spełnione wiele warunków takich jak nie przekroczenie maksymalnej ładowności pojazdu, fizyczna obecność paczek w punkcie startowym czy możliwość uczestniczenia danego kuriera w tym czasie. Widok całej drogi paczki musi uwględniać wszystkie punkty paczkowe oraz trasy w których ta paczka była obecna.

## Funkcje dostępne dla użytkowników
### Każdy użytkownik

1. Śledzenie przesyłek <br />
<img src="img/tracking.png" width="500px">
2. Logowanie <br />
<img src="img/login.png" width="150px">
3. Rejestracja <br />
<img src="img/register.png" width="150px">

### Pracownik punktu
1. Zarejestrowanie nowej przesyłki <br />
<img src="img/new_package.png" width="250px">
2. Wyświetlenie przesyłek w punkcie <br />
3. Potwierdzenie odebrania przesyłki <br />
<img src="img/packages_at_point.png" width="800px">
4. Utworzenie trasy dla kuriera <br />
<img src="img/new_route.png" width="400px">

### Kurier
1. Wyświetlenie tras <br />
2. Potwierdzenie odbycia trasy <br />
<img src="img/routes.png" width="800px">

### Admin
1. Dodanie kuriera
2. Dodanie punktu paczkowego
3. Dodanie pojazdu
4. Nadanie kontom uprawnień
## Schemat bazy danych

<img src="img/schemat.png" alt="Schemat">

## Bardziej szczegółowy opis kluczowych tabel
1. <img src="img/tabela1.png">


## Funkcje SQL
[Dodanie kuriera](./sql/functions/AddCourier.sql)<br />
[Dodanie rozmiaru paczki](./sql/functions/AddPackageDimension.sql)<br />
[Dodanie punktu paczkowego](./sql/functions/AddParcelPoint.sql)<br />
[Dodanie wehikułu](./sql/functions/AddVehicle.sql)<br />
[Zarejestrowanie nowej paczki](./sql/functions/RegisterPackage.sql)<br />
<img src="img/RegisterPackage.png">
[Potwierdzenie odebrania paczki](./sql/functions/PickUpPackage.sql)<br />
[Lista paczek w punkcie](./sql/functions/GetContentsOfParcelPoint.sql)<br />
DO POPRAWIENIA I OPISANIA<br />
[Lokalizacja paczki](./sql/functions/PackageLocation.sql)<br />
[Historia podróży paczki](./sql/functions/PackageTrackingHistory.sql)<br />
<img src="img/PackageTrackingHistory.png">
[Dodanie trasy przewozowej](./sql/functions/AddRoute.sql)<br />
[Potwierdzenie odbycia trasy](./sql/functions/CompleteRoute.sql)<br />
<img src="img/CompleteRoute.png">

## Backend
Backend naszego projektu został wykonany w Pythonie przy pomocy frameworka Flask. Do porozumienia z bazą PostgreSQL korzystaliśmy również z biblioteki psycopg2. Kod źródłowy wszystkich endpointów znajduje się w pliku [app.py](./back_end/app.py).
### Dostępne endpointy
1. Logowanie <br />
Adres: {{baseUrl}}/login, metoda: POST
2. Rejestracja <br />
Adres: {{baseUrl}}/register, metoda: POST
3. Śledzenie przesyłki <br />
Adres: {{baseUrl}}/tracking, metoda: POST <br />
DO OPISANIA
4. Wymiary przesyłek <br />
Adres: {{baseUrl}}/package_dimensions, metoda: GET
5. Punkty paczkowe <br />
Adres: {{baseUrl}}/parcelpoints, metoda: GET
6. Pojazdy <br />
Adres: {{baseUrl}}/vehicles, metoda: GET
7. Kurierzy <br />
Adres: {{baseUrl}}/couriers, metoda: GET
8. Nowa paczka <br />
Adres: {{baseUrl}}/new_package, metoda: POST <br />
DO OPISANIA
9. Nowa trasa <br />
Adres: {{baseUrl}}/create_route, metoda: POST <br />
DO OPISANIA
10. Potwierdzenie odebrania paczki <br />
Adres: {{baseUrl}}/pickup_package, metoda: POST
11. Przesyłki w punkcie <br />
Adres: {{baseUrl}}/parcelpoint_packages, metoda: POST <br />
DO OPISANIA
12. Trasy <br />
Adres: {{baseUrl}}/routes, metoda: POST
13. Potwierdzenie ukończenia trasy <br />
Adres: {{baseUrl}}/finish_route, metoda: POST <br />
DO OPISANIA
14. Nowy kurier <br />
Adres: {{baseUrl}}/new_courier, metoda: POST
15. Nowy punkt paczkowy <br />
Adres: {{baseUrl}}/new_parcelpoint, metoda: POST
16. Nowy samochód <br />
Adres: {{baseUrl}}/new_vehicle, metoda: POST
17. Nadanie uprawnień kontom <br />
DO ZROBIENIA

## Do poprawy lub uzupełnienia (27 kwietnia 2023)
- ~~przedstawić opis problemu na początku README~~<br />
- ~~zastanowić się nad podejściem do przechowywania danych w PersonInfo~~<br />
- ~~dodać spis (listę) funkcji (np. z linkami do kodu)~~<br />
- ~~dodawać komentarze do kodu sql~~<br />
- opisać kluczowe tabele i funkcje (ale jak coś jest oczywiste to nie mieszać)<br />
- ~~dokumentacja w jednym pliku (w miarę liniowa - bez linków itp.)~~<br />
- zarysować architekturę backendu (Python + Flask) w dokumentacji<br />
- testy do backendu w Postman'ie<br />
- wnioski czy to dobrze ze zrobilismy tak ze procedury sa w postgresie i tylko je wywolujemy przez backend
