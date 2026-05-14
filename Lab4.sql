-- 1. Перестворюємо таблиці (чистий запуск)
DROP TABLE IF EXISTS Presentations;
DROP TABLE IF EXISTS Sections;
DROP TABLE IF EXISTS Speakers;
DROP TABLE IF EXISTS ConferencesInfo;
GO
CREATE TABLE ConferencesInfo (
    ConferenceID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Building NVARCHAR(100) NOT NULL,
    Rating DECIMAL(10, 2) DEFAULT 0,
    UCR NVARCHAR(100), DCR DATETIME, ULC NVARCHAR(100), DLC DATETIME
);

CREATE TABLE Sections (
    SectionID INT IDENTITY(1,1) PRIMARY KEY,
    ConferenceID INT NOT NULL,
    SectionName NVARCHAR(100) NOT NULL,
    OrderNumber INT NOT NULL,
    Chairperson NVARCHAR(100) NOT NULL,
    RoomNumber NVARCHAR(20) NOT NULL,
    UCR NVARCHAR(100), DCR DATETIME, ULC NVARCHAR(100), DLC DATETIME,
    FOREIGN KEY (ConferenceID) REFERENCES ConferencesInfo(ConferenceID)
);

CREATE TABLE Speakers (
    SpeakerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    AcademicDegree NVARCHAR(50),
    Workplace NVARCHAR(150) NOT NULL,
    Position NVARCHAR(100) NOT NULL,
    Biography NVARCHAR(MAX),
    UCR NVARCHAR(100), DCR DATETIME, ULC NVARCHAR(100), DLC DATETIME
);

CREATE TABLE Presentations (
    PresentationID INT IDENTITY(1,1) PRIMARY KEY,
    SectionID INT NOT NULL,
    SpeakerID INT NOT NULL,
    Topic NVARCHAR(255) NOT NULL,
    StartTime DATETIME NOT NULL,
    DurationMinutes INT DEFAULT 20,
    UCR NVARCHAR(100), DCR DATETIME, ULC NVARCHAR(100), DLC DATETIME,
    FOREIGN KEY (SectionID) REFERENCES Sections(SectionID),
    FOREIGN KEY (SpeakerID) REFERENCES Speakers(SpeakerID)
);
GO
-- Очищуємо таблиці перед вставкою, щоб не було дублікатів при повторному запуску
-- (Порядок видалення важливий через FOREIGN KEY)
DELETE FROM Presentations;
DELETE FROM Sections;
DELETE FROM Speakers;
DELETE FROM ConferencesInfo;
GO

-- 1. Додаємо конференції
-- Поля UCR, DCR, ULC, DLC заповняться автоматично (якщо є відповідні тригери)
INSERT INTO ConferencesInfo (Title, StartDate, EndDate, Building)
VALUES
('Всесвітній економічний форум', '2026-05-15', '2026-05-17', 'Конгрес-центр'),
('Інновації в медицині 2026', '2026-09-10', '2026-09-12', 'Медичний університет');
GO

-- 2. Додаємо секції
-- Тут спрацює твій тригер INSTEAD OF INSERT trg_Sections_Sequence
INSERT INTO Sections (ConferenceID, SectionName, OrderNumber, Chairperson, RoomNumber)
VALUES 
(1, 'Цифрова економіка', 1, 'Марченко В.О.', 'Ауд. 101'),
(1, 'Макроекономічні прогнози', 2, 'Павлюк Г.С.', 'Ауд. 105'),
(2, 'Генетичні дослідження', 1, 'д-р Ващук Л.М.', 'Зал 2'),
(2, 'Цифрова діагностика', 2, 'проф. Кравченко О.І.', 'Зал 4');
GO

-- 3. Додаємо доповідачів
-- Тут спрацює тригер trg_Speakers_Audit
INSERT INTO Speakers (FullName, AcademicDegree, Workplace, Position, Biography)
VALUES
('Андрій Бондар', 'PhD', 'НБУ', 'Аналітик', 'Спеціаліст з банківських систем'),
('Олена Коваль', 'Магістр', 'SoftServe', 'Project Manager', 'Досвід в управлінні фінтех-проєктами'),
('Віктор Савченко', 'д.м.н.', 'Клініка Оберіг', 'Головний лікар', 'Автор понад 50 наукових статей'),
('Ірина Соколова', 'PhD', 'БіоТех', 'Дослідник', 'Експерт з молекулярної біології');
GO

-- 4. Додаємо виступи
-- Тут спрацюють тригери перевірки розкладу та накладок у кімнатах
INSERT INTO Presentations (SectionID, SpeakerID, Topic, StartTime, DurationMinutes)
VALUES 
(1, 1, 'Вплив блокчейну на банківський сектор', '2026-05-15 10:00:00', 40),
(1, 2, 'Тренди фінтех-стартапів 2026', '2026-05-15 11:00:00', 30),
(2, 1, 'Прогнози інфляції на наступний рік', '2026-05-16 09:30:00', 45),
(3, 4, 'Редагування геному: етичні питання', '2026-09-10 14:00:00', 60),
(4, 3, 'ШІ у ранній діагностиці хвороб', '2026-09-11 11:00:00', 50);
GO

-- 2. ТРИГЕРИ

-- Аудит для Speakers
CREATE OR ALTER TRIGGER trg_Speakers_Audit
ON Speakers
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM deleted)
        UPDATE Speakers SET UCR = SUSER_SNAME(), DCR = GETDATE(), ULC = SUSER_SNAME(), DLC = GETDATE()
        FROM Speakers s JOIN inserted i ON s.SpeakerID = i.SpeakerID;
    ELSE
        UPDATE Speakers SET ULC = SUSER_SNAME(), DLC = GETDATE()
        FROM Speakers s JOIN inserted i ON s.SpeakerID = i.SpeakerID;
END;
GO

-- Сурогатний ключ та Аудит для Sections
CREATE OR ALTER TRIGGER trg_Sections_Sequence
ON Sections
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Sections (ConferenceID, SectionName, OrderNumber, Chairperson, RoomNumber, UCR, DCR, ULC, DLC)
    SELECT ConferenceID, SectionName, OrderNumber, Chairperson, RoomNumber, 
           SUSER_SNAME(), GETDATE(), SUSER_SNAME(), GETDATE()
    FROM inserted;
END;
GO

-- Перевірка спікера (один день - одна секція)
CREATE OR ALTER TRIGGER trg_Check_Speaker_Schedule
ON Presentations
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Presentations p
        JOIN inserted i ON p.SpeakerID = i.SpeakerID
        WHERE CAST(p.StartTime AS DATE) = CAST(i.StartTime AS DATE)
          AND p.SectionID <> i.SectionID
          AND p.PresentationID <> i.PresentationID
    )
    BEGIN
        RAISERROR ('Помилка: Виступаючий вже зареєстрований в іншій секції на цей день!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Перевірка накладки виступів у кімнаті
CREATE OR ALTER TRIGGER trg_Check_Room_Overlap
ON Presentations
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Presentations p
        JOIN Sections s_old ON p.SectionID = s_old.SectionID
        JOIN inserted i ON 1=1
        JOIN Sections s_new ON i.SectionID = s_new.SectionID
        WHERE s_old.RoomNumber = s_new.RoomNumber
          AND p.PresentationID <> i.PresentationID
          AND p.StartTime < DATEADD(minute, i.DurationMinutes, i.StartTime)
          AND i.StartTime < DATEADD(minute, p.DurationMinutes, p.StartTime)
    )
    BEGIN
        RAISERROR ('Помилка: У цьому приміщенні вже заплановано інший виступ на цей час!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
SELECT FullName, UCR, DCR, ULC, DLC FROM Speakers;
GO
UPDATE Speakers SET AcademicDegree = AcademicDegree;
UPDATE Sections SET OrderNumber = OrderNumber;
GO
INSERT INTO Presentations (SectionID, SpeakerID, Topic, StartTime, DurationMinutes)
    VALUES (1, 1, 'Повторний виступ', '2026-05-15 14:00:00', 30);