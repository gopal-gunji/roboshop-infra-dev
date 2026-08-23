resource "aws_iam_role" "mysql" {
    name = local.mysql_role_name #Roboshop-Dev-Mysql
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid = ""
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        },
      ]
    })
    
    tags = merge(
        {
            Name = local.mysql_role_name
        },
        local.common_tags
    )
}


resource "aws_iam_policy" "mysql" {
  name        = "S3ReadOnlyAccessPolicy"
  description = "A policy for mysql EC2 instance"
  policy      = file("mysql-iam-policy.json")
}