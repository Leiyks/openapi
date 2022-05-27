module openapi

import x.json2 { Any }
import json

pub struct RequestBody {
pub mut:
	description string
	content     map[string]MediaType
	required    bool
}

pub fn (mut request_body RequestBody) from_json(json Any) ? {
	object := json.as_map()
	check_required<RequestBody>(object, 'content')?

	for key, value in object {
		match key {
			'description' {
				request_body.description = value.str()
			}
			'content' {
				request_body.content = decode_map<MediaType>(value.json_str())?
			}
			'required' {
				request_body.required = value.bool()
			}
			else {}
		}
	}
}
