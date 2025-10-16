@extern(embed)
package environments

// We use cue embed functionality as an equivalent replacement for
// ApplicationSet generators.
config: _ @embed(glob=*/*/config.json)

// With CUE we can constrain the data with a schema.
config: [FILEPATH=string]: #Config

// #Config defines the schema of each config.json file.
#Config: {
	env:     "prod"
	region:  "us"
	type:    "prod"
	chart:   =~"^[0-9]+\\.[0-9]+\\.[0-9]+$"
}
