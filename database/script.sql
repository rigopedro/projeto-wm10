CREATE TABLE users (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE products (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE logs (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT,
    operation VARCHAR(10) NOT NULL,
    log_data VARCHAR(500),
    changed_by VARCHAR(100),
    log_date DATETIME DEFAULT GETDATE()
);

PRINT 'Tabelas criadas com sucesso!';