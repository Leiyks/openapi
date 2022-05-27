import open_api
import os

fn test_parameter_header_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/parameter_header.json')?
	parameter := open_api.decode<open_api.Parameter>(content)?

	assert parameter.name == 'token'
	assert parameter.location == 'header'
	assert parameter.description == 'token to be passed as a header'
	assert parameter.required == true
	assert parameter.style == 'simple'
}

fn test_parameter_path_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/parameter_path.json')?
	parameter := open_api.decode<open_api.Parameter>(content)?

	assert parameter.name == 'username'
	assert parameter.location == 'path'
	assert parameter.description == 'username to fetch'
	assert parameter.required == true
	assert parameter.style == 'simple'
}

fn test_parameter_query_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/parameter_query.json')?
	parameter := open_api.decode<open_api.Parameter>(content)?

	assert parameter.name == 'id'
	assert parameter.location == 'query'
	assert parameter.description == 'ID of the object to fetch'
	assert parameter.required == false
	assert parameter.style == 'form'
	assert parameter.explode == true
}

fn test_parameter_free_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/parameter_free.json')?
	parameter := open_api.decode<open_api.Parameter>(content)?

	assert parameter.name == 'freeForm'
	assert parameter.location == 'query'
	assert parameter.description == ''
	assert parameter.required == false
	assert parameter.style == 'form'
	assert parameter.explode == true
}

fn test_parameter_complex_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/parameter_complex.json')?
	parameter := open_api.decode<open_api.Parameter>(content)?

	assert parameter.name == 'coordinates'
	assert parameter.location == 'query'
	assert parameter.description == ''
	assert parameter.required == false
	assert parameter.style == 'form'
	assert parameter.explode == true

	assert parameter.content.len == 1
	assert 'application/json' in parameter.content
}

fn test_parameter_struct_without_in() ? {
	content := '{ "name": "freeForm" }'
	info := open_api.decode<open_api.Parameter>(content) or { return }
	assert false
}

fn test_parameter_struct_without_name() ? {
	content := '{ "in": "query" }'
	info := open_api.decode<open_api.Parameter>(content) or { return }
	assert false
}

fn test_parameter_struct_without_required() ? {
	content := '{ "name": "freeForm", "in": "path" }'
	info := open_api.decode<open_api.Parameter>(content) or { return }
	assert false
}

fn test_parameter_struct_without_in_wrong() ? {
	content := '{ "name": "freeForm", "in": "aled" }'
	info := open_api.decode<open_api.Parameter>(content) or { return }
	assert false
}
