CREATE TABLE users (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);
GO


CREATE TABLE products (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO


CREATE TABLE logs (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT,
    operation VARCHAR(10) NOT NULL,
    log_data VARCHAR(500),
    changed_by VARCHAR(100),
    log_date DATETIME DEFAULT GETDATE()
);

PRINT 'Tabelas criadas com sucesso!';
GO


CREATE PROCEDURE add_user
    @name VARCHAR(100),
    @email VARCHAR(100),
    @password_hash VARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM users WHERE email = @email)
    BEGIN
        SELECT 0 AS success, 'email já utilizado' AS message;
        RETURN;
    END

    INSERT INTO users (name, email, password_hash)
    VALUES (@name, @email, @password_hash);

    SELECT 1 AS success, 'usuário registrado com sucesso' AS message;
END
GO

CREATE PROCEDURE login_user
    @email VARCHAR(100),
    @password_hash VARCHAR(255)
AS
BEGIN
    SELECT id, name, email
    FROM users
    WHERE email = @email AND password_hash = @password_hash;
END
GO

PRINT 'Procedures de autenticação criadas!';