select * from packagetrackinghistory(1);

INSERT INTO USERS (id, courier_id, parcelpoint_id, email, password_hash) VALUES
(4,	null,	null,	'kurier2@gmail.com',	'$2b$12$ofAYapQ8.So0TefzFUkFy.h79zR9t/wPmv8zAt839/j7B9/jL7kCC'),
(3,	1,	null,	'kurier1@gmail.com',	'$2b$12$zN3YCuotJhhvDuVrNZvW/uX1nCiMCmKRnTJqD7tp/ih3vxQiXuQX2'),
(7, null,	1,	'punktpaczkowy1@gmail.com',	'$2b$12$3mSwizx/ceLy/UzShzXoXuauI3Xb3330uL58gIxDH.myLgVepaX9u'),
(6,	1,	2,	'wszystko@gmail.com',	'$2b$12$5gMtzSwfKmYnqoTz0.jnnuLqhb9.KFJqaIDkgBcY.jXK0ROTdx9wq');

select * from packagelocation(4)