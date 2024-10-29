data "terraform_remote_state" "shared" {   
    backend = "local"
    config = {
        path = "terraform.tfstate.d/shared/terraform.tfstate"
    }
}