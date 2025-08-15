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

PRINT 'tabelas criadas com sucesso!';
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

PRINT 'procedures de autenticação criadas';

CREATE TRIGGER log_update
ON products
AFTER UPDATE
AS
BEGIN
    INSERT INTO logs (product_id, operation, log_data, changed_by)
    SELECT
        i.id,
        'UPDATE',
        'Produto ' + i.name + ' atualizado.',
        CAST(CONTEXT_INFO() AS VARCHAR(100))
    FROM
        inserted i;
END
GO

CREATE TRIGGER log_delete
ON products
AFTER DELETE
AS
BEGIN
    INSERT INTO logs (product_id, operation, log_data, changed_by)
    SELECT
        d.id,
        'DELETE',
        'Produto ' + d.name + ' deletado.',
        CAST(CONTEXT_INFO() AS VARCHAR(100))
    FROM
        deleted d;
END
GO

CREATE FUNCTION fn_validate_token(@token VARCHAR(255))
RETURNS BIT
AS
BEGIN
    IF @token IS NOT NULL AND LEN(@token) > 10
        RETURN 1;

    RETURN 0;
END
GO

PRINT 'triggers e Function criadas';