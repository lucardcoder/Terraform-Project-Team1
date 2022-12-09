## Auto Scaling Group & Application Load Balancer
Load Balancer works with launch template Auto Scaling Group to distribute incoming traffic across targets to Servers (healthy Amazon EC2 instances) and Database. This increases the scalability and availability of the application. We can enable Load Balancer within multiple availability zones to increase the fault tolerance of your applications.
```
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.3"
  # Autoscaling group
  name                      = "Project-asg"
  min_size                  = 1
  max_size                  = 99
  desired_capacity          = 3
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier = [
    data.terraform_remote_state.backend.outputs.private_subnet1,
    data.terraform_remote_state.backend.outputs.private_subnet2,
    data.terraform_remote_state.backend.outputs.private_subnet3
  ]
  depends_on = [module.alb]
```

```

module "alb" {
  source                           = "terraform-aws-modules/alb/aws"
  version                          = "~> 8.0"
  name                             = "my-alb"
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = true
  vpc_id                           = data.terraform_remote_state.backend.outputs.vpc_id
  subnets = [
    data.terraform_remote_state.backend.outputs.public_subnet1,
    data.terraform_remote_state.backend.outputs.public_subnet2,
    data.terraform_remote_state.backend.outputs.public_subnet3
  ]


  security_groups = [
    aws_security_group.alb-sg.id
  ]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  tags = var.tags
}
```

## Route53
Route53 records let you route traffic to selected AWS resources inside the VPC. In this case it will be using to route Application Load Balancer endpoints as well as RDS cluster endpoints.

```
data "aws_route53_zone" "my_zone" {
  name         = var.domain_name
  private_zone = false
}



resource "aws_route53_record" "alias_route53_record" {
  zone_id = data.aws_route53_zone.my_zone.zone_id     
  name    = "wordpress.${var.domain_name}"              # Replace with your name/domain/subdomain
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
```

##  User Data to Install Wordpress & NFS & Redis Cache
Below code is used to install dependencies, Wordpress, mount EFS mount points to the instances and installs Redis Cache.

```
#!/bin/bash
# variable will be populated by terraform template
db_username=${db_username}
db_user_password=${db_user_password}
db_name=${db_name}
db_RDS=${db_RDS}

# install LAMP Server
yum update -y

#install apache server and mysql client
yum install -y httpd
yum install -y mysql

sudo yum install nfs-utils -y -q

# Mounting Efs 
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/  /var/www/html
# Making Mount Permanent
echo '${efs_dns_name}:/ /var/www/html nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab


#first enable php7.xx from  amazon-linux-extra and install it
amazon-linux-extras enable php7.4
yum clean metadata
yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel}

#install imagick extension
yum -y install gcc ImageMagick ImageMagick-devel ImageMagick-perl
pecl install imagick
chmod 755 /usr/lib64/php/modules/imagick.so
cat <<EOF >>/etc/php.d/20-imagick.ini

extension=imagick

EOF

systemctl restart php-fpm.service

systemctl start  httpd


# Change OWNER and permission of directory /var/www
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;


#Download wordpress package and extract
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
# Create wordpress configuration file and update database value
cd /var/www/html
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/$db_name/g" wp-config.php
sed -i "s/username_here/$db_username/g" wp-config.php
sed -i "s/password_here/$db_user_password/g" wp-config.php
sed -i "s/localhost/$db_RDS/g" wp-config.php
cat <<EOF >>/var/www/html/wp-config.php
define( 'FS_METHOD', 'direct' );
define('WP_MEMORY_LIMIT', '128M');
EOF



# Change permission of /var/www/html/
chown -R ec2-user:apache /var/www/html
chmod -R 774 /var/www/html



#  enable .htaccess files in Apache config using sed command
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf

#Make apache  autostart and restart apache
systemctl enable  httpd.service
systemctl restart httpd.service
echo WordPress Installed


## Install Redis Cache ##

sudo yum -y install gcc make # install GCC compiler
cd /usr/local/src
sudo wget http://download.redis.io/redis-stable.tar.gz
sudo tar xvzf redis-stable.tar.gz
sudo rm -f redis-stable.tar.gz
cd redis-stable
sudo yum groupinstall "Development Tools" -y
sudo make distclean
sudo make
sudo yum install -y tcl

sudo cp src/redis-server /usr/local/bin/
sudo cp src/redis-cli /usr/local/bin/

redis-server --daemonize yes

```

Template file data is used read from user_data.sh file.

```
data "template_file" "user_data" {
  template = file("user_data.sh")
  vars = {
    db_username      = var.database_user
    db_user_password = data.aws_ssm_parameter.foo.value ## retreive from random_string resource in main.tf in RDS folder.
    db_name          = var.database_name
    db_RDS           = data.aws_rds_cluster.wordpress_db_cluster.endpoint
    efs_dns_name     = data.aws_efs_file_system.efs.dns_name
  }
}
```
