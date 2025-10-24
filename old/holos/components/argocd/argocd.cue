@extern(embed)
package holos

import "holos.example/config/environments"

// Produce a helm chart build plan.
holos: Helm.BuildPlan

parameters: {
	environments.#Config & {
		env:     _ @tag(env)
		region:  _ @tag(region)
		type:    _ @tag(type)
	}
}

Helm: #Helm & {
	Chart: {
		name:    "argo-cd"
		version: "8.6.0"
		repository: {
			name: "argo"
			url:  "https://argoproj.github.io/argo-helm"
		}
	}
	Values: {
		valueFiles["values/env-type/\(parameters.type).yaml"]
		valueFiles["values/regions/\(parameters.region).yaml"]
		valueFiles["values/envs/\(parameters.env).yaml"]
	}
}

valueFiles: _ @embed(glob=values/*/*.yaml)