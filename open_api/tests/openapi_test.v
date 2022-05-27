import open_api
import os

fn test_basic_open_api_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/open_api_basic.json')?
	open_api := open_api.decode<open_api.OpenApi>(content)?
	assert open_api.openapi == '3'
	assert open_api.info.title == 'Sample Pet Store App'
	assert open_api.info.version == '1.0.1'

	assert open_api.paths.len == 1
	assert '/home' in open_api.paths
	assert open_api.paths['/home'].description == 'homepage'

	assert open_api.tags.len == 2
	assert open_api.tags[0].name == 'cat'
	assert open_api.tags[1].name == 'dog'

	assert open_api.servers.len == 1
	assert open_api.servers[0].url == 'https://random.fr'
	assert open_api.servers[0].variables.len == 1
	assert open_api.servers[0].variables['var1'].default_value == 'default'
}

fn test_open_api_struct_without_paths() ? {
	content := '{ "openapi": "3", "info": {"title": "oui", "version": "1"} }'
	info := open_api.decode<open_api.OpenApi>(content) or { return }
	assert false
}

fn test_open_api_struct_without_info() ? {
	content := '{ "openapi": "3", "paths": {} }'
	info := open_api.decode<open_api.OpenApi>(content) or { return }
	assert false
}

fn test_open_api_struct_without_openapi() ? {
	content := '{ "info": {"title": "oui", "version": "1"}, "paths": {} }'
	info := open_api.decode<open_api.OpenApi>(content) or { return }
	assert false
}
