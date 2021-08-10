resource "aws_db_subnet_group" "db-rds" {
  name       = "db-rds"
  subnet_ids = ["${aws_subnet.private_1.id}", "${aws_subnet.private_2.id}"]

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_db_instance" "drupal" {
    identifier = "drupal-db"
    instance_class = "db.t2.micro"
    
    allocated_storage = 20
    engine = "MySQL"
    engine_version = "8.0.23"
    username = "drupal"
    password = "drupal" #only for test environment
    db_subnet_group_name = aws_db_subnet_group.db-rds.name
    vpc_security_group_ids = [aws_security_group.app-drupal.id]
    publicly_accessible = "false"
    
}