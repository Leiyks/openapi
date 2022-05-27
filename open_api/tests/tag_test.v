import open_api
import os

fn test_tag_struct() ? {
	content := '{ "name": "tag_name", "description": "desc" }'
	tag := open_api.decode<open_api.Tag>(content)?
	assert tag.name == 'tag_name'
	assert tag.description == 'desc'
}

fn test_tag_struct_without_name() ? {
	content := '{ "description": "desc" }'
	tag := open_api.decode<open_api.Tag>(content) or { return }
	assert false
}
