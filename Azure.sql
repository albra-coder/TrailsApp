-- Create schema CW1
GO
CREATE SCHEMA CW1;
GO

-- Create Users table
CREATE TABLE CW1.Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    Role NVARCHAR(50) NOT NULL
);
GO

-- Create Trails table
CREATE TABLE CW1.Trails (
    TrailID INT PRIMARY KEY IDENTITY(1,1),
    TrailName NVARCHAR(100) NOT NULL,
    Distance DECIMAL(10,2) NOT NULL,
    Duration NVARCHAR(50) NOT NULL,
    TrailDescription NVARCHAR(255) NULL
);
GO

-- Create Trail_Owner table as a link entity
CREATE TABLE CW1.Trail_Owner (
    OwnerID INT PRIMARY KEY IDENTITY(1,1),
    TrailID INT,
    UserID INT,
    FOREIGN KEY (TrailID) REFERENCES CW1.Trails(TrailID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES CW1.Users(UserID) ON DELETE CASCADE
);
GO

-- Create TrailLog table
CREATE TABLE CW1.TrailLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TrailID INT,
    UserName NVARCHAR(100),
    Action NVARCHAR(50),
    Timestamp DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (TrailID) REFERENCES CW1.Trails(TrailID)
);
GO

-- Insert demo data into Users table
INSERT INTO CW1.Users (Name, Email, Role) VALUES 
('Grace Hopper', 'grace@plymouth.ac.uk', 'Admin'),
('Tim Berners-Lee', 'tim@plymouth.ac.uk', 'Member'),
('Ada Lovelace', 'ada@plymouth.ac.uk', 'Member');
GO

-- Insert demo data into Trails table
INSERT INTO CW1.Trails (TrailName, Distance, Duration, TrailDescription) VALUES 
('Plymbridge Circular', 5.5, '2 hours', 'A circular trail around Plymbridge.'),
('Plymouth Waterfront', 6.0, '2.5 hours', 'A scenic trail along the waterfront.'),
('Cornwall Coastal Path', 7.0, '3 hours', 'A stunning coastal path in Cornwall.');
GO

-- Insert demo data into Trail_Owner table
INSERT INTO CW1.Trail_Owner (TrailID, UserID) VALUES 
(1, 1),  -- Grace owns Plymbridge Circular
(2, 2),  -- Tim owns Plymouth Waterfront
(3, 3);  -- Ada owns Cornwall Coastal Path
GO

-- Select all users
SELECT * FROM CW1.Users;
GO

-- Select all trails
SELECT * FROM CW1.Trails;
GO

-- Select all trail owners
SELECT * FROM CW1.Trail_Owner;
GO

-- Create a view to combine trail details with their owners
CREATE VIEW CW1.TrailDetails AS
SELECT 
    t.TrailID,
    t.TrailName,
    t.Distance,
    t.Duration,
    t.TrailDescription,
    u.Name AS OwnerName,
    u.Email AS OwnerEmail
FROM 
    CW1.Trails t
JOIN 
    CW1.Trail_Owner to_ ON t.TrailID = to_.TrailID -- Changed alias to 'to_' 
JOIN 
    CW1.Users u ON to_.UserID = u.UserID;
GO
-- Select from the view to check the combined data
SELECT * FROM CW1.TrailDetails;
-- Start a new batch
GO

-- Create InsertTrail procedure
CREATE PROCEDURE CW1.InsertTrail
    @TrailName NVARCHAR(100),
    @Distance FLOAT,
    @Duration NVARCHAR(50),
    @TrailDescription NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        INSERT INTO CW1.Trails (TrailName, Distance, Duration, TrailDescription)
        VALUES (@TrailName, @Distance, @Duration, @TrailDescription);
    END TRY
    BEGIN CATCH
        -- Log the error or return a message
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
CREATE PROCEDURE CW1.GetTrailById
    @TrailID INT
AS
BEGIN
    SELECT * FROM CW1.Trails WHERE TrailID = @TrailID;
END;
-- Start a new batch
GO

-- Create UpdateTrail procedure
CREATE PROCEDURE CW1.UpdateTrail
    @TrailID INT,
    @TrailName NVARCHAR(100),
    @Distance FLOAT,
    @Duration NVARCHAR(50),
    @TrailDescription NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        UPDATE CW1.Trails
        SET 
            TrailName = @TrailName,
            Distance = @Distance,
            Duration = @Duration,
            TrailDescription = @TrailDescription
        WHERE TrailID = @TrailID;
    END TRY
    BEGIN CATCH
        -- Log the error or return a message
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
CREATE PROCEDURE CW1.DeleteTrail
    @TrailID INT
AS
BEGIN
    DELETE FROM CW1.Trails WHERE TrailID = @TrailID;
END;
EXEC CW1.InsertTrail 
    @TrailName = 'New Trail',
    @Distance = 5.0,
    @Duration = '2 hours',
    @TrailDescription = 'A beautiful new trail for hiking enthusiasts.';
EXEC CW1.GetTrailById @TrailID = 1;  -- Replace 1 with an existing TrailID
EXEC CW1.UpdateTrail 
    @TrailID = 1, 
    @TrailName = 'Updated Trail',
    @Distance = 6.0,
    @Duration = '2.5 hours',
    @TrailDescription = 'An updated description for the trail.';
EXEC CW1.DeleteTrail @TrailID = 1;  -- Replace 1 with the ID of the trail you want to delete
CREATE TABLE CW1.TrailLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TrailID INT,
    UserName NVARCHAR(100),
    Action NVARCHAR(50),
    Timestamp DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (TrailID) REFERENCES CW1.Trails(TrailID)
);
-- Create the trigger for logging trail additions
GO

CREATE TRIGGER CW1.LogTrailAddition
ON CW1.Trails
AFTER INSERT
AS
BEGIN
    INSERT INTO CW1.TrailLog (TrailID, UserName, Action)
    SELECT 
        i.TrailID,
        SYSTEM_USER AS UserName,  -- Get the name of the user who performed the action
        'Added' AS Action
    FROM 
        inserted i;
END;
GO
SELECT * FROM CW1.Trails;
SELECT * FROM CW1.TrailLog;
EXEC CW1.InsertTrail 
    @TrailName = 'Test Trail',
    @Distance = 4.0,
    @Duration = '1.5 hours',
    @TrailDescription = 'A trail for testing trigger functionality.';
SELECT * FROM CW1.TrailLog;

