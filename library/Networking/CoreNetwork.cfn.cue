package Networking

import (
	"strings"
	"github.com/srehero/cfn/schemas/CloudFormation"
	"github.com/srehero/cfn/schemas/EC2"
)

#CoreNetwork: CloudFormation.#Template & {
	let default_public_subnets = {
		"1A": {
			AZ:   "A"
			Cidr: "10.0.0.0/20"
			Role: "public"
		}
		"1B": {
			AZ:   "B"
			Cidr: "10.0.16.0/20"
			Role: "public"
		}
	}

	let default_private_subnets = {
		"1A": {
			AZ:   "A"
			Cidr: "10.0.32.0/20"
			Role: "apps"
		}
		"1B": {
			AZ:   "B"
			Cidr: "10.0.48.0/20"
			Role: "apps"
		}
		"2A": {
			AZ:   "A"
			Cidr: "10.0.64.0/20"
			Role: "data"
		}
		"2B": {
			AZ:   "B"
			Cidr: "10.0.80.0/20"
			Role: "data"
		}
	}

	#Env: {
		Name:           string
		PublicSubnets:  {...} | *default_public_subnets
		PrivateSubnets: {...} | *default_private_subnets
	}

	Resources: {
		// DHCPOptions?
		// VPCDHCPOptionsAssociation?

		VPC: EC2.#VPC & {
			Properties: {
				CidrBlock:          "10.0.0.0/16"
				InstanceTenancy:    "default"
				EnableDnsSupport:   true
				EnableDnsHostnames: true
				Tags: [{
					Key: "Name"
					Value: Ref: "AWS::StackName"
				}]
			}
		}

		InternetGateway: EC2.#InternetGateway & {
			Properties: {
				Tags: [{
					Key: "Name"
					Value: Ref: "AWS::StackName"
				}]
			}
		}

		VPCGatewayAttachment: EC2.#VPCGatewayAttachment & {
			Properties: {
				VpcId: Ref:             "VPC"
				InternetGatewayId: Ref: "InternetGateway"
			}
		}

		for Id, Props in #Env.PublicSubnets {
			let subnet_name = "${AWS::StackName}-\(Props.Role)-subnet-\(strings.ToLower(Id))"

			"PublicSubnet\(Id)": EC2.#Subnet & {
				Properties: {
					VpcId: Ref: "VPC"
					CidrBlock:        Props.Cidr
					AvailabilityZone: Props.AZ
					Tags: [{
						Key: "Name"
						Value: "Fn::Sub": "${AWS::StackName}-\(Props.Role)-subnet-\(strings.ToLower(Id))"
					}]
				}
			}

			"PublicSubnet\(Id)RouteTable": EC2.#RouteTable & {
				Properties: {
					VpcId: Ref: "VPC"
					Tags: [{
						Key: "Name"
						Value: "Fn::Sub": subnet_name
					}]
				}
			}

			"PublicSubnet\(Id)RouteTableAssociation": EC2.#RouteTableAssociation & {
				Properties: {
					SubnetId: Ref:     "PublicSubnet\(Id)"
					RouteTableId: Ref: "PublicSubnet\(Id)RouteTable"
				}
			}
		}

		for Id, Props in #Env.PrivateSubnets {
			let subnet_name = "${AWS::StackName}-\(Props.Role)-subnet-\(strings.ToLower(Id))"

			"PrivateSubnet\(Id)": EC2.#Subnet & {
				Properties: {
					VpcId: Ref: "VPC"
					CidrBlock:        Props.Cidr
					AvailabilityZone: Props.AZ
					Tags: [{
						Key: "Name"
						Value: "Fn::Sub": subnet_name
					}]
				}
			}

			"PrivateSubnet\(Id)RouteTable": EC2.#RouteTable & {
				Properties: {
					VpcId: Ref: "VPC"
					Tags: [{
						Key: "Name"
						Value: "Fn::Sub": subnet_name
					}]
				}
			}

			"PrivateSubnet\(Id)RouteTableAssociation": EC2.#RouteTableAssociation & {
				Properties: {
					SubnetId: Ref:     "PrivateSubnet\(Id)"
					RouteTableId: Ref: "PrivateSubnet\(Id)RouteTable"
				}
			}
		}
	}
}
