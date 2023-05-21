select * from packagetrackinghistory(1);

INSERT INTO USERS (id, courier_id, parcelpoint_id, email, password_hash) VALUES
(4,	null,	null,	'kurier2@gmail.com',	'$2b$12$ofAYapQ8.So0TefzFUkFy.h79zR9t/wPmv8zAt839/j7B9/jL7kCC'),
(3,	1,	null,	'kurier1@gmail.com',	'$2b$12$zN3YCuotJhhvDuVrNZvW/uX1nCiMCmKRnTJqD7tp/ih3vxQiXuQX2'),
(7, null,	1,	'punktpaczkowy1@gmail.com',	'$2b$12$3mSwizx/ceLy/UzShzXoXuauI3Xb3330uL58gIxDH.myLgVepaX9u'),
(6,	1,	2,	'wszystko@gmail.com',	'$2b$12$5gMtzSwfKmYnqoTz0.jnnuLqhb9.KFJqaIDkgBcY.jXK0ROTdx9wq');

select * from packagelocation(4)

INSERT INTO Couriers (id, first_name, last_name, phone_number)
VALUES
(1, 'John', 'Smith', '123-456-7890'),
(2, 'Emily', 'Johnson', '987-654-3210'),
(3, 'Michael', 'Williams', '555-123-4567'),
(4, 'Emma', 'Brown', '444-555-6666'),
(5, 'Daniel', 'Jones', '777-888-9999'),
(6, 'Olivia', 'Davis', '111-222-3333'),
(7, 'Matthew', 'Miller', '999-888-7777'),
(8, 'Sophia', 'Wilson', '666-555-4444'),
(9, 'James', 'Taylor', '333-222-1111'),
(10, 'Ava', 'Anderson', '222-333-4444');

INSERT INTO ParcelPoints (id, name, city, street, house_number, apartment_number)
VALUES
(1, 'Punkt Krakowski', 'Kraków', 'Jasnogórska', '22', NULL),
(2, 'Punkt Warszawski', 'Warszawa', 'Złota', '44', '51'),
(3, 'Punkt Gdański', 'Gdańsk', 'Długa', '10', NULL),
(4, 'Punkt Poznański', 'Poznań', 'Wielka', '5', '3'),
(5, 'Punkt Wrocławski', 'Wrocław', 'Rynek', '15', NULL),
(6, 'Punkt Łódzki', 'Łódź', 'Piotrkowska', '30', NULL),
(7, 'Punkt Szczeciński', 'Szczecin', 'Wojska Polskiego', '8', '12'),
(8, 'Punkt Lubelski', 'Lublin', 'Krakowskie Przedmieście', '50', NULL),
(9, 'Punkt Białostocki', 'Białystok', 'Lipowa', '7', NULL),
(10, 'Punkt Katowicki', 'Katowice', 'Mariacka', '11', '2');

INSERT INTO Vehicles (id, registration_plate, max_weight)
VALUES
(1, 'ABC123', 1500.00000),
(2, 'DEF456', 2000.00000),
(3, 'GHI789', 1800.50000),
(4, 'JKL012', 2200.75000),
(5, 'MNO345', 1900.25000),
(6, 'PQR678', 1700.50000),
(7, 'STU901', 2100.75000),
(8, 'VWX234', 1600.25000),
(9, 'YZA567', 2300.50000),
(10, 'BCD890', 1400.75000);