module openapi

import x.json2 { Any }
import json

pub struct Example {
pub mut:
	external_value string
	summary        string
	description    string
	value          Any
}

pub fn (mut example Example) from_json(json Any) ? {
	object := json.as_map()

	if 'value' in object && 'externalValue' in object {
		return error('Failed Example decoding: "value" and "externalValue" are mutually exclusive')
	}

	for key, value in object {
		match key {
			'externalValue' {
				example.external_value = value.str()
			}
			'summary' {
				example.summary = value.str()
			}
			'description' {
				example.description = value.str()
			}
			'value' {
				example.value = value
			}
			else {}
		}
	}
}
