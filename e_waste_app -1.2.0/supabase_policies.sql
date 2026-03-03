-- 1. Enable RLS
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 2. SELECT Policy (READ Access)
-- RECOMMENDATION: Keep this PUBLIC so your app can display the image using Image.network()
-- If you make this strict, your app will NOT be able to show the photo.
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'user_photos' );

-- 3. INSERT Policy (UPLOAD Access)
-- Strict: Only allow upload to own folder
DROP POLICY IF EXISTS "Authenticated users can upload" ON storage.objects;
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'user_photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 4. UPDATE Policy (EDIT Access)
-- Strict: Only allow update of own files
DROP POLICY IF EXISTS "Users can update their own files" ON storage.objects;
CREATE POLICY "Users can update their own files"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'user_photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 5. DELETE Policy (DELETE Access)
-- Strict: Only allow delete of own files
DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;
CREATE POLICY "Users can delete their own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'user_photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
