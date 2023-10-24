## Description
A configuration to deploy multiple Azure Virtual Machines along with associated Network Security Groups. 

## Project structure
```
├── README.md
├── main.tf                 # Main configuration file
├── modules
│   ├── networking          # Networking module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── resource-group      # Resource group module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── virtual-machines    # Virtual machines module
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── provider.tf             # Provider service file
```