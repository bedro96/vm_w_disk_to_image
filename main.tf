module "ubuntuvm" {
    source = "./modules/ubuntuvm"

    resourcegroup_name="terraformvmrg2"
    prefix="terraformvmss"
    location="southeastasia"
    ssh_username="kunhoko"
    ssh_password="CitrixOnAzure1!"
    ssh_port="22"
}