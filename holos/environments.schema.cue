package holos

#Environment: {
	name:         string
	tier:         "prod" | "nonprod"
	jurisdiction: "us" | "global"
	state:        "texas" | "ohio" | "global"

	// Prod environment names must be prefixed with prod for clarity.
	if tier == "prod" {
		name: "prod" | =~"^prod-"
	}
}

#Environments: {
	[NAME=string]: #Environment & {
		name: NAME
	}
}