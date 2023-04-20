CREATE DATABASE FINAL_PROJECT

USE FINAL_PROJECT

CREATE TABLE Hospital (
    HospitalID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50),
    Direccion VARCHAR(100),
    Telefono VARCHAR(20), 
    Provincia VARCHAR(50) NOT NULL
);

CREATE TABLE CentroMedico (
    CentroMedicoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50),
    Direccion VARCHAR(100),
    HospitalID INT,
    FOREIGN KEY (HospitalID) REFERENCES Hospital(HospitalID)
);

CREATE TABLE Medico (
    MedicoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Especialidad VARCHAR(50) NOT NULL,
	FechaIngreso DATE NOT NULL
);

CREATE TABLE Paciente (
    PacienteID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50),
    FechaNacimiento DATE NOT NULL,
    Genero CHAR(1) NOT NULL,
    Diagnostico VARCHAR(100) NOT NULL,
	FechaDiagnostico DATE NOT NULL,
    MedicoID INT,
    FOREIGN KEY (MedicoID) REFERENCES Medico(MedicoID)
);

CREATE TABLE ClinicaAfiliada (
    ClinicaAfiliadaID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50),
    Direccion VARCHAR(100),
	Provincia VARCHAR(50),
    HospitalID INT,
    FOREIGN KEY (HospitalID) REFERENCES Hospital(HospitalID)
);

CREATE TABLE Historia (
    HistoriaID INT IDENTITY(1,1) PRIMARY KEY,
    ClinicaAfiliadaID INT,
    MedicoID INT,
    Cantidad INT,
    FOREIGN KEY (ClinicaAfiliadaID) REFERENCES ClinicaAfiliada(ClinicaAfiliadaID),
    FOREIGN KEY (MedicoID) REFERENCES Medico(MedicoID)
);


INSERT INTO Hospital (Nombre, Direccion, Telefono, Provincia)
VALUES ('Hospital Dar�o Contreras', 'Calle Principal #123', '809-123-4567', 'Santo Domingo'),
       ('Hospital del Este', 'Avenida del Sol #456', '809-987-6543', 'La Altragacia'),
       ('Hospital Jos� Cabral', 'Calle Mayor #789', '809-567-8901', 'Santiago');

INSERT INTO CentroMedico (Nombre, Direccion, HospitalID)
VALUES ('Centro M�dico ABC', 'Avenida Independencia #456', 1),
       ('Centro M�dico XYZ', 'Calle Libertad #789', 3),
       ('Centro M�dico DEF', 'Avenida del Este #123', 2);

INSERT INTO Medico (Nombre, Especialidad, FechaIngreso)
VALUES ('Juan Perez', 'Pediatr�a', '2022-01-15'),
       ('Maria Rodriguez', 'Cardiolog�a', '2023-01-30'),
       ('Carlos Gomez', 'Oncolog�a', '2023-03-10'),
       ('Laura Fernandez', 'Dermatolog�a', '2022-11-05');

INSERT INTO Paciente (Nombre, FechaNacimiento, Genero, Diagnostico, FechaDiagnostico, MedicoID)
VALUES ('Mar�a Ram�rez', '1985-05-10', 'F', 'Hipertensi�n', '2023-04-01', 1),
       ('Pedro Santos', '1990-07-15', 'M', 'Diabetes', '2023-04-02', 2),
       ('Laura G�mez', '1978-12-20', 'F', 'Asma', '2023-03-31', 3),
	   ('Pedro Sanchez', '1954-05-29', 'M', 'Artritis', '2023-04-07', 1);

INSERT INTO ClinicaAfiliada (Nombre, Direccion, Provincia, HospitalID)
VALUES ('Cl�nica XYZ', 'Calle Duarte #789', 'La Romana', 1),
       ('Cl�nica ABC', 'Avenida Espa�a #456', 'Espaillat', 2),
       ('Cl�nica DEF', 'Calle Mayor #123', 'San Juan', 3),
	   ('Cl�nica GHI', 'Avenida Gom�z #321', 'San Juan', 2);

INSERT INTO Historia (ClinicaAfiliadaID, MedicoID, Cantidad)
VALUES (1, 1, 5),
       (2, 2, 3),
       (3, 3, 2);

select * from Historia

-- Muestre la cantidad de cl�nicas por provincias
GO
CREATE VIEW ClinicasProvincias AS
SELECT Provincia, COUNT(*) AS CantidadClinicas
FROM ClinicaAfiliada
GROUP BY Provincia;

GO -- Test VIEW ClinicasProvincias
SELECT Provincia, CantidadClinicas
FROM ClinicasProvincias;


-- Inserta la cantidad de consultas de cada m�dico en cada cl�nica utilizando un cursor
GO
CREATE PROCEDURE InsertarConsultasMedicos
AS
BEGIN
    DECLARE @idClinica INT, 
	@idMedico INT, 
	@cantidad INT
    
    DECLARE cursorMedicos CURSOR FOR
	SELECT c.ClinicaAfiliadaID, m.MedicoID, v.CantidadClinicas
    FROM Medico m
    CROSS JOIN ClinicasProvincias v
    INNER JOIN ClinicaAfiliada c ON v.Provincia = c.Provincia
    
    OPEN cursorMedicos
    
    -- Obtener la siguiente fila del cursor
    FETCH NEXT FROM cursorMedicos INTO @idClinica, @idMedico, @cantidad
    
    -- Loop a trav�s de las filas del cursor
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Insertar la cantidad de consultas del m�dico en la cl�nica en la tabla Historia
        INSERT INTO Historia (ClinicaAfiliadaID, MedicoID, Cantidad)
        VALUES (@idClinica, @idMedico, @cantidad)
        
        -- Obtener la siguiente fila del cursor
        FETCH NEXT FROM cursorMedicos INTO @idClinica, @idMedico, @cantidad
    END
    
    CLOSE cursorMedicos
    DEALLOCATE cursorMedicos
END

--Test
EXEC InsertarConsultasMedicos;


-- Total de m�dicos a partir de la cl�nica indicada como par�metro
GO
CREATE FUNCTION TotalMedicosPorClinica
(
    @ClinicaAfiliadaID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalMedicos INT;

    SELECT @TotalMedicos = COUNT(*) 
    FROM Medico m
    INNER JOIN Historia h ON m.MedicoID = h.MedicoID
    WHERE h.ClinicaAfiliadaID = @ClinicaAfiliadaID;

    RETURN @TotalMedicos;
END;

--Test TotalMedicosPorClinica
GO
DECLARE @ClinicaAfiliadaID INT = 4; -- Reemplaza con el ID de la cl�nica deseada

SELECT ca.Nombre AS NombreClinica, dbo.TotalMedicosPorClinica(@ClinicaAfiliadaID) AS TotalMedicos
FROM ClinicaAfiliada ca
WHERE ca.ClinicaAfiliadaID = @ClinicaAfiliadaID;

Go
DECLARE 
@resultado INT,
@clinicaID INT;

SET @clinicaID = 3;

SET @resultado = dbo.TotalMedicosPorClinica(@clinicaID);

PRINT 'El total de m�dicos en la cl�nica es: ' + CONVERT(NVARCHAR(10), @resultado);

GO
DROP FUNCTION TotalMedicosPorClinica


-- Diagn�stico de un paciente filtrando por fecha
GO
SELECT p.Nombre AS Nombre_Paciente, p.Diagnostico AS Diagnostico, 
p.FechaDiagnostico AS Fecha_Diagnostico
FROM Paciente p
WHERE p.FechaDiagnostico BETWEEN '2023-03-01' AND '2023-04-03';



-- M�dicos que ingresaron al centro este a�o
GO
CREATE VIEW MedicosIngresadosEsteAnio AS
SELECT m.MedicoID, m.Nombre, m.Especialidad, m.FechaIngreso
FROM Medico m
WHERE YEAR(m.FechaIngreso) = YEAR(GETDATE());

GO -- Test VIEW MedicosIngresadosEsteAnio
SELECT Nombre, Especialidad, FechaIngreso
FROM MedicosIngresadosEsteAnio;

DROP VIEW MedicosIngresadosEsteAnio;





