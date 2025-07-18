-- Create texts table for storing text inputs
CREATE TABLE IF NOT EXISTS texts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security on texts table
ALTER TABLE texts ENABLE ROW LEVEL SECURITY;

-- Create a policy to allow anonymous inserts (for testing)
CREATE POLICY "Allow anonymous inserts" ON texts
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Create a policy to allow anonymous reads (for testing)
CREATE POLICY "Allow anonymous reads" ON texts
  FOR SELECT
  TO anon
  USING (true);

-- Create the uploads storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('uploads', 'uploads', true)
ON CONFLICT (id) DO NOTHING;

-- Create storage policy to allow anonymous uploads
CREATE POLICY "Allow anonymous uploads" ON storage.objects
  FOR INSERT
  TO anon
  WITH CHECK (bucket_id = 'uploads');

-- Create storage policy to allow anonymous reads
CREATE POLICY "Allow anonymous reads" ON storage.objects
  FOR SELECT
  TO anon
  USING (bucket_id = 'uploads');