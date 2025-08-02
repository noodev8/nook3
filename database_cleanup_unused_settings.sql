-- Clean up unused settings from system_settings table
-- Remove settings that are not actually used by the application

DELETE FROM system_settings WHERE setting_key IN (
    'delivery_radius_miles',
    'minimum_order_delivery',
    'delivery_fee',
    'delivery_instructions',
    'order_confirmation_required',
    'minimum_advance_booking_hours'
);

-- Show remaining settings after cleanup
SELECT * FROM system_settings ORDER BY setting_key;