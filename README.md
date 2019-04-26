# NOTE:
This repository has been deprecated, please visit the [Pocket Core repository for the latest on Pocket development.](https://github.com/pokt-network/pocket-core)

## Terraform ElasticBeanstalk with multi docker container stack for AION and Pocket 

This terraform project creates the following resources in `us-east-1` in your AWS account:


- 1 VPC [vpc_setup.tf](vpc_setup.tf)
- 6 subnets (3 private and 3 public) [vpc_setup.tf](vpc_setup.tf)
- 1 Internet Gateway and 1 NAT gateway for providing internet access to private instances ([vpc_setup.tf](vpc_setup.tf) and [nat.tf](nat.tf))
- 3 Route tables [vpc_setup.tf](vpc_setup.tf)
- 1 Unique keypair for the instances on the 3 ELB env and bastion instances
- 2 Security groups for the instances in each of the ELBs
- 2 ELB applications [elasticbeanstalk.tf](elasticbeanstalk.tf)
- 3 ELB environments (multi docker containers) [elasticbeanstalk.tf](elasticbeanstalk.tf)
  - 2 ELB environments with Internal LoadBalancer and t3.xlarge instances for aion nodes 
  - 1 ELB environment with Public LoadBalancer and t3.small instances for Pocket nodes
  - All ELB instances are behind private subnets
  - Scaling groups has network rules
  - Enhanced Monitoring
  - Notifications to an specified email

- 1 Bucket and 3 ELB application versions in order to directly deploy aion-mainnet, aion-mastery and pocket [bucket.tf](bucket.tf)
- (Optional) Provides a bastion instance for the `main-public-1` subnet (in case you want to access the instances ) [elasticbeanstalk.tf](elasticbeanstalk.tf) 

NOTE: You can customize the region as shown in customize section below. We just provided  this script with region `us-east-1` as default


It also deploys the following applications on the ELB environments created:

- [aion-mainnet aion](aion-mainnet/deploy.zip)
- [aion-mastery](aion-mainnet/deploy.zip)
- [pocket](pocket-node/deploy.zip)

NOTE: You will see that we provide inside the `Dockerrun.aws.json` on the .zips  a node exporter (prom/node-exporter:v0.15.0) this is provided in case the person in question wants to extract analytics of the node using graphana for better monitoring 
This specific docker configuration can be removed if needed

### Usage

####  Installation and configuration 

First you need to [install terraform](https://www.terraform.io/intro/getting-started/install.html) and the [awscli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) correctly configured with a default profile using the following variables in your environment:

```
AWS_ACCESS_KEY = "YOUR ACCESS KEY"
AWS_SECRET_KEY = "YOUR SECRET KEY"
```

Then inside the project folder:

```
  $ terraform init 
```

Finally, you need to get the public key of an existing ssh keypair from aws to use it as the keypair of the instances we are creating


For obtainning public ssh keys for the instances you should use:

``` $ sudo ssh-keygen -y -f private_key.pem ```

And copy the result inside the `default` value in the variable `public_keypair` on `vars.tf`

If you need to customize this terraform setup, you can see more general aspects on `vars.tf`.

In case you want to switch to another region. Take in count to change the AMI for the bastion instance and the availability zone, because those are values that change between regions.

NOTE: in the `vars.tf` file you will find some of the bastion instance AMI ID commented so you can get those values from there. In the case of the availability zone values, it's just check if <region>-a, <region>-b, <region>-c are available, if not. Just replace then and use onlt the available ones per region


### Execute


If you're all set, Then execute the plan using terraform:


```
terraform plan   # to show the plan (All the changes that will be performed)

terraform apply  # to apply the changes
```

In both commands, terraform will ask:

```
  var.create_bastion
    Enter a value: yes

  var.environment
    Enter a value: staging 

  var.notify_email
    Enter a value: youremail@email.com

```

After everything has been completed, go inside elasticbeanstalk in the region you run terraform and use the URL provided by elasticbeanstalk of the app pocket and check if AION it's working


#### Deploying aion-mainnet and aion-mastery applications versions manually 

This step it's only for those who want to deploy manually aion-mainnet and aion-mastery maybe because changes on the application-version file or any other need

We assume at this point that you have (awscli)[https://aws.amazon.com/cli/] and (awsebcli)[https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html] installed and configured correctly using a IAM user with permissions for deploying on ELB or just using your AWS access id keys and secret keys on the environment level of this user


> cd aion-mainnet

> make deploy ENV=aion-mainnet-node-staging

Just replace `staging` with the environment that you deployed using terraform before

The make command uses the Makefile for zipping the content of the folder `aion-mainnet` and deploying it in the ELB interface automatically.

For more information about configuration in Elasticbeanstalk. Please check this (link)[https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environment-configuration-methods-before.html]

Once this is done, this will deploy to ELB and will create a docker container with aion configured for mainnet purposes. Also it will run the commands described in `.ebextensions/` in order to 
modify the storage of docker to overlay2 for using all the disk space in  the docker container and restart the docker daemon. For more information about the functionality of the ELB and other configurations please check (this)[https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/ebextensions.html]

If you see any issue while deploying your container, please check the `.elasticbeanstalk/config.yml` to see if everything matchs your configuration and if the script Makefile do what your setup expects. 

#### Deploying pocket-node manually


FOr deploying pocket-node is the same procedure as the step before


> cd pocket-node


> make deploy ENV=pocket-staging


Replacing `staging` with the environment that you deployed using terraform before. 


Please check the links in the `Deploying aion-mainnet` step for more info

#### Customizing 
  
For customize you can directly edit vars.tf and the related terraform files mentioned in the list of resources at the beginning of this document.

In case you want to create those resources in another region, you should change the region in [vars.tf](vars.tf) and change the AMI image with an AMI for that specific region for the [bastion.tf](bastion.tf)  


#### Scaling triggers

We configured the scaling group policies with the network perfomance limits of the instances in mind. Please [check](https://cloudonaut.io/ec2-network-performance-cheat-sheet/) for more info


#### References

- Forked from (wardviaene)(https://github.com/wardviaene/terraform-demo)
- Terraform [aws_elastic_beanstalk_environment](https://www.terraform.io/docs/providers/aws/r/elastic_beanstalk_environment.html) options
