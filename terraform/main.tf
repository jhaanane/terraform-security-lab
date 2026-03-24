provider "aws" {
  region = "eu-west-1"
}

# S3 avec chiffrement AES256 et blocage complet de l'accès public
resource "aws_s3_bucket" "app_data" {
  bucket = "my-secure-app-data"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app_data" {
  bucket                  = aws_s3_bucket.app_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Security group restreint : uniquement HTTPS entrant
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Autoriser uniquement HTTPS entrant depuis internet"

  ingress {
    description = "HTTPS depuis internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Sortie vers internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Base de données sans chiffrement et accessible depuis internet
resource "aws_db_instance" "app" {
  identifier          = "app-db"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "plaintext-password-123"
  publicly_accessible = false
  storage_encrypted   = true
  skip_final_snapshot = false
  allocated_storage   = 20
}
