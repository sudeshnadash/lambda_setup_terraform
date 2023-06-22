This repository is an example to create terraform resources for lambda function and also setting up lambda function in local without using SAM.

These are the following folders: <br/>
1. layer - This folder contains all the files in my custom layer. This sits inside python folder so the AWS treats it as a python module

2. src - This is the main folder for the lambda function file<br/>

3. terraform - This folder contains the IAC scripts. Make sure you enter into the correct env folder using the below command:<br/>
`cd terraform/env/dev`

And then run the below scripts to install it in your AWS account: <br/>
`terraform init <br/>
terraform validate<br/>
terraform plan <br/>
terraform apply`

4. test - This folder contains all the test scripts.

5. requirements.txt - This contains all the dependencies needed to be installed to use the application
