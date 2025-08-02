-- Store Information Table
-- This table stores dynamic store information to avoid hardcoded values in the app

CREATE TABLE IF NOT EXISTS store_info (
    id SERIAL PRIMARY KEY,
    info_key VARCHAR(50) UNIQUE NOT NULL,
    info_value TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default store information
INSERT INTO store_info (info_key, info_value, description) VALUES
('store_name', 'The Nook of Welshpool', 'Business name'),
('store_address', '42 High Street, Welshpool, SY21 7JQ', 'Full store address'),
('store_phone', '01938 123456', 'Store contact phone number'),
('store_email', 'info@nookofwelshpool.co.uk', 'Store contact email'),
('opening_hours_mon_fri', '10:00 AM - 5:00 PM', 'Monday to Friday opening hours'),
('opening_hours_saturday', '10:00 AM - 4:00 PM', 'Saturday opening hours'),
('opening_hours_sunday', 'Closed', 'Sunday opening hours'),
('delivery_radius_miles', '5', 'Delivery radius in miles'),
('minimum_order_delivery', '15.00', 'Minimum order amount for delivery'),
('delivery_fee', '2.50', 'Standard delivery fee'),
('collection_instructions', 'Please arrive at the stated collection time. Ring bell if shop appears closed.', 'Instructions for collection'),
('delivery_instructions', 'We deliver within 5 miles of Welshpool. Please ensure someone is available to receive the order.', 'Instructions for delivery'),
('business_description', 'Local food business specializing in buffets and share boxes for groups and events.', 'Business description for info page')
ON CONFLICT (info_key) DO NOTHING;

-- Create function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_store_info_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_store_info_updated_at_trigger ON store_info;
CREATE TRIGGER update_store_info_updated_at_trigger
    BEFORE UPDATE ON store_info
    FOR EACH ROW
    EXECUTE FUNCTION update_store_info_updated_at();