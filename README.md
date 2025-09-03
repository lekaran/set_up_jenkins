# set_up_jenkins
This repo set up the infrastructure and the installation of Jenkins

# terraform directory
In this directory we can find the code of the infrastructure for the project. <br>
For this project we need : <br>
terraform version 1.13.X <br>
aws provider version 6.10.X <br>
<br>
To create the infra : <br>
Set up the AWS Configuration. <br>
Enter in the `terraform` directory. <br>
Make this command de deploy the infra : <br>
```
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

Afte, make this commande to retrieve the IP and the DNS of the Server where Jenkins are installed : <br>
```
$ terraform output
``` 

To destroy the infra : <br>
```
$ terraform destroy -auto-approve
```

# ansible directory 
In this directory we can find the code of the installation of Jenkins for the project.