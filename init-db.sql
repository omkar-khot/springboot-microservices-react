-- Database Initialization Script
-- This script creates the necessary schemas and tables for the microservices

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table (for User Service)
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products Table (for Product Service)
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    category VARCHAR(50),
    sku VARCHAR(50) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Roles Table (for Auth Service)
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255)
);

-- User Roles Table (for Auth Service)
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- Refresh Tokens Table (for Auth Service)
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(500) UNIQUE NOT NULL,
    expiry_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);

-- Insert Default Roles
INSERT INTO roles (name, description) VALUES 
    ('ROLE_USER', 'Standard user role'),
    ('ROLE_ADMIN', 'Administrator role'),
    ('ROLE_MODERATOR', 'Moderator role')
ON CONFLICT (name) DO NOTHING;

-- Insert Sample Users (password is 'password123' hashed with BCrypt)
INSERT INTO users (username, email, password, first_name, last_name) VALUES 
    ('admin', 'admin@example.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'Admin', 'User'),
    ('john_doe', 'john@example.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'John', 'Doe'),
    ('jane_smith', 'jane@example.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'Jane', 'Smith')
ON CONFLICT (username) DO NOTHING;

-- Assign Roles to Users
INSERT INTO user_roles (user_id, role_id) 
SELECT u.id, r.id FROM users u, roles r 
WHERE u.username = 'admin' AND r.name = 'ROLE_ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id) 
SELECT u.id, r.id FROM users u, roles r 
WHERE u.username IN ('john_doe', 'jane_smith') AND r.name = 'ROLE_USER'
ON CONFLICT DO NOTHING;

-- Insert Sample Products
INSERT INTO products (name, description, price, quantity, category, sku) VALUES 
    ('Laptop Pro 15', 'High-performance laptop with 15-inch display', 1299.99, 50, 'Electronics', 'LAP-PRO-15'),
    ('Wireless Mouse', 'Ergonomic wireless mouse with USB receiver', 29.99, 200, 'Accessories', 'MOU-WIR-01'),
    ('USB-C Hub', '7-in-1 USB-C hub with HDMI and SD card reader', 49.99, 150, 'Accessories', 'HUB-USC-01'),
    ('Mechanical Keyboard', 'RGB mechanical keyboard with blue switches', 89.99, 75, 'Accessories', 'KEY-MEC-RGB'),
    ('Monitor 27"', '4K UHD 27-inch monitor with HDR support', 399.99, 30, 'Electronics', 'MON-27-4K'),
    ('Webcam HD', '1080p HD webcam with built-in microphone', 69.99, 100, 'Electronics', 'WEB-HD-01'),
    ('Desk Lamp LED', 'Adjustable LED desk lamp with USB charging', 34.99, 120, 'Office', 'LAM-LED-01'),
    ('Headphones BT', 'Bluetooth over-ear headphones with noise cancellation', 149.99, 80, 'Audio', 'HEAD-BT-NC'),
    ('Portable SSD 1TB', 'External SSD with 1TB storage and USB 3.2', 129.99, 60, 'Storage', 'SSD-EXT-1TB'),
    ('Phone Stand', 'Adjustable phone stand for desk', 19.99, 250, 'Accessories', 'STD-PHN-01')
ON CONFLICT (sku) DO NOTHING;

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions (optional, adjust as needed)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
