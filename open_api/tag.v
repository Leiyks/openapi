module open_api

import x.json2 { Any }
import json

pub struct Tag {
pub mut:
	name          string
	external_docs ExternalDocumentation
	description   string
}

pub fn (mut tag Tag) from_json(json Any) ? {
	object := json.as_map()
	check_required<Tag>(object, 'name')?

	for key, value in object {
		match key {
			'name' {
				tag.name = value.str()
			}
			'externalDocs' {
				tag.external_docs = decode<ExternalDocumentation>(value.json_str())?
			}
			'description' {
				tag.description = value.str()
			}
			else {}
		}
	}
}
