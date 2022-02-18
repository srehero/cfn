package ElasticLoadBalancingV2

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Listener: CloudFormation.#Resource & {
	Type: "AWS::ElasticLoadBalancingV2::Listener"
}

#ListenerCertificate: CloudFormation.#Resource & {
	Type: "AWS::ElasticLoadBalancingV2::ListenerCertificate"
}

#ListenerRule: CloudFormation.#Resource & {
	Type: "AWS::ElasticLoadBalancingV2::ListenerRule"
}

#LoadBalancer: CloudFormation.#Resource & {
	Type: "AWS::ElasticLoadBalancingV2::LoadBalancer"
}

#TargetGroup: CloudFormation.#Resource & {
	Type: "AWS::ElasticLoadBalancingV2::TargetGroup"
}
