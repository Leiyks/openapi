import open_api
import os

fn test_schema_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/schema.json')?
	components := open_api.decode<open_api.Components>(content)?
	assert components.schemas.len == 3

	mut schema := components.schemas['Pet'] as open_api.Schema
	assert schema.type_schema == 'object'
	assert schema.discriminator.property_name == 'petType'
	assert schema.properties.len == 2
	assert schema.required == ['name', 'petType']
}
