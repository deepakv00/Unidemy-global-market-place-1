/*
  # Add Special Categories and Sample Products

  1. New Categories
    - `Donate` - For free items/donations
    - `Urgent Sale` - For fast selling when relocating
  
  2. Sample Products
    - 2 donation items (price = 0)
    - 2 urgent sale items
  
  3. Updates
    - Mark special categories with is_special flag
    - Add sample products with realistic data
*/

-- Add is_special column to categories if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'categories' AND column_name = 'is_special'
  ) THEN
    ALTER TABLE categories ADD COLUMN is_special boolean DEFAULT false;
  END IF;
END $$;

-- Insert special categories
INSERT INTO categories (name, description, is_special) VALUES
  ('Donate', 'Free items and donations - help your community by giving away items you no longer need', true),
  ('Urgent Sale', 'Quick sales for moving, relocation, or urgent situations - priced to sell fast', true)
ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  is_special = EXCLUDED.is_special;

-- Get category IDs for sample products
DO $$
DECLARE
  donate_category_id uuid;
  urgent_category_id uuid;
  electronics_category_id uuid;
  furniture_category_id uuid;
  sample_user_id uuid;
BEGIN
  -- Get category IDs
  SELECT id INTO donate_category_id FROM categories WHERE name = 'Donate';
  SELECT id INTO urgent_category_id FROM categories WHERE name = 'Urgent Sale';
  SELECT id INTO electronics_category_id FROM categories WHERE name = 'Electronics';
  SELECT id INTO furniture_category_id FROM categories WHERE name = 'Furniture';
  
  -- Create a sample user if none exists
  INSERT INTO user_profiles (id, full_name, phone, city, state, pincode, role)
  VALUES (
    gen_random_uuid(),
    'Community Helper',
    '+1-555-0199',
    'Toronto',
    'Ontario',
    'M5V 3A8',
    'both'
  )
  ON CONFLICT (id) DO NOTHING
  RETURNING id INTO sample_user_id;
  
  -- If no user was created (conflict), get an existing user
  IF sample_user_id IS NULL THEN
    SELECT id INTO sample_user_id FROM user_profiles LIMIT 1;
  END IF;
  
  -- Insert donation products (price = 0)
  INSERT INTO products (
    seller_id, title, description, price, category_id, condition, 
    location, city, state, pincode, image_urls, status
  ) VALUES
  (
    sample_user_id,
    'Free Study Desk - Good Condition',
    'Giving away a sturdy wooden study desk. Perfect for students! Has some minor scratches but very functional. Great for dorm rooms or home office. Must pick up from downtown Toronto.',
    0,
    furniture_category_id,
    'good',
    'Downtown Toronto, ON',
    'Toronto',
    'Ontario',
    'M5V 3A8',
    ARRAY['https://images.pexels.com/photos/667838/pexels-photo-667838.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=300&w=400'],
    'active'
  ),
  (
    sample_user_id,
    'Free Textbooks - Engineering & Math',
    'Collection of engineering and mathematics textbooks from university. Calculus, Physics, Engineering Mechanics, and more. All in good readable condition. Perfect for students who need them!',
    0,
    donate_category_id,
    'good',
    'North York, Toronto, ON',
    'Toronto',
    'Ontario',
    'M2N 1A1',
    ARRAY['https://images.pexels.com/photos/159581/dictionary-reference-book-learning-meaning-159581.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=300&w=400'],
    'active'
  );
  
  -- Insert urgent sale products
  INSERT INTO products (
    seller_id, title, description, price, category_id, condition, 
    location, city, state, pincode, image_urls, status
  ) VALUES
  (
    sample_user_id,
    'URGENT: MacBook Air M1 - Moving Sale',
    'Moving to another country next week! Selling my MacBook Air M1 (2021) in excellent condition. Barely used, comes with original charger and box. Perfect for students or professionals. Quick sale needed!',
    899,
    electronics_category_id,
    'like_new',
    'Mississauga, ON',
    'Mississauga',
    'Ontario',
    'L5B 1M5',
    ARRAY['https://images.pexels.com/photos/205421/pexels-photo-205421.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=300&w=400'],
    'active'
  ),
  (
    sample_user_id,
    'URGENT: Complete Bedroom Set - Must Go!',
    'Relocating urgently! Selling complete bedroom furniture set: queen bed frame, mattress, dresser, and nightstand. All in great condition. Priced to sell quickly - need gone by weekend!',
    299,
    furniture_category_id,
    'good',
    'Scarborough, Toronto, ON',
    'Toronto',
    'Ontario',
    'M1P 2V8',
    ARRAY['https://images.pexels.com/photos/1743229/pexels-photo-1743229.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=300&w=400'],
    'active'
  );
  
END $$;