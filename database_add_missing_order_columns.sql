-- Add missing columns to orders table for order confirmation system
-- This adds columns needed for order numbers and customer phone numbers

-- Add order_number column
ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_number VARCHAR(20) UNIQUE;

-- Add guest_phone column for storing customer phone numbers
ALTER TABLE orders ADD COLUMN IF NOT EXISTS guest_phone VARCHAR(20);

-- Add updated_at column for tracking order updates
ALTER TABLE orders ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Create index for order_number lookups
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON orders (order_number);

-- Create trigger to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_orders_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_orders_updated_at_trigger ON orders;
CREATE TRIGGER update_orders_updated_at_trigger
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_orders_updated_at();

-- Show updated table structure
\d orders;