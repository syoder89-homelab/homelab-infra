package holos

// Injected from Platform.spec.components.parameters.EnvironmentName
EnvironmentName: string @tag(EnvironmentName)

Environments: #Environments & {
	"prod-home": {
		tier:         "prod"
		jurisdiction: "us"
		state:        "texas"
	}
	// Nonprod environments are colocated together.
	_nonprod: {
		tier:         "nonprod"
		jurisdiction: "us"
		state:        "texas"
	}
	dev:   _nonprod
	test:  _nonprod
	stage: _nonprod
}