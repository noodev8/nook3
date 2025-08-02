-- Add missing store information to existing system_settings table
-- This extends the current system_settings with additional store configuration

INSERT INTO system_settings (setting_key, setting_value, description) VALUES
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
ON CONFLICT (setting_key) DO NOTHING;

-- Create function to update the updated_at timestamp for system_settings if it doesn't exist
CREATE OR REPLACE FUNCTION update_system_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at if it doesn't exist
DROP TRIGGER IF EXISTS update_system_settings_updated_at_trigger ON system_settings;
CREATE TRIGGER update_system_settings_updated_at_trigger
    BEFORE UPDATE ON system_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_system_settings_updated_at();