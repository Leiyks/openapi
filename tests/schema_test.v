import openapi
import os

fn test_schema_struct() ? {
	content := os.read_file(@VMODROOT + '/testdata/schema.json')?
	components := openapi.decode<openapi.Components>(content)?
	assert components.schemas.len == 3

	mut schema := components.schemas['Pet'] as openapi.Schema
	assert schema.type_schema == 'object'
	assert schema.discriminator.property_name == 'petType'
	assert schema.properties.len == 2
	assert schema.required == ['name', 'petType']
}
