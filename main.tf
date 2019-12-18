module "ubuntuvm" {
    source = "./modules/ubuntuvm"

    resourcegroup_name="terraformvmrg2"
    prefix="terraformvmss"
    location="southeastasia"
    ssh_username="kunhoko"
    ssh_password="CitrixOnAzure1!"
    ssh_port="22"
}

module "imagecreation" {
    source = "./modules/imagecreation"
    
    resourcegroup_name=module.ubuntuvm.resourcegroup_name
    location=module.ubuntuvm.location
    os_managed_disk_id=module.ubuntuvm.os_managed_disk_id
    data_managed_disk_id=module.ubuntuvm.data_managed_disk_id
    managed_image_name="imgtestwithdatadisk20191217"
}