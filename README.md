Packer + Terraform + Consul + Nomad Example
---

Example using Packer + Terraform for Digital Ocean with Nomad, Consul & fabio

## First Things First

Navigate to the `packer` directory and create all the images. Make sure you populate the variables.json with your DigitalOcean token

```bash
cd packer
vim variables-nomad.json
packer validate -var-file variables-nomad.json ubuntu_do.json

vim variables-consul.json
packer validate -var-file variables-consul.json ubuntu_do.json
```

Once you are happy with the validations you can start building the images

```bash
packer build -var-file variables-consul.json ubuntu_do.json

packer build -var-file variables-nomad.json ubuntu_do.json
```


## License
MIT 2019 Theo Despoudis