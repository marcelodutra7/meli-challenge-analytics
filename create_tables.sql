CREATE TABLE customer (
  customer_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único do cliente',
  name VARCHAR(255) NOT NULL COMMENT 'Nome do cliente',
  last_name VARCHAR(100) NOT NULL COMMENT 'Sobrenome do cliente',
  email VARCHAR(255) UNIQUE NOT NULL COMMENT 'Endereço de e-mail do cliente',
  phone VARCHAR(20) COMMENT 'Número de telefone do cliente',
  document VARCHAR(20) UNIQUE COMMENT 'Documento de identificação (CPF/CNPJ)',
  document_type ENUM('PF', 'PJ') NOT NULL COMMENT 'Tipo de documento: PF (Pessoa Física) ou PJ (Pessoa Jurídica)',
  gender VARCHAR(10) NOT NULL COMMENT 'Gênero do cliente',
  birth_date DATE COMMENT 'Data de nascimento do cliente',
  address VARCHAR(255) COMMENT 'Endereço do cliente',
  zip_code VARCHAR(10) COMMENT 'Código postal (CEP) do cliente',
  city VARCHAR(100) COMMENT 'Cidade do cliente',
  state VARCHAR(50) COMMENT 'Estado do cliente',
  country VARCHAR(100) COMMENT 'País do cliente',
  date_create TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
  date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização do registro'
);

CREATE TABLE category (
  category_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único da categoria',
  name VARCHAR(255) NOT NULL UNIQUE COMMENT 'Nome da categoria',
  description TEXT COMMENT 'Descrição da categoria',
  parent_id INT NULL COMMENT 'Categoria pai para categorias hierárquicas',
  is_active BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Indica se a categoria está ativa (1) ou inativa (0)',
  date_create TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
  date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização do registro',
  FOREIGN KEY (parent_id) REFERENCES category(category_id) ON DELETE SET NULL
);

CREATE TABLE item (
  item_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único do item',
  category_id INT NOT NULL COMMENT 'Identificador da categoria a que o item pertence',
  name VARCHAR(255) NOT NULL COMMENT 'Nome do item',
  description TEXT COMMENT 'Descrição detalhada do item',
  price DECIMAL(10,2) NOT NULL COMMENT 'Preço do item',
  is_active BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Indica se o item está ativo (1) ou inativo (0)',
  date_create TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
  date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização do registro',
  FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE
);

CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único do pedido',
  customer_id INT NOT NULL COMMENT 'Identificador do cliente que fez o pedido',
  item_id INT NOT NULL COMMENT 'Identificador do item comprado',
  value DECIMAL(10,2) NOT NULL COMMENT 'Valor total do pedido',
  status VARCHAR(20) NOT NULL COMMENT 'Status do pedido (Ex: Pendente, Pago, Cancelado)',
  shipping_address TEXT COMMENT 'Endereço de entrega do pedido',
  shipping_method VARCHAR(50) COMMENT 'Método de entrega escolhido',
  payment_method VARCHAR(50) COMMENT 'Método de pagamento utilizado',
  payment_status VARCHAR(20) COMMENT 'Status do pagamento (Ex: Aprovado, Recusado, Pendente)',
  order_source VARCHAR(50) COMMENT 'Origem do pedido (Ex: App, Site, Loja Física)',
  date_create TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do pedido',
  date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização do pedido',
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE CASCADE
);

CREATE TABLE item_daily_history (
    date DATE NOT NULL COMMENT 'Data do snapshot',
    item_id INT NOT NULL COMMENT 'Identificador do item',
    value DECIMAL(10,2) NOT NULL COMMENT 'Preço do item no final do dia',
    status VARCHAR NOT NULL COMMENT 'Status do item no final do dia',
    date_create TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de inserção no histórico',
    PRIMARY KEY (date, item_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE CASCADE
);

CREATE PROCEDURE sp_generate_item_history(IN p_date DATE)
BEGIN
    -- Remove registros do mesmo dia para garantir reprocessamento
    DELETE FROM item_daily_history WHERE date = p_date;

    -- Insere os registros com o status final do dia
    INSERT INTO item_daily_history (date, item_id, value, status)
    SELECT 
        p_date AS date, 
        i.item_id, 
        i.value, 
        i.status
    FROM item i;
    
END