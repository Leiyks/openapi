module openapi

import x.json2 { Any }
import json

pub struct OpenApi {
pub mut:
	openapi       string
	info          Info
	paths         Paths
	external_docs ExternalDocumentation
	servers       []Server
	components    Components
	security      []SecurityRequirement
	tags          []Tag
}

pub fn (mut open_api OpenApi) from_json(json Any) ? {
	object := json.as_map()
	check_required<OpenApi>(object, 'openapi', 'info', 'paths')?

	for key, value in object {
		match key {
			'openapi' {
				open_api.openapi = value.str()
			}
			'info' {
				open_api.info = decode<Info>(value.json_str())?
			}
			'paths' {
				open_api.paths = decode<Paths>(value.json_str())?
			}
			'externalDocs' {
				open_api.external_docs = decode<ExternalDocumentation>(value.json_str())?
			}
			'servers' {
				open_api.servers = decode_array<Server>(value.json_str())?
			}
			'components' {
				open_api.components = decode<Components>(value.json_str())?
			}
			'security' {
				open_api.security = decode_array<SecurityRequirement>(value.json_str())?
			}
			'tags' {
				open_api.tags = decode_array<Tag>(value.json_str())?
			}
			else {}
		}
	}

	open_api.validate()?
}

fn (open_api OpenApi) validate() ? {
	if !open_api.openapi.starts_with('3') {
		return error('Failed OpenApi decoding: can only decode OpenAPi version 3')
	}
}
