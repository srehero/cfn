package Networking

import (
	"strings"
	"github.com/srehero/cfn/schemas/CloudFormation"
	"github.com/srehero/cfn/schemas/EC2"
)

#CoreNetwork: CloudFormation.#Template & {
	let default_vpc = {
		Cidr: "10.0.0.0/16"
	}

	let default_public_subnets = {
		"1A": {
			AZ:   "a"
			Cidr: "10.0.0.0/20"
			Role: "apps"
		}
		"1B": {
			AZ:   "b"
			Cidr: "10.0.16.0/20"
			Role: "apps"
		}
	}

	let default_private_subnets = {
		"1A": {
			AZ:   "a"
			Cidr: "10.0.32.0/20"
			Role: "apps"
		}
		"1B": {
			AZ:   "b"
			Cidr: "10.0.48.0/20"
			Role: "apps"
		}
		"2A": {
			AZ:   "a"
			Cidr: "10.0.64.0/20"
			Role: "data"
		}
		"2B": {
			AZ:   "b"
			Cidr: "10.0.80.0/20"
			Role: "data"
		}
	}

	#Stack: {
		Vpc:            {...} | *default_vpc
		PublicSubnets:  {...} | *default_public_subnets
		PrivateSubnets: {...} | *default_private_subnets
	}

	Resources: {
		VPC: EC2.#VPC & {
			Properties: {
				CidrBlock:          #Stack.Vpc.Cidr
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

		for Id, Props in #Stack.PublicSubnets {
			let subnet_name = "${AWS::StackName}-public-\(Props.Role)-subnet-\(strings.ToLower(Id))"
			let nat_gateway_name = "${AWS::StackName}-nat-gateway-\(strings.ToLower(Props.AZ))"

			"NatGateway\(strings.ToUpper(Props.AZ))EIP": EC2.#EIP & {
				DependsOn: "VPCGatewayAttachment"
				Properties: {
					Domain: "vpc"
					Tags: [{
						Key: "Name"
						Value: "Fn::Sub": nat_gateway_name
					}]
				}
			}

			"NatGateway\(strings.ToUpper(Props.AZ))": EC2.#NatGateway & {
				DependsOn: "VPCGatewayAttachment"
				Properties: {
					AllocationId: "Fn::GetAtt": "NatGateway\(strings.ToUpper(Props.AZ))EIP.AllocationId"
					SubnetId: Ref:              "PublicSubnet\(Id)"
					Tags: [{
						Key: "Name"
						Value: "Fn::Sub": nat_gateway_name
					}]
				}
			}

			"PublicSubnet\(Id)": EC2.#Subnet & {
				Properties: {
					VpcId: Ref: "VPC"
					CidrBlock: Props.Cidr
					AvailabilityZone: "Fn::Sub": "${AWS::Region}\(strings.ToLower(Props.AZ))"
					MapPublicIpOnLaunch: true
					Tags: [{
						Key: "Name"
						Value: "Fn::Sub": subnet_name
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

			"PublicSubnet\(Id)InternetGatewayRoute": EC2.#Route & {
				DependsOn: "VPCGatewayAttachment"
				Properties: {
					RouteTableId: Ref: "PublicSubnet\(Id)RouteTable"
					DestinationCidrBlock: "0.0.0.0/0"
					GatewayId: Ref: "InternetGateway"
				}
			}

			"PublicSubnet\(Id)RouteTableAssociation": EC2.#SubnetRouteTableAssociation & {
				Properties: {
					SubnetId: Ref:     "PublicSubnet\(Id)"
					RouteTableId: Ref: "PublicSubnet\(Id)RouteTable"
				}
			}
		}

		for Id, Props in #Stack.PrivateSubnets {
			let subnet_name = "${AWS::StackName}-private-\(Props.Role)-subnet-\(strings.ToLower(Id))"

			"PrivateSubnet\(Id)": EC2.#Subnet & {
				Properties: {
					VpcId: Ref: "VPC"
					CidrBlock: Props.Cidr
					AvailabilityZone: "Fn::Sub": "${AWS::Region}\(strings.ToLower(Props.AZ))"
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

			"PrivateSubnet\(Id)NatGatewayRoute": EC2.#Route & {
				DependsOn: "VPCGatewayAttachment"
				Properties: {
					RouteTableId: Ref: "PrivateSubnet\(Id)RouteTable"
					DestinationCidrBlock: "0.0.0.0/0"
					NatGatewayId: Ref: "NatGateway\(strings.ToUpper(Props.AZ))"
				}
			}

			"PrivateSubnet\(Id)RouteTableAssociation": EC2.#SubnetRouteTableAssociation & {
				Properties: {
					SubnetId: Ref:     "PrivateSubnet\(Id)"
					RouteTableId: Ref: "PrivateSubnet\(Id)RouteTable"
				}
			}
		}
	}

	Outputs: {
		VpcId: {
			Value: Ref: "VPC"
			Export: Name: "Fn::Sub": "${AWS::StackName}-VpcId"
		}
		VpcCidrBlock: {
			Value: "Fn::GetAtt": "VPC.CidrBlock"
			Export: Name: "Fn::Sub": "${AWS::StackName}-VpcCidrBlock"
		}
		VpcDefaultNetworkAcl: {
			Value: "Fn::GetAtt": "VPC.DefaultNetworkAcl"
			Export: Name: "Fn::Sub": "${AWS::StackName}-VpcDefaultNetworkAcl"
		}
		VpcDefaultSecurityGroup: {
			Value: "Fn::GetAtt": "VPC.DefaultSecurityGroup"
			Export: Name: "Fn::Sub": "${AWS::StackName}-VpcDefaultSecurityGroup"
		}
		for Id, Props in #Stack.PublicSubnets {
			"PublicSubnet\(Id)Id": {
				Value: Ref: "PublicSubnet\(Id)"
				Export: Name: "Fn::Sub": "${AWS::StackName}-PublicSubnet\(Id)Id"
			}
			"PublicSubnet\(Id)AvailabilityZone": {
				Value: "Fn::GetAtt": "PublicSubnet\(Id).AvailabilityZone"
				Export: Name: "Fn::Sub": "${AWS::StackName}-PublicSubnet\(Id)AvailabilityZone"
			}
			"PublicSubnet\(Id)RouteTableId": {
				Value: Ref: "PublicSubnet\(Id)RouteTable"
				Export: Name: "Fn::Sub": "${AWS::StackName}-PublicSubnet\(Id)RouteTableId"
			}
		}
		for Id, Props in #Stack.PrivateSubnets {
			"PrivateSubnet\(Id)Id": {
				Value: Ref: "PrivateSubnet\(Id)"
				Export: Name: "Fn::Sub": "${AWS::StackName}-PrivateSubnet\(Id)Id"
			}
			"PrivateSubnet\(Id)AvailabilityZone": {
				Value: "Fn::GetAtt": "PrivateSubnet\(Id).AvailabilityZone"
				Export: Name: "Fn::Sub": "${AWS::StackName}-PrivateSubnet\(Id)AvailabilityZone"
			}
			"PrivateSubnet\(Id)RouteTableId": {
				Value: Ref: "PrivateSubnet\(Id)RouteTable"
				Export: Name: "Fn::Sub": "${AWS::StackName}-PrivateSubnet\(Id)RouteTableId"
			}
		}
	}
}
