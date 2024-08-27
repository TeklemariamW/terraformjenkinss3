%sh
# Install Terraform
sudo apt-get update && sudo apt-get install -y unzip
curl -O https://releases.hashicorp.com/terraform/1.3.6/terraform_1.3.6_linux_amd64.zip
unzip terraform_1.3.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform -v  # Verify installation