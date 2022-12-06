## EFS
We will be using EFS for a serverless and scalable solution to store wordpress data automatically. Below code will create 3 NFS mount points three private subnets. Mounting EFS to instances embedded inside the userdata script.

```
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"
  tags = var.tags
}




resource "aws_efs_mount_target" "mount1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.terraform_remote_state.backend.outputs.private_subnet1
  security_groups = [aws_security_group.efs-sg.id]
}


resource "aws_efs_mount_target" "mount2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.terraform_remote_state.backend.outputs.private_subnet2
  security_groups = [aws_security_group.efs-sg.id]
}



resource "aws_efs_mount_target" "mount3" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.terraform_remote_state.backend.outputs.private_subnet3
  security_groups = [aws_security_group.efs-sg.id]
}

```