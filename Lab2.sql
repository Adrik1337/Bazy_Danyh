USE CONFERENCES;
GO
-- 1. Таблиця Конференцій
CREATE TABLE ConferencesInfo (
    ConferenceID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Building NVARCHAR(100) NOT NULL,
    CONSTRAINT CHK_Dates CHECK (EndDate >= StartDate)
);

-- 2. Таблиця Секцій
CREATE TABLE Sections (
    SectionID INT IDENTITY(1,1) PRIMARY KEY,
    ConferenceID INT NOT NULL,
    SectionName NVARCHAR(100) NOT NULL,
    OrderNumber INT NOT NULL,
    Chairperson NVARCHAR(100) NOT NULL,
    RoomNumber NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_Section_Conference FOREIGN KEY (ConferenceID) REFERENCES ConferencesInfo(ConferenceID),
    CONSTRAINT UQ_Section_Room UNIQUE (ConferenceID, RoomNumber)
);

-- 3. Таблиця Доповідачів
CREATE TABLE Speakers (
    SpeakerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    AcademicDegree NVARCHAR(50),
    Workplace NVARCHAR(150) NOT NULL,
    Position NVARCHAR(100) NOT NULL,
    Biography NVARCHAR(MAX)
);

-- 4. Таблиця Виступів
CREATE TABLE Presentations (
    PresentationID INT IDENTITY(1,1) PRIMARY KEY,
    SectionID INT NOT NULL,
    SpeakerID INT NOT NULL,
    Topic NVARCHAR(255) NOT NULL,
    StartTime DATETIME NOT NULL,
    DurationMinutes INT NOT NULL DEFAULT 20,
    CONSTRAINT FK_Pres_Section FOREIGN KEY (SectionID) REFERENCES Sections(SectionID),
    CONSTRAINT FK_Pres_Speaker FOREIGN KEY (SpeakerID) REFERENCES Speakers(SpeakerID)
);
GO
USE CONFERENCES;
GO

-- 1. Додаємо конференцію
INSERT INTO ConferencesInfo (Title, StartDate, EndDate, Building)
VALUES
('Всесвітній економічний форум', '2026-05-15', '2026-05-17', 'Конгрес-центр'),
('Інновації в медицині 2026', '2026-09-10', '2026-09-12', 'Медичний університет');

-- 2. Додаємо секції (зв'язані з конференцією ID=1)
INSERT INTO Sections (ConferenceID, SectionName, OrderNumber, Chairperson, RoomNumber)
VALUES 
(1, 'Цифрова економіка', 1, 'Марченко В.О.', 'Ауд. 101'),
(1, 'Макроекономічні прогнози', 2, 'Павлюк Г.С.', 'Ауд. 105'),
(2, 'Генетичні дослідження', 1, 'д-р Ващук Л.М.', 'Зал 2'),
(2, 'Цифрова діагностика', 2, 'проф. Кравченко О.І.', 'Зал 4');

-- 3. Додаємо доповідачів
INSERT INTO Speakers (FullName, AcademicDegree, Workplace, Position, Biography)
VALUES
('Андрій Бондар', 'PhD', 'НБУ', 'Аналітик', 'Спеціаліст з банківських систем'),
('Олена Коваль', 'Магістр', 'SoftServe', 'Project Manager', 'Досвід в управлінні фінтех-проєктами'),
('Віктор Савченко', 'д.м.н.', 'Клініка Оберіг', 'Головний лікар', 'Автор понад 50 наукових статей'),
('Ірина Соколова', 'PhD', 'БіоТех', 'Дослідник', 'Експерт з молекулярної біології');

-- 4. Додаємо виступи (зв'язуємо з секцією та доповідачем)
INSERT INTO Presentations (SectionID, SpeakerID, Topic, StartTime, DurationMinutes)
VALUES 
(1, 1, 'Цифрова трансформація та її Вплив', '2026-05-15 12:00:00', 35),
(1, 1, 'Вплив блокчейну на банківський сектор', '2026-05-15 10:00:00', 40),
(1, 2, 'Тренди фінтех-стартапів 2026', '2026-05-15 11:00:00', 30),
(2, 1, 'Прогнози інфляції на наступний рік', '2026-05-16 09:30:00', 45),
(2, 2, 'Коротка доповідь для тесту', '2026-05-15 13:00:00', 15),
(3, 4, 'Редагування геному: етичні питання', '2026-09-10 14:00:00', 60),
(4, 3, 'ШІ у ранній діагностиці хвороб', '2026-09-11 11:00:00', 50);
GO
SELECT * FROM ConferencesInfo; 
SELECT * FROM Sections;        
SELECT * FROM Speakers;        
SELECT * FROM Presentations;
GO

-- =========================================================================
-- 1. SELECT на базі однієї таблиці (сортування, OR та AND)
-- Завдання: Отримати список доповідачів зі ступенем PhD або д.м.н., що працюють в НБУ або БіоТех
-- =========================================================================
SELECT FullName, AcademicDegree, Workplace 
FROM Speakers
WHERE (AcademicDegree = 'PhD' OR AcademicDegree = 'д.м.н.')
  AND (Workplace = 'НБУ' OR Workplace = 'БіоТех')
ORDER BY FullName ASC;


-- =========================================================================
-- 2. SELECT з виводом обчислюваних полів
-- Завдання: Розрахувати час закінчення виступу (початок + тривалість)
-- =========================================================================
SELECT Topic, StartTime, DurationMinutes,
       DATEADD(minute, DurationMinutes, StartTime) AS EndTime
FROM Presentations;


-- =========================================================================
-- 3. SELECT на базі кількох таблиць (Inner Join, OR/AND)
-- Завдання: Список тем доповідей разом із назвами секцій та конференцій
-- =========================================================================
SELECT C.Title AS ConfTitle, S.SectionName, P.Topic
FROM ConferencesInfo C
JOIN Sections S ON C.ConferenceID = S.ConferenceID
JOIN Presentations P ON S.SectionID = P.SectionID
WHERE C.Building = 'Конгрес-центр' OR C.Building = 'Медичний університет'
ORDER BY C.Title;


-- =========================================================================
-- 4. SELECT з типом поєднання Outer Join
-- Завдання: Вивести всіх доповідачів, навіть тих, у кого ще немає виступів
-- =========================================================================
SELECT S.FullName, P.Topic
FROM Speakers S
LEFT OUTER JOIN Presentations P ON S.SpeakerID = P.SpeakerID;

-- =========================================================================
-- 5. Використання операторів LIKE, BETWEEN, IN, EXISTS, ALL, ANY
-- Призначення: Комплексний пошук виступів за темою, тривалістю та перевіркою зв'язків
-- =========================================================================

SELECT Topic, DurationMinutes, SectionID
FROM Presentations P
WHERE 
    -- 1. LIKE: Тема містить слово 'Цифрова' або 'Вплив'
    (Topic LIKE '%Цифрова%' OR Topic LIKE '%Вплив%')
    
    -- 2. BETWEEN: Тривалість у межах від 10 до 60 хвилин
    AND DurationMinutes BETWEEN 10 AND 60 
    
    -- 3. IN: Виступи лише у секціях з ID 1-4
    AND SectionID IN (1, 2, 3, 4) 
    
    -- 4. EXISTS: Перевіряємо, чи існує такий доповідач у таблиці Speakers
    AND EXISTS (
        SELECT 1 FROM Speakers S 
        WHERE S.SpeakerID = P.SpeakerID
    )
    
    -- 5. ANY: Тривалість виступу більша за будь-який (хоча б один) виступ із секції №2
    AND DurationMinutes > ANY (
        SELECT DurationMinutes FROM Presentations WHERE SectionID = 2
    )
    
    -- 6. ALL: Тривалість менша за всі виступи, які тривають понад 100 хв (якщо такі є)
    AND DurationMinutes < ALL (
        SELECT DurationMinutes FROM Presentations WHERE DurationMinutes > 100
    );


-- =========================================================================
-- 6. SELECT з підсумовуванням та групуванням (GROUP BY)
-- Завдання: Кількість виступів у кожній секції
-- =========================================================================
SELECT SectionID, COUNT(*) AS CountOfPresentations
FROM Presentations
GROUP BY SectionID;


-- =========================================================================
-- 7. SELECT з підзапитом у частині WHERE
-- Завдання: Виступи, тривалість яких більша за середню
-- =========================================================================
SELECT Topic, DurationMinutes
FROM Presentations
WHERE DurationMinutes > (SELECT AVG(DurationMinutes) FROM Presentations);


-- =========================================================================
-- 8. SELECT з підзапитом у частині FROM
-- Завдання: Вибрати дані з підзапиту про секції конференції №1
-- =========================================================================
SELECT Sub.SectionName, Sub.Chairperson
FROM (SELECT * FROM Sections WHERE ConferenceID = 1) AS Sub;


-- =========================================================================
-- 9. Ієрархічний SELECT-запит (CTE)
-- Завдання: Показати ієрархію Конференція -> Секція
-- =========================================================================
WITH Hierarchy AS (
    SELECT Title AS Name, CAST(Title AS NVARCHAR(MAX)) AS Path, 1 AS Lvl
    FROM ConferencesInfo
    UNION ALL
    SELECT S.SectionName, CAST(C.Title + ' -> ' + S.SectionName AS NVARCHAR(MAX)), 2
    FROM Sections S
    JOIN ConferencesInfo C ON S.ConferenceID = C.ConferenceID
)
SELECT Name, Path, Lvl FROM Hierarchy;


-- =========================================================================
-- 10. SELECT-запит типу CrossTab (PIVOT)
-- Завдання: Таблиця кількості доповідачів за науковими ступенями
-- =========================================================================
SELECT 'Кількість' AS [Ступінь], [PhD], [д.м.н.], [Магістр]
FROM (SELECT AcademicDegree FROM Speakers) AS Source
PIVOT (COUNT(AcademicDegree) FOR AcademicDegree IN ([PhD], [д.м.н.], [Магістр])) AS pvt;


-- =========================================================================
-- 11. UPDATE (звичайна та через JOIN)
-- =========================================================================
-- Оновлення кімнати
UPDATE Sections SET RoomNumber = 'Ауд. 202' WHERE SectionID = 1;

-- Оновлення тривалості всіх виступів у конкретній будівлі (через JOIN)
UPDATE P
SET P.DurationMinutes = 45
FROM Presentations P
JOIN Sections S ON P.SectionID = S.SectionID
JOIN ConferencesInfo C ON S.ConferenceID = C.ConferenceID
WHERE C.Building = 'Конгрес-центр';

-- =========================================================================
-- 12. Append (INSERT) для додавання записів з явно вказаними значеннями
-- Призначення: Додати нового доповідача безпосередньо в таблицю Speakers
-- =========================================================================
INSERT INTO Speakers (FullName, AcademicDegree, Workplace, Position, Biography)
VALUES ('Олексій Петренко', 'Кандидат наук', 'Київський Політехнік', 'Доцент', 'Експерт з кібербезпеки');


-- =========================================================================
-- 13. Append (INSERT) для додавання записів з інших таблиць
-- Призначення: Копіювання певних даних з однієї таблиці в іншу
-- =========================================================================

-- Створимо додаткову таблицю "Архів Доповідачів" для демонстрації
CREATE TABLE SpeakersArchive (
    ArchiveID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100),
    Degree NVARCHAR(50)
);

-- Власне запит INSERT з використанням SELECT (додавання з іншої таблиці)
INSERT INTO SpeakersArchive (Name, Degree)
SELECT FullName, AcademicDegree
FROM Speakers
WHERE AcademicDegree = 'PhD';



-- =========================================================================
-- 14. DELETE
-- =========================================================================
-- Видалення виступу за ID (якщо потрібно було б видалити всі - DELETE FROM Presentations)
DELETE FROM Presentations WHERE PresentationID = 5;


-- =========================================================================
-- 15. СКЛАДНІ ЗАПИТИ (Поєднання кількох типів)
-- =========================================================================

-- Складний запит №1: Вивести доповідачів, які мають більше 1 виступу (JOIN + Group By + Having)
SELECT S.FullName, COUNT(P.PresentationID) AS TotalPres
FROM Speakers S
JOIN Presentations P ON S.SpeakerID = P.SpeakerID
GROUP BY S.FullName
HAVING COUNT(P.PresentationID) >= 1;

-- Складний запит №2: Секції з назвою конференції, де є виступи тривалістю понад 40 хв (Join + Subquery)
SELECT C.Title, S.SectionName
FROM ConferencesInfo C
JOIN Sections S ON C.ConferenceID = S.ConferenceID
WHERE S.SectionID IN (SELECT SectionID FROM Presentations WHERE DurationMinutes > 40);

/*DROP TABLE IF EXISTS Presentations;
DROP TABLE IF EXISTS Speakers;     
DROP TABLE IF EXISTS Sections;    
DROP TABLE IF EXISTS ConferencesInfo;*/