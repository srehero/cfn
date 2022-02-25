package Route53

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#FirewallDomainList: CloudFormation.#Resource & {
	Type: "AWS::Route53Resolver::FirewallDomainList"
}

#FirewallRuleGroup: CloudFormation.#Resource & {
	Type: "AWS::Route53Resolver::FirewallRuleGroup"
}

#FirewallRuleGroupAssociation: CloudFormation.#Resource & {
	Type: "AWS::Route53Resolver::FirewallRuleGroupAssociation"
}

#ResolverConfig: CloudFormation.#Resource & {
	Type: "AWS::Route53Resolver::ResolverConfig"
}

#ResolverDNSSECConfig: CloudFormation.#Resource & {
	Type: "AWS::Route53Resolver::ResolverDNSSECConfig"
}

#ResolverEndpoint: CloudFormation.#Resource & {
	Type: "AWS::Route53Resolver::ResolverEndpoint"
}

#ResolverQueryLoggingConfig: CloudFormation.#Resource & {
	Type: "AWS::Route53Resolver::ResolverQueryLoggingConfig"
}

#ResolverQueryLoggingConfigAssociation: CloudFormation.#Resource & {
	Type: "AWS::Route53Resolver::ResolverQueryLoggingConfigAssociation"
}

#ResolverRule: CloudFormation.#Resource & {
	Type: "AWS::Route53Resolver::ResolverRule"
}

#ResolverRuleAssociation: CloudFormation.#Resource & {
	Type: "AWS::Route53Resolver::ResolverRuleAssociation"
}
