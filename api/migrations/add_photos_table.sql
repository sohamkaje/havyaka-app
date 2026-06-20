-- Run once in phpMyAdmin on havyakus_WPWXK

CREATE TABLE IF NOT EXISTS sTu_haa2026_convention_photos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    media_type ENUM('image', 'video') NOT NULL DEFAULT 'image',
    caption VARCHAR(255) DEFAULT '',
    uploaded_by VARCHAR(150) NOT NULL,
    uploader_email VARCHAR(150) DEFAULT '',
    convention_day VARCHAR(20) DEFAULT '',
    event_tag VARCHAR(50) DEFAULT 'General',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
