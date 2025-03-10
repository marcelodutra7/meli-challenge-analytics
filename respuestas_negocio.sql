
-- TAREFA 01

SELECT c.*
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
WHERE 
    -- Verifica se o mês e o dia do nascimento são iguais ao de hoje
    MONTH(c.birth_date) = MONTH(CURDATE()) 
    AND DAY(c.birth_date) = DAY(CURDATE())
    -- Filtra pedidos realizados em janeiro de 2020
    AND o.date_create BETWEEN '2020-01-01 00:00:00' AND '2020-01-31 23:59:59'
GROUP BY c.customer_id
HAVING COUNT(o.order_id) > 1500;

-- TAREFA 02

WITH SalesByUser AS (
    SELECT 
        MONTH(o.date_create) AS mes,
        YEAR(o.date_create) AS ano,
        c.name AS nome,
		c.last_name AS sobrenome,
        COUNT(o.order_id) AS qtd_vendas,
        SUM(o.value) AS total_transacionado,
        COUNT(o.item_id) AS qtd_produtos
    FROM orders o
    JOIN customer c ON o.customer_id = c.customer_id
    JOIN item i ON o.item_id = i.item_id
    JOIN category cat ON i.category_id = cat.category_id
    WHERE 
        cat.name = 'Celulares' -- Filtra apenas a categoria desejada
        AND o.date_create BETWEEN '2020-01-01' AND '2020-12-31' -- Apenas no ano de 2020
    GROUP BY mes, ano, cliente
)
SELECT *
FROM (
    SELECT 
        sb.*,
        ROW_NUMBER() OVER (PARTITION BY sb.ano, sb.mes ORDER BY sb.qtd_vendas DESC) AS ranking -- numera os clientes por mês e ano com base na quantidade de vendas
    FROM SalesByUser sb
) ranked
WHERE ranking <= 5
ORDER BY ano, mes, ranking;

-- TAREFA 03

-- executa a procedure SP_GENERATE_ITEM_HISTORY para limpar e popular a tabela ITEM_DAILY_HISTORY
CALL item_daily_history('2025-03-09'); -- Gera histórico para o dia 09/03/2025
