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

-- Insert sample entries for Packages table
INSERT INTO Packages (id, weight, dimensions_id, sender_info_id, recipient_info_id, destination_packagepoint_id, pickedup_time)
VALUES
    (1, 3.5, 1, 1, 2, 2, NULL),
    (2, 2.1, 3, 3, 4, 1, NULL),
    (3, 4.8, 2, 5, 6, 4, NULL),
    (4, 1.9, 4, 7, 8, 3, NULL),
    (5, 6.2, 1, 9, 10, 2, NULL),
    (6, 3.9, 3, 11, 12, 3, NULL),
    (7, 2.3, 2, 13, 14, 4, NULL),
    (8, 5.7, 4, 15, 16, 1, NULL),
    (9, 1.5, 1, 17, 18, 2, NULL),
    (10, 4.2, 3, 19, 20, 3, NULL),
    (11, 2.8, 2, 21, 22, 1, NULL),
    (12, 3.2, 3, 23, 24, 1, NULL),
    (13, 5.1, 1, 25, 26, 4, NULL),
    (14, 1.7, 4, 27, 28, 3, NULL),
    (15, 4.9, 3, 29, 30, 4, NULL),
    (16, 2.5, 2, 31, 32, 2, NULL),
    (17, 6.3, 1, 33, 34, 4, NULL),
    (18, 1.3, 4, 35, 36, 1, NULL),
    (19, 3.7, 3, 37, 38, 2, NULL),
    (20, 4.4, 2, 39, 40, 3, NULL);

-- Insert sample entries for PersonInfo table (sender and recipient info)
INSERT INTO PersonInfo (id, name, phone_number, email)
VALUES
    (1, 'John Smith', '1234567890', 'john@example.com'),
    (2, 'Jane Doe', '0987654321', 'jane@example.com'),
    (3, 'Michael Johnson', '5551234567', 'michael@example.com'),
    (4, 'Emily Williams', '9876543210', 'emily@example.com'),
    (5, 'David Brown', '1112223333', 'david@example.com'),
    (6, 'Jessica Davis', '4445556666', 'jessica@example.com'),
    (7, 'Andrew Wilson', '7778889999', 'andrew@example.com'),
    (8, 'Olivia Taylor', '2223334444', 'olivia@example.com'),
    (9, 'Christopher Martin', '6667778888', 'christopher@example.com'),
    (10, 'Sophia Anderson', '9990001111', 'sophia@example.com'),
    (11, 'Jennifer Wilson', '1112223333', 'jennifer@example.com'),
    (12, 'Matthew Thompson', '4445556666', 'matthew@example.com'),
    (13, 'Emma Davis', '7778889999', 'emma@example.com'),
    (14, 'Daniel Martinez', '2223334444', 'daniel@example.com'),
    (15, 'Ava Anderson', '6667778888', 'ava@example.com'),
    (16, 'Alexander White', '9990001111', 'alexander@example.com'),
    (17, 'Sophie Clark', '1234567890', 'sophie@example.com'),
    (18, 'Josephine Turner', '0987654321', 'josephine@example.com'),
    (19, 'William Walker', '5551234567', 'william@example.com'),
    (20, 'Grace Mitchell', '9876543210', 'grace@example.com'),
    (21, 'Liam Turner', '1112223333', 'liam@example.com'),
    (22, 'Abigail Scott', '4445556666', 'abigail@example.com'),
    (23, 'Benjamin Lee', '7778889999', 'benjamin@example.com'),
    (24, 'Harper Thompson', '2223334444', 'harper@example.com'),
    (25, 'Elijah Davis', '6667778888', 'elijah@example.com'),
    (26, 'Mia White', '9990001111', 'mia@example.com'),
    (27, 'James Clark', '1234567890', 'james@example.com'),
    (28, 'Nora Turner', '0987654321', 'nora@example.com'),
    (29, 'Lucas Adams', '5551234567', 'lucas@example.com'),
    (30, 'Scarlett Mitchell', '9876543210', 'scarlett@example.com'),
    (31, 'Henry Baker', '1112223333', 'henry@example.com'),
    (32, 'Lily Evans', '4445556666', 'lily@example.com'),
    (33, 'Samuel Parker', '7778889999', 'samuel@example.com'),
    (34, 'Chloe Collins', '2223334444', 'chloe@example.com'),
    (35, 'Daniel Wood', '6667778888', 'daniel@example.com'),
    (36, 'Elizabeth Reed', '9990001111', 'elizabeth@example.com'),
    (37, 'Aiden Stewart', '1234567890', 'aiden@example.com'),
    (38, 'Victoria Turner', '0987654321', 'victoria@example.com'),
    (39, 'Jackson Morris', '5551234567', 'jackson@example.com'),
    (40, 'Penelope Wright', '9876543210', 'penelope@example.com');

INSERT INTO ParcelPointPackages (id, package_id, parcelpoint_id, time)
VALUES
    (1, 1, 1, TIMESTAMP '2023-01-05 10:30:00'),
    (2, 2, 2, TIMESTAMP '2023-01-10 14:45:00'),
    (3, 3, 3, TIMESTAMP '2023-01-15 09:20:00'),
    (4, 4, 4, TIMESTAMP '2023-01-20 16:55:00'),
    (5, 5, 1, TIMESTAMP '2023-01-25 11:40:00'),
    (6, 6, 2, TIMESTAMP '2023-01-30 13:15:00'),
    (7, 7, 3, TIMESTAMP '2023-02-04 08:50:00'),
    (8, 8, 4, TIMESTAMP '2023-02-09 17:25:00'),
    (9, 9, 1, TIMESTAMP '2023-02-14 12:10:00'),
    (10, 10, 2, TIMESTAMP '2023-02-19 15:35:00'),
    (11, 11, 3, TIMESTAMP '2023-02-24 10:00:00'),
    (12, 12, 4, TIMESTAMP '2023-03-01 18:25:00'),
    (13, 13, 1, TIMESTAMP '2023-03-06 13:10:00'),
    (14, 14, 2, TIMESTAMP '2023-03-11 16:35:00'),
    (15, 15, 3, TIMESTAMP '2023-03-16 11:00:00'),
    (16, 16, 4, TIMESTAMP '2023-03-21 19:25:00'),
    (17, 17, 1, TIMESTAMP '2023-03-26 14:10:00'),
    (18, 18, 2, TIMESTAMP '2023-03-31 17:35:00'),
    (19, 19, 3, TIMESTAMP '2023-04-05 12:00:00'),
    (20, 20, 4, TIMESTAMP '2023-04-10 20:25:00');

select updateuserprivileges(25,null,null,true)