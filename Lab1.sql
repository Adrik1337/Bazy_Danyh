CREATE DATABASE CONFERENCES;
GO
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
(1, 1, 'Вплив блокчейну на банківський сектор', '2026-05-15 10:00:00', 40),
(1, 2, 'Тренди фінтех-стартапів 2026', '2026-05-15 11:00:00', 30),
(2, 1, 'Прогнози інфляції на наступний рік', '2026-05-16 09:30:00', 45),
(3, 4, 'Редагування геному: етичні питання', '2026-09-10 14:00:00', 60),
(4, 3, 'ШІ у ранній діагностиці хвороб', '2026-09-11 11:00:00', 50);
GO
SELECT * FROM ConferencesInfo; 
SELECT * FROM Sections;        
SELECT * FROM Speakers;        
SELECT * FROM Presentations;