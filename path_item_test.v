module openapi

import os

fn test_path_item_struct() ? {
	content := os.read_file(@VMODROOT + '/testdata/path_item.json')?
	path_item := decode<PathItem>(content)?

	assert path_item.get.description == 'Returns pets based on ID'
	assert path_item.get.summary == 'Find pets by ID'
	assert path_item.get.operation_id == 'getPetsById'
	assert path_item.get.responses.len == 1
	assert path_item.parameters.len == 1
}

fn test_path_item_operations_map() ? {
	content := os.read_file(@VMODROOT + '/testdata/path_item.json')?
	path_item := decode<PathItem>(content)?

	assert path_item.get_operations().keys() == ['GET']
}
