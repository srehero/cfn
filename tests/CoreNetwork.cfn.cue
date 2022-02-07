package cfn

import (
	"github.com/srehero/cfn/stacks/Networking"
)

stack: "testing": Networking.#CoreNetwork & {
	#Env: {
		Name: "testing"
		Vpc: {
			Cidr: "10.10.0.0/16"
		}
		PrivateSubnets: {
			"1A": {
				AZ:   "A"
				Cidr: "192.168.0.0/20"
				Role: "apps"
			}
		}
	}
}
