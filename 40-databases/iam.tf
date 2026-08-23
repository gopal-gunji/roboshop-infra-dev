resource "aws_iam_role" "mysql" {
    name = local.mysql_role_name #Roboshop-Dev-Mysql
    assume_role_policy = jsondecode({
        version = "2012-10-17"
        statement = [
            {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid = ""
            Principal = {
                Service = "ec2.amazon.com"
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