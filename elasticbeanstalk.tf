########################################## NODE ELB ################################

# key pair
resource "aws_key_pair" "aion-mastery" {
  key_name = "aion-mastery-node-${var.environment}" 
  public_key = "${var.public_keypair}"

}

# sec group
resource "aws_security_group" "aion-mastery" {
  vpc_id = "${aws_vpc.main.id}"
  name = "aion-mastery-node-${var.environment}"
  description = "App testnet security group"
  ingress {
      from_port = 80 
      to_port = 80 
      protocol = "tcp"
      cidr_blocks = ["${aws_subnet.main-private-1.cidr_block}", "${aws_subnet.main-private-2.cidr_block}", "${aws_subnet.main-private-3.cidr_block}"]
      security_groups = ["${aws_security_group.pocket.id}"] 
  },
  ingress {
      from_port = 30000 
      to_port = 30999 
      protocol = "tcp"
      cidr_blocks = ["${aws_subnet.main-private-1.cidr_block}", "${aws_subnet.main-private-2.cidr_block}", "${aws_subnet.main-private-3.cidr_block}"]
      self = true 
  },
  ingress {
      from_port = 30000 
      to_port = 30999 
      protocol = "udp"
      cidr_blocks = ["${aws_subnet.main-private-1.cidr_block}", "${aws_subnet.main-private-2.cidr_block}", "${aws_subnet.main-private-3.cidr_block}"]
      self = true 
 
  },
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "aion-mastery-node-${var.environment}"
  }
}

# aion  node 

resource "aws_elastic_beanstalk_environment" "aion-mastery-node-env" {
  name = "aion-mastery-node-${var.environment}"
  application = "${aws_elastic_beanstalk_application.aion-mainnet-node.name}"
  solution_stack_name = "${var.platform}"
  cname_prefix = "aion-mastery-node-${var.environment}"
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${aws_vpc.main.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.main-private-1.id},${aws_subnet.main-private-2.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "false"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBScheme"
    value = "internal"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "LoadBalancerType"
    value = "application"
  }  
  
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.main-public-1.id},${aws_subnet.main-public-2.id}"
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name = "CrossZone"
    value = "true"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "app-ec2-role"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = "${aws_security_group.aion-mastery.id}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "${aws_key_pair.aion-mastery.id}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "${var.node_instancetype}"
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "aws-elasticbeanstalk-service-role"
  }

# START: Deploying policies

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "DeploymentPolicy"
    value = "AllAtOnce"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSize"
    value = "30"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSizeType"
    value = "Percentage"
  }

# END: Deploying policies

  setting {
    namespace = "aws:autoscaling:asg"
    name = "Availability Zones"
    value = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }

# START: Autoscaling policies
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Statistic"
    value = "Average"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "MeasureName"
    value = "NetworkIn"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Unit"
    value = "Bytes/Second"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "UpperBreachScaleIncrement"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "UpperThreshold"
    value = "37500000"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "LowerBreachScaleIncrement"
    value = "1"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "LowerThreshold"
    value = "16250000"
  }

  
# END:Autoscaling policies

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateType"
    value = "Health"
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name = "Notification Endpoint"
    value = "${var.notify_email}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name = "Notification Protocol"
    value = "email"
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name = "SystemType"
    value = "enhanced"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "RootVolumeSize"
    value = "300"
  }
  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "RootVolumeType"
    value = "gp2"
  }


}

########################################## NODE ELB ################################

# key pair
resource "aws_key_pair" "aion-mainnet" {
  key_name = "aion-mainnet-node-${var.environment}" 
  public_key = "${var.public_keypair}"

}

# sec group
resource "aws_security_group" "aion-mainnet" {
  vpc_id = "${aws_vpc.main.id}"
  name = "aion-mainnet-node-${var.environment}"
  description = "App mainnet security group"
  ingress {
      from_port = 80 
      to_port = 80 
      protocol = "tcp"
      cidr_blocks = ["${aws_subnet.main-private-1.cidr_block}", "${aws_subnet.main-private-2.cidr_block}", "${aws_subnet.main-private-3.cidr_block}"]
      security_groups = ["${aws_security_group.pocket.id}"] 
  },
  ingress {
      from_port = 30000 
      to_port = 30999 
      protocol = "tcp"
      cidr_blocks = ["${aws_subnet.main-private-1.cidr_block}", "${aws_subnet.main-private-2.cidr_block}", "${aws_subnet.main-private-3.cidr_block}"]
      self = true 
  },
  ingress {
      from_port = 30000 
      to_port = 30999 
      protocol = "udp"
      cidr_blocks = ["${aws_subnet.main-private-1.cidr_block}", "${aws_subnet.main-private-2.cidr_block}", "${aws_subnet.main-private-3.cidr_block}"]
      self = true 
 
  },
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "aion-mainnet-node-${var.environment}"
  }
}

# aion  node 

resource "aws_elastic_beanstalk_application" "aion-mainnet-node" {
  name = "aion-mainnet-node"
  description = "aion"
}

resource "aws_elastic_beanstalk_environment" "aion-mainnet-node-env" {
  name = "${aws_elastic_beanstalk_application.aion-mainnet-node.name}-${var.environment}"
  application = "${aws_elastic_beanstalk_application.aion-mainnet-node.name}"
  solution_stack_name = "${var.platform}"
  cname_prefix = "${aws_elastic_beanstalk_application.aion-mainnet-node.name}-${var.environment}"
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${aws_vpc.main.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.main-private-1.id},${aws_subnet.main-private-2.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "false"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBScheme"
    value = "internal"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "LoadBalancerType"
    value = "application"
  }  
  
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.main-public-1.id},${aws_subnet.main-public-2.id}"
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name = "CrossZone"
    value = "true"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "app-ec2-role"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = "${aws_security_group.aion-mainnet.id}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "${aws_key_pair.aion-mainnet.id}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "${var.node_instancetype}"
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "aws-elasticbeanstalk-service-role"
  }

# START: Deploying policies

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "DeploymentPolicy"
    value = "AllAtOnce"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSize"
    value = "30"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSizeType"
    value = "Percentage"
  }

# END: Deploying policies

  setting {
    namespace = "aws:autoscaling:asg"
    name = "Availability Zones"
    value = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }

# START: Autoscaling policies
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Statistic"
    value = "Average"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "MeasureName"
    value = "NetworkIn"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Unit"
    value = "Bytes/Second"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "UpperBreachScaleIncrement"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "UpperThreshold"
    value = "37500000"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "LowerBreachScaleIncrement"
    value = "1"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "LowerThreshold"
    value = "16250000"
  }

  
# END:Autoscaling policies

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateType"
    value = "Health"
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name = "Notification Endpoint"
    value = "${var.notify_email}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name = "Notification Protocol"
    value = "email"
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name = "SystemType"
    value = "enhanced"
  }
 
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "RootVolumeSize"
    value = "300"
  }

}

########################################## POCKET NODE ELB ################################

# key pair
resource "aws_key_pair" "pocket" {
  key_name = "pocket-node-${var.environment}" 
  public_key = "${var.public_keypair}"


}

# sec group
resource "aws_security_group" "pocket" { 
  vpc_id = "${aws_vpc.main.id}"
  name = "pocket-node-${var.environment}"
  description = "App prod security group"
  ingress {
      from_port = 80 
      to_port = 80 
      protocol = "tcp"
      cidr_blocks = ["${aws_subnet.main-public-1.cidr_block}", "${aws_subnet.main-public-2.cidr_block}", "${aws_subnet.main-public-3.cidr_block}" ]
  },
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "pocket-node-${var.environment}"
  }
}

# Pocket node 

resource "aws_elastic_beanstalk_application" "pocket-node" {
  name = "pocket"
  description = "pocket-node-application"

  

}

resource "aws_elastic_beanstalk_environment" "pocket-node-env" {
  depends_on = ["aws_elastic_beanstalk_environment.aion-mastery-node-env", 
                "aws_elastic_beanstalk_environment.aion-mainnet-node-env"]

  name = "${aws_elastic_beanstalk_application.pocket-node.name}-${var.environment}"
  application = "${aws_elastic_beanstalk_application.pocket-node.name}"
  solution_stack_name = "${var.platform}"
  cname_prefix = "${aws_elastic_beanstalk_application.pocket-node.name}-${var.environment}"
  
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${aws_vpc.main.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.main-private-1.id},${aws_subnet.main-private-2.id},${aws_subnet.main-private-3.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "false"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "app-ec2-role"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = "${aws_security_group.pocket.id}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "${aws_key_pair.pocket.id}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "${var.pocket_instancetype}"
  }

  # START: Autoscaling policies
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Statistic"
    value = "Average"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "MeasureName"
    value = "NetworkIn"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Unit"
    value = "Bytes/Second"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "UpperBreachScaleIncrement"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "UpperThreshold"
    value = "10500000"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "LowerBreachScaleIncrement"
    value = "1"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "LowerThreshold"
    value = "08250000"
  }

  
# END:Autoscaling policies

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "aws-elasticbeanstalk-service-role"
  } 
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "LoadBalancerType"
    value = "application"
  }  
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBScheme"
    value = "public"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.main-public-1.id},${aws_subnet.main-public-2.id}"
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name = "CrossZone"
    value = "true"
  }
  
  # START: Deploying policies

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "DeploymentPolicy"
    value = "AllAtOnce"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSize"
    value = "30"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSizeType"
    value = "Percentage"
  }

# END: Deploying policies

  setting {
    namespace = "aws:autoscaling:asg"
    name = "Availability Zones"
    value = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateType"
    value = "Health"
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name = "Notification Endpoint"
    value = "${var.notify_email}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name = "Notification Protocol"
    value = "email"
  }

 setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name = "SystemType"
    value = "enhanced"
  }


# ENV VARIABLES:
  setting {   
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "POCKET_NODE_PLUGIN_AION_TESTNET_NODE"
    value = "http://${aws_elastic_beanstalk_environment.aion-mastery-node-env.cname}"
  }

  setting {   
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "POCKET_NODE_PLUGIN_AION_MAINNET_NODE"
    value = "http://${aws_elastic_beanstalk_environment.aion-mainnet-node-env.cname}"
  }
 

  setting {   
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "POCKET_NODE_PLUGIN_AION_TEST_NETWORK_ID"
    value = "4"
  }
  
  setting {   
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "POCKET_NODE_PLUGIN_AION_MAIN_NETWORK_ID"
    value = "1"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name = "HealthCheckPath"
    value = "/node/"
  }

}
