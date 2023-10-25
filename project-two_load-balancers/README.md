## Description
The Azure Load Balancer services is used to take in requests from your users and then distribute the load accross virtual machines (VMs), that are integrated within a backend pool.
In this case, there need not be an IP address assigned to the VMs; in fact, we chose to assign a public IP address onto the load balancer that will handle the communication onto the VMs.
Sometimes you might want to deploy your VMs as part of an availability set and place them behind the load balancer in order to ensure better availability for your infrastructure - we've also placed this as optional in our configuration.

## Project structure

```
├── README.md
├── locals.tf
├── main.tf                 # Azure Load Balancer configuration
├── modules
│   ├── networking          # Networking module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── resource-group      # Resource group module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── virtual-machines    # VMs module
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── provider.tf
```