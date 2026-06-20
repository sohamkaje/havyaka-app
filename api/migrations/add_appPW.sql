-- Run once in phpMyAdmin on havyakus_WPWXK

ALTER TABLE sTu_haa2026_convention_registration
ADD COLUMN appPW VARCHAR(5) NULL;

UPDATE sTu_haa2026_convention_registration
SET appPW = LPAD(FLOOR(RAND() * 100000), 5, '0')
WHERE appPW IS NULL OR appPW = '';
