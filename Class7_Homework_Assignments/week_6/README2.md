# Class 7 Week 6 HW Deliverables Terraform Guide 
The purpose of this guide is to provide the initial instructions to setup Terraform for pervisioning infrastructure in the AWS cloud.

## Initial Terraform configuration confirmation check 
* Verify AWS CLI Configuration and terraform version. Open Git Bash and run the following commnads. Aws configure | Terragorm -v version
  
`AWS configure`
<img width="942" height="515" alt="image" src="https://github.com/user-attachments/assets/16d5e51a-013e-435e-8902-a9168e78c10b" />

`Terraform -version`
<img width="956" height="251" alt="image" src="https://github.com/user-attachments/assets/bd414fb2-3c78-406f-84d6-2d081630b7fa" />

## Create Terraform file 
* In Git Bash navigate to the local Terraform folder and create folder 2025oct25 (or a folder that makes sense for your project). (NO CAPITAL LETTERS, NO SPACES AND DO NOT SAVE IT TO ONE DRIVE). From the Terraform foilder in Git bash, run the commands below.
1. Command: `mkdir 2025oct25`
2. Command: `cd 2025oct25`
   
*Create a terreform authentication file in the newly created directory/folder 2025oct25.Verify that the file is empty and then copy the code from the 0-auth,tf file in forted GithHub repository to the 0-auth file you created.
1. Command: `touch 0-auth.tf`
2. Command: `cat 0-auth.tf`  (this command is to verify that the file is empty)
3. Command: `code .` (this command opens VS code)
4. Instruction: In Vs code Navigate and select Terminal>new terminal located to the top and left of the screen.
5. Instruction: go to https://github.com/malgus-waf/class5 and click on 0-auth
6. instruction: copy and paste the user data from https://github.com/malgus-waf/class5/blob/main/0-Auth.tf and paste it into your 0-auth.tf file via VS code.
7. Instruction: save the data to your 0-auth.tf file (CTRl+S)
8. Command: `curl -o .gitignore https://raw.githubusercontent.com/Aaron-Rob/terraform-aws/master/.gitignore b` (downloads the .gitignore file from remotr directory)

## Excute and validate Terraform 
1. Command: `terraform init` (starts Terraform)
2. Command: `terraform validate` (checks configuration for syntex errors)
3. Command: `terraform plan` (creates a plan to configure/pervision the infrastructure you requested)
4. command: `terraform apply` (executes the plan)

## Confirm that Terraform has been properly configured.
To in insure that your Terraform configuratuion is working properly you should have the following files in folder 2025oct25.
* terraform.lock.hcl
* .gitignore
* terraform.tfstate
**Note: DO NOT TOUCH OR MODIFY ANY OF THE ABOVE FILES.**

## Example of what your VS code ootput should look like.
<img width="1280" height="637" alt="image" src="https://github.com/user-attachments/assets/545eca58-08ed-4ac2-801f-71dd783aea55" />
