module openapi

import os

fn test_components_struct() ? {
	content := os.read_file(@VMODROOT + '/testdata/components.json')?
	components := decode<Components>(content)?

	assert components.schemas.len == 3
	assert components.parameters.len == 3
	assert components.responses.len == 3
	assert components.security_schemes.len == 2
}
