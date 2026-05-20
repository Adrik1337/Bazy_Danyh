-- 1. Створення логінів для сервера
CREATE LOGIN boss_login WITH PASSWORD = 'Password123!';
CREATE LOGIN mod_login WITH PASSWORD = 'Password456!';
CREATE LOGIN student_login WITH PASSWORD = 'Password789!';
GO

-- 2. Створення користувачів у самій базі "Конференції"
CREATE USER conf_boss FOR LOGIN boss_login;
CREATE USER moderator_ivan FOR LOGIN mod_login;
CREATE USER student_reader FOR LOGIN student_login;
GO

-- 3. Створення ролей
CREATE ROLE role_editor;
CREATE ROLE role_readonly;
GO

-- 4. Надання привілеїв ролям (по одній таблиці за раз)
GRANT SELECT ON Speakers TO role_readonly;
GRANT SELECT ON ConferencesInfo TO role_readonly;

GRANT SELECT, INSERT, UPDATE ON Speakers TO role_editor;
GRANT SELECT, INSERT, UPDATE ON ConferencesInfo TO role_editor;
GO

-- 5. Призначаємо ролі користувачам
ALTER ROLE role_editor ADD MEMBER moderator_ivan;
ALTER ROLE role_readonly ADD MEMBER student_reader;
-- Адміну можна дати вбудовану роль db_owner
ALTER ROLE db_owner ADD MEMBER conf_boss;
GO

-- 6. Персональний привілей для перевірки (пункт 6)
GRANT UPDATE ON Speakers TO moderator_ivan;
GO
-- 7. Відкликаємо персональне право на UPDATE, яке ми надавали в кінці твого скрипта
REVOKE UPDATE ON Speakers FROM moderator_ivan;
GO
-- 8. Забираємо роль у модератора Івана
ALTER ROLE role_editor DROP MEMBER moderator_ivan;
GO
-- 9. Видаляємо користувачів з бази даних
DROP USER moderator_ivan;
DROP USER student_reader;
DROP USER conf_boss;
GO

--  Видаляємо ролі
DROP ROLE role_editor;
DROP ROLE role_readonly;
GO

-- Видаляємо логіни з сервера (якщо створювала їх через CREATE LOGIN)
DROP LOGIN mod_login;
DROP LOGIN student_login;
DROP LOGIN boss_login;
GO
-- Перевірка прав для Модератора Івана (через імітацію контексту)
EXECUTE AS USER = 'moderator_ivan';
    SELECT 
        HAS_PERMS_BY_NAME('Speakers', 'OBJECT', 'SELECT') AS CanSelectSpeakers,
        HAS_PERMS_BY_NAME('Speakers', 'OBJECT', 'UPDATE') AS CanUpdateSpeakers,
        HAS_PERMS_BY_NAME('Speakers', 'OBJECT', 'DELETE') AS CanDeleteSpeakers; -- Має бути 0
REVERT;

-- Перевірка прав для Студента
EXECUTE AS USER = 'student_reader';
    SELECT 
        HAS_PERMS_BY_NAME('Speakers', 'OBJECT', 'SELECT') AS CanRead,
        HAS_PERMS_BY_NAME('Speakers', 'OBJECT', 'INSERT') AS CanInsert; -- Має бути 0
REVERT;
GO
