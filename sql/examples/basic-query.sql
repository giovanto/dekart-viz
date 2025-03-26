-- Basic query with minimal columns
SELECT 
  id,
  geom,
  aantal_inwoners 
FROM 
  netherlands.vk500
LIMIT 100;