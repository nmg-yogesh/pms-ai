export const EXAMPLE_QUERIES = [
  "How many orders were placed last month?",
  "Show me the top 5 customers by total spending",
  "What products are running low on stock?",
  "Which category has the most sales?"
];

export const DATABASE_SCHEMA = `
Assume the following database schema:
- users (id, name, email, created_at, status)
- cart_items (id, cart_id, product_id, quantity)
- carts (id, user_id, created_at)
- categories (id, name,slug)
- order_items (id, order_id, product_id, quantity, price)
- orders (id, user_id, total_amount, created_at, status,address_id)
- payments_methods (id, user_id,provder,details,is_default)
- payments (id, order_id, amount, status, provider,transaction_ref,created_at)
- products (id, name, description, price, stock, category_id)
- user_addresses (id, user_id,full_name,phone,address_line1,address_line2, city, state, country, postal_code,is_default)
`;

export const OPENAI_MODEL = 'gpt-4o-mini';
export const SQL_MAX_TOKENS = 1000;
export const EXPLANATION_MAX_TOKENS = 1500;

export const DEMO_MESSAGE = 'Demo Mode: This interface uses simulated data. To connect to a real MySQL database, you\'ll need to implement a secure backend API.';
export const CONFIG_DISCLAIMER = 'Note: This is a demo interface. In production, database credentials should be configured on the backend for security.';
