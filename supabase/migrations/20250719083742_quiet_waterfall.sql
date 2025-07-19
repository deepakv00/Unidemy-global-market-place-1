/*
  # Add Special Categories and is_special Column

  1. Schema Changes
    - Add `is_special` column to categories table
    - Set default value to false for existing categories
  
  2. New Categories
    - Add "Donate" category for free items
    - Add "Urgent Sale" category for fast selling
    - Mark both as special categories
  
  3. Sample Products
    - Add 2 donation products (price = 0)
    - Add 2 urgent sale products
    - Use realistic data with proper locations
*/

-- Add is_special column to categories table
ALTER TABLE categories ADD COLUMN IF NOT EXISTS is_special boolean DEFAULT false;

-- Insert special categories if they don't exist
INSERT INTO categories (name, description, is_special) 
VALUES 
  ('Donate', 'Free items and community donations', true),
  ('Urgent Sale', 'Quick sales for moving or urgent needs', true)
ON CONFLICT (name) DO UPDATE SET 
  description = EXCLUDED.description,
  is_special = EXCLUDED.is_special;

-- Insert sample products for special categories
DO $$
DECLARE
  donate_category_id uuid;
  urgent_category_id uuid;
  sample_user_id uuid;
BEGIN
  -- Get category IDs
  SELECT id INTO donate_category_id FROM categories WHERE name = 'Donate';
  SELECT id INTO urgent_category_id FROM categories WHERE name = 'Urgent Sale';
  
  -- Get a sample user ID (use first user or create a placeholder)
  SELECT id INTO sample_user_id FROM user_profiles LIMIT 1;
  
  -- If no users exist, skip product creation
  IF sample_user_id IS NOT NULL THEN
    -- Insert donation products (price = 0)
    INSERT INTO products (
      seller_id, title, description, price, category_id, condition, 
      location, city, state, pincode, image_urls, status
    ) VALUES 
    (
      sample_user_id,
      'Free Study Desk - Good Condition',
      'Giving away a sturdy wooden study desk. Perfect for students! Has some minor scratches but very functional. Pick up only.',
      0,
      donate_category_id,
      'good',
      'Downtown Campus Area',
      'Austin',
      'Texas',
      '73301',
      ARRAY['https://images.pexels.com/photos/667838/pexels-photo-667838.jpeg?auto=compress&cs=tinysrgb&w=400'],
      'active'
    ),
    (
      sample_user_id,
      'Free Textbooks - Engineering & Math',
      'Collection of engineering and mathematics textbooks. Calculus, Physics, and Computer Science books included. Free to good home!',
      0,
      donate_category_id,
      'good',
      'University District',
      'Austin',
      'Texas',
      '73301',
      ARRAY['https://images.pexels.com/photos/159711/books-bookstore-book-reading-159711.jpeg?auto=compress&cs=tinysrgb&w=400'],
      'active'
    ),
    -- Insert urgent sale products
    (
      sample_user_id,
      'MacBook Air M1 - Moving Sale',
      'Excellent condition MacBook Air with M1 chip. Moving out of state next week, need to sell quickly! Includes charger and original box.',
      899,
      urgent_category_id,
      'like_new',
      'Tech District',
      'Austin',
      'Texas',
      '73301',
      ARRAY['https://images.pexels.com/photos/205421/pexels-photo-205421.jpeg?auto=compress&cs=tinysrgb&w=400'],
      'active'
    ),
    (
      sample_user_id,
      'Complete Bedroom Set - Must Go!',
      'Moving sale! Complete bedroom set including queen bed frame, mattress, dresser, and nightstand. Everything must go by weekend!',
      299,
      urgent_category_id,
      'good',
      'Residential Area',
      'Austin',
      'Texas',
      '73301',
      ARRAY['https://images.pexels.com/photos/1743229/pexels-photo-1743229.jpeg?auto=compress&cs=tinysrgb&w=400'],
      'active'
    )
    ON CONFLICT DO NOTHING;
  END IF;
END $$;