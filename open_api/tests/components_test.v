import open_api
import os

fn test_components_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/components.json')?
	components := open_api.decode<open_api.Components>(content)?

	assert components.schemas.len == 3
	assert components.parameters.len == 3
	assert components.responses.len == 3
	assert components.security_schemes.len == 2
}
