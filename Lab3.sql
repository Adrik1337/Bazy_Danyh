DROP TABLE IF EXISTS Presentations;
DROP TABLE IF EXISTS Sections;
DROP TABLE IF EXISTS Speakers;
DROP TABLE IF EXISTS ConferencesInfo;
GO
-- Створюємо таблиці
CREATE TABLE ConferencesInfo (
    ConferenceID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Building NVARCHAR(100) NOT NULL,
    Rating DECIMAL(10, 2) DEFAULT 0
);

CREATE TABLE Sections (
    SectionID INT IDENTITY(1,1) PRIMARY KEY,
    ConferenceID INT NOT NULL,
    SectionName NVARCHAR(100) NOT NULL,
    OrderNumber INT NOT NULL,
    Chairperson NVARCHAR(100) NOT NULL,
    RoomNumber NVARCHAR(20) NOT NULL,
    FOREIGN KEY (ConferenceID) REFERENCES ConferencesInfo(ConferenceID)
);

CREATE TABLE Speakers (
    SpeakerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    AcademicDegree NVARCHAR(50),
    Workplace NVARCHAR(150) NOT NULL,
    Position NVARCHAR(100) NOT NULL,
    Biography NVARCHAR(MAX)
);

CREATE TABLE Presentations (
    PresentationID INT IDENTITY(1,1) PRIMARY KEY,
    SectionID INT NOT NULL,
    SpeakerID INT NOT NULL,
    Topic NVARCHAR(255) NOT NULL,
    StartTime DATETIME NOT NULL,
    DurationMinutes INT DEFAULT 20,
    FOREIGN KEY (SectionID) REFERENCES Sections(SectionID),
    FOREIGN KEY (SpeakerID) REFERENCES Speakers(SpeakerID)
);
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
(1, 1, 'Вплив блокчейну на банківський сектор', '2026-05-15 10:00:00', 40),
(1, 2, 'Тренди фінтех-стартапів 2026', '2026-05-15 11:00:00', 30),
(2, 1, 'Прогнози інфляції на наступний рік', '2026-05-16 09:30:00', 45),
(3, 4, 'Редагування геному: етичні питання', '2026-09-10 14:00:00', 60),
(4, 3, 'ШІ у ранній діагностиці хвороб', '2026-09-11 11:00:00', 50);
GO
CREATE OR ALTER PROCEDURE Calculate_Conference_Rating
    @p_ConfID INT
AS
BEGIN
    DECLARE @v_total_rating DECIMAL(10, 2);

    -- Рахуємо бали: 10 за спікера, 15 за ступінь, 0.1 за хвилину
    SELECT @v_total_rating = 
        (COUNT(p.PresentationID) * 10) + 
        (SUM(CASE WHEN s.AcademicDegree IS NOT NULL THEN 1 ELSE 0 END) * 15) + 
        (SUM(p.DurationMinutes) * 0.1)
    FROM Presentations p
    JOIN Sections sec ON p.SectionID = sec.SectionID
    JOIN Speakers s ON p.SpeakerID = s.SpeakerID
    WHERE sec.ConferenceID = @p_ConfID;

    -- Оновлюємо таблицю
    UPDATE ConferencesInfo 
    SET Rating = ISNULL(@v_total_rating, 0) 
    WHERE ConferenceID = @p_ConfID;
END;

GO
CREATE OR ALTER PROCEDURE Update_Ratings_In_Period
    @p_StartDate DATE,
    @p_EndDate DATE
AS
BEGIN
    DECLARE @CurrentConfID INT;

    -- Використовуємо курсор для проходу по конференціях у вказаному періоді
    DECLARE conf_cursor CURSOR FOR 
    SELECT ConferenceID FROM ConferencesInfo 
    WHERE StartDate BETWEEN @p_StartDate AND @p_EndDate;

    OPEN conf_cursor;
    FETCH NEXT FROM conf_cursor INTO @CurrentConfID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC Calculate_Conference_Rating @CurrentConfID;
        FETCH NEXT FROM conf_cursor INTO @CurrentConfID;
    END;

    CLOSE conf_cursor;
    DEALLOCATE conf_cursor;
END;
GO
EXEC Update_Ratings_In_Period @p_StartDate = '2026-01-01', @p_EndDate = '2026-12-31';
SELECT Title, Rating FROM ConferencesInfo;
