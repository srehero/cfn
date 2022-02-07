package Networking

import (
	"strings"
	"github.com/srehero/cfn/schemas/CloudFormation"
	"github.com/srehero/cfn/schemas/EC2"
	"github.com/srehero/cfn/schemas/IAM"
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

	#Env: {
		Name:           string
		Vpc: {...} | *default_vpc
		PublicSubnets:  {...} | *default_public_subnets
		PrivateSubnets: {...} | *default_private_subnets
	}

	Resources: {
		// DHCPOptions?
		// VPCDHCPOptionsAssociation?
		// VPCFlowLogsRole
		// VPCFlowLogsLogGroup
		// VPCFlowLogsToCloudWatch

		VPC: EC2.#VPC & {
			Properties: {
				CidrBlock:          #Env.Vpc.Cidr
				InstanceTenancy:    "default"
				EnableDnsSupport:   true
				EnableDnsHostnames: true
				Tags: [{
					Key: "Name"
					Value: Ref: "AWS::StackName"
				}]
			}
		}

		VPCNetworkAcl: EC2.#NetworkAcl & {
			Properties: {
				VpcId: Ref: "VPC"
				Tags: [{
					Name: Ref: "AWS::StackName"
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
			let subnet_name = "${AWS::StackName}-\(Props.Role)-public-subnet-\(strings.ToLower(Id))"
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
					SubnetId: Ref: "PublicSubnet\(Id)"
					Tags: [{
						Key: "Name"
						Value: "Fn::Sub": nat_gateway_name
					}]
				}
			}

			"PublicSubnet\(Id)": EC2.#Subnet & {
				Properties: {
					VpcId: Ref: "VPC"
					CidrBlock:        Props.Cidr
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

		for Id, Props in #Env.PrivateSubnets {
			let subnet_name = "${AWS::StackName}-\(Props.Role)-private-subnet-\(strings.ToLower(Id))"

			"PrivateSubnet\(Id)": EC2.#Subnet & {
				Properties: {
					VpcId: Ref: "VPC"
					CidrBlock:        Props.Cidr
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

		S3GatewayVPCEndpoint: EC2.#VPCEndpoint & {
			Properties: {
				PolicyDocument: IAM.#PolicyDocument & {
					Statement: [{
						Effect: "Allow"
						Action: "*"
						Resource: "*"
						Principal: "*"
					}]
				}
				RouteTableIds: [ for Id, Props in #Env.PrivateSubnets { { Ref: "PrivateSubnet\(Id)RouteTable" } } ]
				ServiceName: "Fn::Sub": "com.amazonaws.${AWS::Region}.s3"
				VpcId: Ref: "VPC"
				Tags: [{
					Name: "Fn::Sub": "${AWS::StackName}-s3-endpoint"
				}]
			}
		}
	}
}
